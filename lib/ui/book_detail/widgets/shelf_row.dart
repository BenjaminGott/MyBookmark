import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/library_item.dart';
import '../../../domain/models/shelf.dart';
import '../../providers/book_actions_controller.dart';
import '../../shelf_labels.dart';

/// L'étagère du livre, changeable d'un geste.
class ShelfRow extends ConsumerWidget {
  const ShelfRow({required this.item, super.key});

  final LibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(bookActionsProvider);

    return SegmentedButton<Shelf>(
      segments: <ButtonSegment<Shelf>>[
        for (final shelf in Shelf.values)
          ButtonSegment<Shelf>(
            value: shelf,
            icon: Icon(shelf.icon),
            label: Text(shelf.label),
          ),
      ],
      selected: <Shelf>{item.shelf},
      showSelectedIcon: false,
      onSelectionChanged:
          busy ? null : (selection) => _move(context, ref, selection.first),
    );
  }

  Future<void> _move(BuildContext context, WidgetRef ref, Shelf shelf) async {
    final outcome = await ref.read(bookActionsProvider.notifier).moveToShelf(
          entryId: item.currentEntry.id,
          shelf: shelf,
        );
    if (!context.mounted || outcome is ActionSuccess) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text((outcome as ActionFailure).message)),
    );
  }
}
