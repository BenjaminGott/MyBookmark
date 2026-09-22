import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/book_search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../widgets/book_cover.dart';
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

    return ListView.separated(
      itemCount: state.results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) =>
          _ResultTile(result: state.results[index]),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.result});

  final BookSearchResult result;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: BookCover(url: result.coverUrl()),
      title: Text(result.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        _subtitle(result),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {},
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
