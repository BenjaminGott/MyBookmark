import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/book_search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../providers/book_actions_controller.dart';
import '../providers/book_providers.dart';
import '../shelf_labels.dart';
import '../widgets/book_cover.dart';
import '../widgets/shelf_picker.dart';
import '../widgets/status_views.dart';
import 'search_controller.dart';
import 'search_state.dart';

/// Recherche de livres dans Open Library, avec autocomplétion.
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);
    final controller = ref.read(searchControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Chercher un livre')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _field,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: controller.onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Titre ou auteur',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _field.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Effacer',
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
        title: 'Cherchez un livre',
        message: state.query.trim().isEmpty
            ? 'Tapez un titre ou un nom d\'auteur.'
            : 'Encore $kMinQueryLength caractères minimum.',
      );
    }

    if (state.hasNoResult) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Aucun résultat',
        message: 'Open Library ne connaît pas ce titre. '
            'Vérifiez l\'orthographe, ou ajoutez le livre à la main.',
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
        _subtitle(result),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: alreadyAdded
          ? Icon(
              Icons.library_add_check,
              semanticLabel: 'Déjà dans votre bibliothèque',
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

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          switch (outcome) {
            ActionSuccess() => shelf.addedMessage,
            ActionFailure(message: final message) => message,
          },
        ),
      ),
    );
  }

  /// Auteur, année et pages, en sautant ce qu'Open Library ne sait pas.
  static String _subtitle(BookSearchResult result) {
    final parts = <String>[
      result.author ?? 'Auteur inconnu',
      if (result.firstPublishYear != null) '${result.firstPublishYear}',
      if (result.pageCount != null) '${result.pageCount} pages',
    ];
    return parts.join(' · ');
  }
}
