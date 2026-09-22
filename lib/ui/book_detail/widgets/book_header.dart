import 'package:flutter/material.dart';

import '../../../core/formatters.dart';
import '../../../domain/models/library_item.dart';
import '../../widgets/book_cover.dart';

/// Grande couverture, titre, auteur et métadonnées du livre.
class BookHeader extends StatelessWidget {
  const BookHeader({required this.item, super.key});

  final LibraryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final book = item.book;

    final details = <String>[
      if (book.firstPublishYear != null) '${book.firstPublishYear}',
      Formatters.pages(book.pageCount),
      if (book.isManual) 'Saisi à la main',
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
          book.author ?? 'Auteur inconnu',
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
