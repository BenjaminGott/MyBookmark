import '../../domain/models/book.dart';
import '../../domain/models/reading_entry.dart';
import '../../domain/models/tag.dart';
import 'app_database.dart';

/// Conversions entre les lignes drift et les modèles du domaine.
///
/// Elles sont regroupées ici pour que la couche `domain` n'ait jamais à
/// connaître drift, et pour qu'un changement de schéma se rattrape en un point.
extension BookRowMapper on BookRow {
  Book toDomain() => Book(
        id: id,
        olKey: olKey,
        title: title,
        author: author,
        pageCount: pageCount,
        coverId: coverId,
        coverUrl: coverUrl,
        firstPublishYear: firstPublishYear,
        description: description,
        isbn: isbn,
        isManual: isManual,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension ReadingEntryRowMapper on ReadingEntryRow {
  ReadingEntry toDomain() => ReadingEntry(
        id: id,
        bookId: bookId,
        shelf: shelf,
        rating: rating,
        review: review,
        startedAt: startedAt,
        finishedAt: finishedAt,
        currentPage: currentPage,
        isCurrent: isCurrent,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension TagRowMapper on TagRow {
  Tag toDomain() => Tag(
        id: id,
        name: name,
        color: color,
        createdAt: createdAt,
      );
}
