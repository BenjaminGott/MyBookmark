import 'package:flutter/material.dart';

import '../../../domain/models/library_item.dart';
import '../../l10n/l10n.dart';
import '../../widgets/book_cover.dart';

/// Grande couverture, titre, auteur et métadonnées du livre.
class BookHeader extends StatelessWidget {
  const BookHeader({required this.item, super.key});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = item.book;
    final l10n = context.l10n;
    final pageCount = book.pageCount;

    final details = <String>[
      if (book.firstPublishYear != null) '${book.firstPublishYear}',
      pageCount == null || pageCount <= 0
          ? l10n.pageCountUnknown
          : l10n.pageCount(pageCount),
      if (book.isManual) l10n.enteredManually,
    ];

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: BookCover(
            url: book.coverUrl,
            width: 160,
            height: 240,
            borderRadius: 12,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          book.title,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          book.author ?? l10n.unknownAuthor,
          style: theme.textTheme.titleMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          details.join(' · '),
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
