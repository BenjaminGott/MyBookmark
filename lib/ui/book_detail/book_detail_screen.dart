import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/failure.dart';
import '../../domain/models/library_item.dart';
import '../../domain/models/shelf.dart';
import '../book_form/book_form_screen.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../providers/book_actions_controller.dart';
import '../providers/book_providers.dart';
import '../share/open_progress_sharing.dart';
import '../widgets/status_views.dart';
import 'widgets/book_header.dart';
import 'widgets/dates_card.dart';
import 'widgets/description_card.dart';
import 'widgets/progress_card.dart';
import 'widgets/rating_card.dart';
import 'widgets/reading_history_card.dart';
import 'widgets/shelf_row.dart';

/// La fiche d'un livre : métadonnées, note, avis, dates et progression.
class BookDetailScreen extends ConsumerWidget {
  const BookDetailScreen({required this.bookId, super.key});

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(bookProvider(bookId));
    final item = book.value;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[if (item != null) _BookMenu(item: item)],
      ),
      body: book.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error is AppException
              ? error
              : const StorageException(AppErrorReason.bookReadFailed),
        ),
        data: (item) {
          if (item == null) {
            // Le livre vient d'être supprimé, ici ou depuis un autre écran.
            return EmptyState(
              icon: Icons.delete_outline,
              title: context.l10n.bookDeletedTitle,
              message: context.l10n.bookDeletedMessage,
            );
          }
          return _BookDetail(item: item);
        },
      ),
    );
  }
}

class _BookDetail extends StatelessWidget {
  const _BookDetail({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: <Widget>[
        BookHeader(item: item),
        const SizedBox(height: 24),
        ShelfRow(item: item),
        const SizedBox(height: 16),
        // Un livre pas encore commencé n'a pas de progression à saisir.
        if (item.shelf != Shelf.toRead) ...<Widget>[
          ProgressCard(item: item),
          const SizedBox(height: 16),
        ],
        RatingCard(item: item),
        const SizedBox(height: 16),
        DatesCard(item: item),
        const SizedBox(height: 16),
        DescriptionCard(book: item.book),
        const SizedBox(height: 16),
        ReadingHistoryCard(bookId: item.book.id),
      ],
    );
  }
}

class _BookMenu extends ConsumerWidget {
  const _BookMenu({required this.item});

  final LibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(bookActionsProvider);

    return PopupMenuButton<_BookMenuAction>(
      tooltip: context.l10n.actionsTooltip,
      enabled: !busy,
      onSelected: (action) => _handle(context, ref, action),
      itemBuilder: (context) => <PopupMenuEntry<_BookMenuAction>>[
        PopupMenuItem<_BookMenuAction>(
          value: _BookMenuAction.share,
          child: Text(context.l10n.shareProgress),
        ),
        PopupMenuItem<_BookMenuAction>(
          value: _BookMenuAction.edit,
          child: Text(context.l10n.editBookDetails),
        ),
        PopupMenuItem<_BookMenuAction>(
          value: _BookMenuAction.reread,
          child: Text(context.l10n.startReread),
        ),
        PopupMenuItem<_BookMenuAction>(
          value: _BookMenuAction.delete,
          child: Text(context.l10n.removeFromLibrary),
        ),
      ],
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _BookMenuAction action,
  ) async {
    switch (action) {
      case _BookMenuAction.share:
        await openProgressSharing(context, item);
      case _BookMenuAction.edit:
        await openBookEditor(context, ref, bookId: item.book.id);
      case _BookMenuAction.reread:
        await _startReread(context, ref);
      case _BookMenuAction.delete:
        await _confirmDelete(context, ref);
    }
  }

  Future<void> _startReread(BuildContext context, WidgetRef ref) async {
    final outcome =
        await ref.read(bookActionsProvider.notifier).startReread(item.book.id);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          switch (outcome) {
            ActionSuccess() => context.l10n.rereadStarted,
            ActionFailure(:final error) => error.describe(context.l10n),
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.deleteBookTitle),
        content: Text(context.l10n.deleteBookMessage(item.book.title)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final outcome =
        await ref.read(bookActionsProvider.notifier).deleteBook(item.book.id);
    if (!context.mounted) {
      return;
    }

    switch (outcome) {
      case ActionSuccess():
        // La fiche n'a plus de sujet : on revient à la bibliothèque.
        Navigator.of(context).pop();
      case ActionFailure(:final error):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.describe(context.l10n))),
        );
    }
  }
}

enum _BookMenuAction { share, edit, reread, delete }
