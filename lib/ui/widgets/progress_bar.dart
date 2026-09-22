import 'package:flutter/material.dart';

import '../../domain/services/reading_progress.dart';

/// Avancement d'une lecture : barre et pourcentage calculés sur le nombre de
/// pages du livre.
///
/// Quand ce nombre est inconnu, il n'y a pas de barre — juste la page en cours.
/// Une barre à zéro laisserait croire que le livre n'est pas commencé.
class ReadingProgressBar extends StatelessWidget {
  const ReadingProgressBar({
    required this.currentPage,
    required this.pageCount,
    super.key,
    this.compact = false,
  });

  final int currentPage;
  final int? pageCount;

  /// Version réduite pour les listes : une ligne, sans libellé de pages.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction =
        ReadingProgress.fraction(currentPage: currentPage, pageCount: pageCount);
    final percent =
        ReadingProgress.percent(currentPage: currentPage, pageCount: pageCount);

    if (fraction == null) {
      return Text(
        currentPage > 0
            ? 'Page $currentPage · nombre de pages inconnu'
            : 'Nombre de pages inconnu',
        style: theme.textTheme.bodySmall
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      );
    }

    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: fraction,
        minHeight: compact ? 4 : 8,
      ),
    );

    if (compact) {
      return Row(
        children: <Widget>[
          Expanded(child: bar),
          const SizedBox(width: 8),
          Text('$percent %', style: theme.textTheme.labelSmall),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        bar,
        const SizedBox(height: 6),
        Text(
          'Page $currentPage sur $pageCount · $percent %',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
