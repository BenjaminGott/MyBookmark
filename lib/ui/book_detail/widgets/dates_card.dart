import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/formatters.dart';
import '../../../domain/models/library_item.dart';
import '../../providers/book_actions_controller.dart';
import 'section_card.dart';

/// Dates de début et de fin de la lecture en cours.
class DatesCard extends ConsumerWidget {
  const DatesCard({required this.item, super.key});

  final LibraryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(bookActionsProvider);
    final entry = item.currentEntry;

    return SectionCard(
      title: 'Dates de lecture',
      child: Column(
        children: <Widget>[
          _DateTile(
            label: 'Commencé le',
            date: entry.startedAt,
            enabled: !busy,
            onPick: () => _pick(context, ref, isStart: true),
            onClear: entry.startedAt == null
                ? null
                : () => _write(context, ref, startedAt: null,
                    finishedAt: entry.finishedAt),
          ),
          const Divider(),
          _DateTile(
            label: 'Terminé le',
            date: entry.finishedAt,
            enabled: !busy,
            onPick: () => _pick(context, ref, isStart: false),
            onClear: entry.finishedAt == null
                ? null
                : () => _write(context, ref,
                    startedAt: entry.startedAt, finishedAt: null),
          ),
        ],
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref, {
    required bool isStart,
  }) async {
    final entry = item.currentEntry;
    final initial =
        (isStart ? entry.startedAt : entry.finishedAt) ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: isStart ? 'Début de lecture' : 'Fin de lecture',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );
    if (picked == null || !context.mounted) {
      return;
    }

    await _write(
      context,
      ref,
      startedAt: isStart ? picked : entry.startedAt,
      finishedAt: isStart ? entry.finishedAt : picked,
    );
  }

  Future<void> _write(
    BuildContext context,
    WidgetRef ref, {
    required DateTime? startedAt,
    required DateTime? finishedAt,
  }) async {
    // La base refuse une fin antérieure au début : autant le dire avant.
    if (startedAt != null &&
        finishedAt != null &&
        finishedAt.isBefore(startedAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La date de fin ne peut pas précéder la date de début.',
          ),
        ),
      );
      return;
    }

    final outcome = await ref.read(bookActionsProvider.notifier).setDates(
          entryId: item.currentEntry.id,
          startedAt: startedAt,
          finishedAt: finishedAt,
        );
    if (!context.mounted || outcome is ActionSuccess) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text((outcome as ActionFailure).message)),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
    required this.enabled,
    required this.onPick,
    this.onClear,
  });

  final String label;
  final DateTime? date;
  final bool enabled;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event),
      title: Text(label),
      subtitle: Text(Formatters.longDate(date) ?? 'Pas renseignée'),
      trailing: onClear == null
          ? null
          : IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Effacer la date',
              onPressed: enabled ? onClear : null,
            ),
      onTap: enabled ? onPick : null,
    );
  }
}
