import 'package:flutter/material.dart';

import '../../../domain/models/book.dart';
import '../../l10n/l10n.dart';
import 'section_card.dart';

/// Le résumé du livre, recopié en base à l'ajout.
///
/// Les résumés d'Open Library sont parfois très longs : le texte est replié
/// au-delà de quelques lignes, avec un bouton pour tout lire.
class DescriptionCard extends StatefulWidget {
  const DescriptionCard({required this.book, super.key});

  final Book book;

  @override
  State<DescriptionCard> createState() => _DescriptionCardState();
}

class _DescriptionCardState extends State<DescriptionCard> {
  static const int _foldedLines = 6;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = widget.book.description;

    if (description == null || description.isEmpty) {
      return SectionCard(
        title: context.l10n.summary,
        child: Text(
          widget.book.isManual
              ? context.l10n.noSummaryManual
              : context.l10n.noSummaryOnline,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    return SectionCard(
      title: context.l10n.summary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            description,
            maxLines: _expanded ? null : _foldedLines,
            overflow: _expanded ? null : TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(
                _expanded ? context.l10n.showLess : context.l10n.readMore,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
