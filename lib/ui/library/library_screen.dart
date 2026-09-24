import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/failure.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/library_item.dart';
import '../../domain/models/library_query.dart';
import '../../domain/models/shelf.dart';
import '../book_form/book_form_screen.dart';
import '../l10n/l10n.dart';
import '../shelf_labels.dart';
import '../widgets/book_cover.dart';
import '../widgets/progress_bar.dart';
import '../widgets/star_rating.dart';
import '../widgets/status_views.dart';
import 'library_query_controller.dart';

/// « Ma bibliothèque » : la liste locale, filtrable et triable.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key, this.onOpenSearch, this.onOpenBook});

  /// Appelé par l'état vide, pour envoyer l'utilisateur chercher un livre.
  final VoidCallback? onOpenSearch;

  final void Function(int bookId)? onOpenBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(libraryQueryProvider);
    final library = ref.watch(currentLibraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            // Décoratif : le titre suffit aux lecteurs d'écran. Le fond vert
            // de l'icône le garde lisible sur le thème clair.
            ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image.asset('assets/logo.png', width: 30, height: 30),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(child: Text(context.l10n.libraryTitle)),
          ],
        ),
        actions: <Widget>[_SortButton(query: query)],
        bottom: _ShelfFilterBar(query: query),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openManualBookForm(context),
        icon: const Icon(Icons.edit_outlined),
        label: Text(context.l10n.addBookManually),
        tooltip: context.l10n.addBookManuallyTooltip,
      ),
      body: library.when(
        // Un changement de filtre garde la liste à l'écran le temps de la
        // nouvelle requête.
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error is AppException
              ? error
              : const StorageException(AppErrorReason.libraryReadFailed),
        ),
        data: (items) => items.isEmpty
            ? _EmptyLibrary(query: query, onOpenSearch: onOpenSearch)
            : _LibraryList(items: items, onOpenBook: onOpenBook),
      ),
    );
  }
}

class _ShelfFilterBar extends ConsumerWidget implements PreferredSizeWidget {
  const _ShelfFilterBar({required this.query});

  final LibraryQuery query;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(libraryQueryProvider.notifier);

    return SizedBox(
      height: preferredSize.height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: FilterChip(
              // Le fond jaune dit la sélection ; une coche viendrait
              // recouvrir l'icône des étagères.
              showCheckmark: false,
              label: Text(context.l10n.filterAll),
              selected: query.shelf == null,
              onSelected: (_) => controller.filterByShelf(null),
            ),
          ),
          for (final shelf in Shelf.values)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: FilterChip(
                showCheckmark: false,
                avatar: Icon(shelf.icon, size: 18),
                label: Text(shelf.label(context.l10n)),
                selected: query.shelf == shelf,
                onSelected: (selected) =>
                    controller.filterByShelf(selected ? shelf : null),
              ),
            ),
        ],
      ),
    );
  }
}

class _SortButton extends ConsumerWidget {
  const _SortButton({required this.query});

  final LibraryQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<LibrarySort>(
      icon: const Icon(Icons.sort),
      tooltip: context.l10n.sortTooltip,
      onSelected: ref.read(libraryQueryProvider.notifier).sortBy,
      itemBuilder: (context) => <PopupMenuEntry<LibrarySort>>[
        for (final sort in LibrarySort.values)
          PopupMenuItem<LibrarySort>(
            value: sort,
            child: Row(
              children: <Widget>[
                Expanded(child: Text(sort.label(context.l10n))),
                if (query.sort == sort)
                  Icon(
                    query.descending
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    size: 18,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LibraryList extends StatelessWidget {
  const _LibraryList({required this.items, required this.onOpenBook});

  final List<LibraryItem> items;
  final void Function(int bookId)? onOpenBook;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return _LibraryTile(
          item: item,
          onTap: onOpenBook == null ? null : () => onOpenBook!(item.book.id),
        );
      },
    );
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({required this.item, this.onTap});

  final LibraryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = item.book;

    return ListTile(
      leading: BookCover(url: book.coverUrl, width: 44, height: 66),
      title: Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      isThreeLine: true,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            book.author ?? context.l10n.unknownAuthor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          switch (item.shelf) {
            Shelf.reading => ReadingProgressBar(
                currentPage: item.currentEntry.currentPage,
                pageCount: book.pageCount,
                compact: true,
              ),
            Shelf.read => item.rating == null
                ? Text(
                    context.l10n.readNotRated,
                    style: theme.textTheme.labelSmall,
                  )
                : StarRating(rating: item.rating, size: 16),
            Shelf.toRead => Text(
                book.hasKnownPageCount
                    ? context.l10n.toReadWithPages(book.pageCount!)
                    : context.l10n.shelfToRead,
                style: theme.textTheme.labelSmall,
              ),
          },
        ],
      ),
      onTap: onTap,
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.query, this.onOpenSearch});

  final LibraryQuery query;
  final VoidCallback? onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final shelf = query.shelf;

    // Filtre actif : la bibliothèque n'est pas forcément vide, c'est l'étagère
    // qui l'est. Le message doit faire la différence.
    if (shelf != null) {
      return EmptyState(
        icon: shelf.icon,
        title: context.l10n.emptyShelfTitle(shelf.label(context.l10n)),
        message: context.l10n.emptyShelfMessage,
      );
    }

    return EmptyState(
      icon: Icons.library_books_outlined,
      title: context.l10n.emptyLibraryTitle,
      message: context.l10n.emptyLibraryMessage,
      action: onOpenSearch == null
          ? null
          : FilledButton.icon(
              onPressed: onOpenSearch,
              icon: const Icon(Icons.search),
              label: Text(context.l10n.searchABook),
            ),
    );
  }
}
