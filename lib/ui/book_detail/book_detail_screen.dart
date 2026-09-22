import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/failure.dart';
import '../../domain/models/library_item.dart';
import '../../domain/models/shelf.dart';
import '../book_form/book_form_screen.dart';
import '../providers/book_actions_controller.dart';
import '../providers/book_providers.dart';
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
              : const StorageException('Lecture du livre impossible.'),
        ),
        data: (item) {
          if (item == null) {
            // Le livre vient d'être supprimé, ici ou depuis un autre écran.
            return const EmptyState(
              icon: Icons.delete_outline,
              title: 'Livre supprimé',
              message: 'Ce livre n\'est plus dans votre bibliothèque.',
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
      tooltip: 'Actions',
      enabled: !busy,
      onSelected: (action) => _handle(context, ref, action),
      itemBuilder: (context) => const <PopupMenuEntry<_BookMenuAction>>[
        PopupMenuItem<_BookMenuAction>(
          value: _BookMenuAction.edit,
          child: Text('Corriger les informations'),
        ),
        PopupMenuItem<_BookMenuAction>(
          value: _BookMenuAction.reread,
          child: Text('Commencer une relecture'),
        ),
        PopupMenuItem<_BookMenuAction>(
          value: _BookMenuAction.delete,
          child: Text('Supprimer de ma bibliothèque'),
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
            ActionSuccess() => 'Relecture commencée. La lecture précédente '
                'reste dans l\'historique.',
            ActionFailure(message: final message) => message,
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce livre ?'),
        content: Text(
          '« ${item.book.title} » sera retiré de votre bibliothèque, avec sa '
          'note, son avis et tout son historique de lecture. '
          'C\'est définitif.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
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
      case ActionFailure(message: final message):
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

enum _BookMenuAction { edit, reread, delete }
