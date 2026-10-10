import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/book_search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../book_form/book_form_screen.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../providers/book_actions_controller.dart';
import '../providers/book_providers.dart';
import '../scan/isbn_scanner_screen.dart';
import '../shelf_labels.dart';
import '../widgets/book_cover.dart';
import '../widgets/readable_width.dart';
import '../widgets/scan_barcode_icon.dart';
import '../widgets/shelf_picker.dart';
import '../widgets/status_views.dart';
import 'search_controller.dart';
import 'search_state.dart';

/// Recherche de livres dans Open Library et Apple Books, avec autocomplétion.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  /// Lit l'ISBN au dos d'un livre et le cherche aussitôt.
  Future<void> _scan() async {
    final isbn = await ref.read(isbnScannerProvider)(context);
    if (isbn == null || !mounted) {
      return;
    }
    _field.text = isbn;
    setState(() {});
    ref.read(searchControllerProvider.notifier).onQueryChanged(isbn);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final controller = ref.read(searchControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.searchABook)),
      body: ReadableWidth(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _field,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: controller.onQueryChanged,
                decoration: InputDecoration(
                  hintText: context.l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  // Champ vide : le scanner de code-barres ; sinon, effacer.
                  suffixIcon: _field.text.isEmpty
                      ? IconButton(
                          icon: const ScanBarcodeIcon(),
                          tooltip: context.l10n.scanBarcode,
                          onPressed: _scan,
                        )
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          tooltip: context.l10n.clear,
                          onPressed: () {
                            _field.clear();
                            controller.clear();
                            setState(() {});
                          },
                        ),
                ),
              ),
            ),
            if (state.isLoading) const LinearProgressIndicator(minHeight: 2),
            Expanded(child: _Results(state: state)),
          ],
        ),
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final error = state.error;
    if (state.status == SearchStatus.failure && error != null) {
      return ErrorView(
        error: error,
        onRetry: ref.read(searchControllerProvider.notifier).retry,
      );
    }

    if (state.status == SearchStatus.idle) {
      return EmptyState(
        icon: Icons.search,
        title: context.l10n.searchPromptTitle,
        message: state.query.trim().isEmpty
            ? context.l10n.searchPromptMessage
            : context.l10n.searchMinChars(kMinQueryLength),
      );
    }

    if (state.hasNoResult) {
      return EmptyState(
        icon: Icons.search_off,
        title: context.l10n.noResultsTitle,
        message: context.l10n.noResultsMessage,
        action: FilledButton.tonalIcon(
          onPressed: () => openManualBookForm(context),
          icon: const Icon(Icons.edit_outlined),
          label: Text(context.l10n.addBookByHand),
        ),
      );
    }

    if (state.results.isEmpty) {
      // Première requête encore en vol : la barre de progression suffit.
      return const SizedBox.shrink();
    }

    // Une erreur de lecture de la base ne doit pas cacher les résultats : sans
    // cette liste, on considère simplement qu'aucun livre n'est déjà connu.
    final known = ref.watch(knownOlKeysProvider).value ?? const <String>{};

    return ListView.separated(
      itemCount: state.results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final result = state.results[index];
        return _ResultTile(
          result: result,
          alreadyAdded: known.contains(result.olKey),
        );
      },
    );
  }
}

class _ResultTile extends ConsumerWidget {
  const _ResultTile({required this.result, required this.alreadyAdded});

  final BookSearchResult result;
  final bool alreadyAdded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(bookActionsProvider);

    return ListTile(
      leading: BookCover(url: result.coverUrl()),
      title: Text(result.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        _subtitle(context.l10n, result),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: alreadyAdded
          ? Icon(
              Icons.library_add_check,
              semanticLabel: context.l10n.alreadyInLibrary,
              color: Theme.of(context).colorScheme.primary,
            )
          : const Icon(Icons.add),
      enabled: !busy && !alreadyAdded,
      onTap: () => _add(context, ref),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final shelf = await showShelfPicker(context, bookTitle: result.title);
    if (shelf == null || !context.mounted) {
      return;
    }

    final outcome = await ref
        .read(bookActionsProvider.notifier)
        .addFromSearch(result, shelf);
    if (!context.mounted) {
      return;
    }

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(switch (outcome) {
          ActionSuccess() => shelf.addedMessage(l10n),
          ActionFailure(:final error) => error.describe(l10n),
        }),
      ),
    );
  }

  /// Auteur, année et pages, en sautant ce qu'Open Library ne sait pas.
  static String _subtitle(AppLocalizations l10n, BookSearchResult result) {
    final pageCount = result.pageCount;
    final parts = <String>[
      result.author ?? l10n.unknownAuthor,
      if (result.firstPublishYear != null) '${result.firstPublishYear}',
      if (pageCount != null) l10n.pageCount(pageCount),
    ];
    return parts.join(' · ');
  }
}
