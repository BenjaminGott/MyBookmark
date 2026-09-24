import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/reading_entry.dart';
import '../../l10n/l10n.dart';
import '../../providers/book_providers.dart';
import '../../shelf_labels.dart';
import '../../widgets/star_rating.dart';
import 'section_card.dart';

/// Les lectures passées du livre, avec la note et l'avis de chacune.
///
/// La carte disparaît tant qu'il n'y a qu'une seule lecture : il n'y a alors
/// pas d'historique à raconter.
class ReadingHistoryCard extends ConsumerWidget {
  const ReadingHistoryCard({required this.bookId, super.key});

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(bookEntriesProvider(bookId)).value;
    if (entries == null || entries.length < 2) {
      return const SizedBox.shrink();
    }

    final past = entries.where((entry) => !entry.isCurrent).toList();

    return SectionCard(
      title: context.l10n.previousReadings(past.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final entry in past) _PastEntry(entry: entry),
        ],
      ),
    );
  }
}

class _PastEntry extends StatelessWidget {
  const _PastEntry({required this.entry});

  final ReadingEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final startedAt = entry.startedAt;
    final finishedAt = entry.finishedAt;
    final period = <String>[
      if (startedAt != null) l10n.historyFrom(startedAt),
      if (finishedAt != null) l10n.historyTo(finishedAt),
    ].join(' ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(entry.shelf.icon, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  period.isEmpty ? l10n.datesNotSet : period,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              if (entry.isRated) StarRating(rating: entry.rating, size: 14),
            ],
          ),
          if (entry.hasReview) ...<Widget>[
            const SizedBox(height: 4),
            Text(entry.review!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
