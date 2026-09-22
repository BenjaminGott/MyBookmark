import 'package:drift/drift.dart';

import '../../../domain/models/reading_entry.dart';
import '../../../domain/models/shelf.dart';
import '../../../domain/services/reading_progress.dart';
import '../app_database.dart';
import '../mappers.dart';
import '../tables/books.dart';
import '../tables/reading_entries.dart';

part 'reading_entries_dao.g.dart';

@DriftAccessor(tables: <Type>[Books, ReadingEntries])
class ReadingEntriesDao extends DatabaseAccessor<AppDatabase>
    with _$ReadingEntriesDaoMixin {
  ReadingEntriesDao(super.attachedDatabase);

  /// Toutes les lectures d'un livre, la plus récente d'abord.
  ///
  /// La lecture en cours est toujours en tête ; les précédentes gardent leur
  /// note, leur avis et leurs dates.
  Stream<List<ReadingEntry>> watchEntriesForBook(int bookId) {
    final select = this.select(readingEntries)
      ..where(($ReadingEntriesTable t) => t.bookId.equals(bookId))
      ..orderBy(<OrderingTerm Function($ReadingEntriesTable)>[
        ($ReadingEntriesTable t) =>
            OrderingTerm(expression: t.isCurrent, mode: OrderingMode.desc),
        ($ReadingEntriesTable t) =>
            OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);
    return select.watch().map(
          (List<ReadingEntryRow> rows) =>
              rows.map((ReadingEntryRow row) => row.toDomain()).toList(),
        );
  }

  Future<ReadingEntry?> findCurrentEntry(int bookId) async {
    final row = await (select(readingEntries)
          ..where(($ReadingEntriesTable t) =>
              t.bookId.equals(bookId) & t.isCurrent.equals(true)))
        .getSingleOrNull();
    return row?.toDomain();
  }

  /// Déplace un livre vers une autre étagère.
  ///
  /// Les dates suivent le geste : passer en « en cours » date le début si
  /// personne ne l'a fait, passer en « lu » date la fin et cale la page
  /// courante sur la dernière page. Aucune date déjà saisie n'est écrasée.
  Future<void> moveToShelf({
    required int entryId,
    required Shelf shelf,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();

    await transaction(() async {
      final entry = await (select(readingEntries)
            ..where(($ReadingEntriesTable t) => t.id.equals(entryId)))
          .getSingleOrNull();
      if (entry == null) {
        return;
      }

      final book = await (select(books)
            ..where(($BooksTable t) => t.id.equals(entry.bookId)))
          .getSingleOrNull();

      var startedAt = Value<DateTime?>.absent();
      var finishedAt = Value<DateTime?>.absent();
      var currentPage = const Value<int>.absent();

      switch (shelf) {
        case Shelf.toRead:
          break;
        case Shelf.reading:
          if (entry.startedAt == null) {
            startedAt = Value<DateTime?>(timestamp);
          }
        case Shelf.read:
          if (entry.startedAt == null) {
            startedAt = Value<DateTime?>(timestamp);
          }
          if (entry.finishedAt == null) {
            finishedAt = Value<DateTime?>(timestamp);
          }
          final pageCount = book?.pageCount;
          if (pageCount != null && pageCount > 0) {
            currentPage = Value<int>(pageCount);
          }
      }

      await (update(readingEntries)
            ..where(($ReadingEntriesTable t) => t.id.equals(entryId)))
          .write(
        ReadingEntriesCompanion(
          shelf: Value<Shelf>(shelf),
          startedAt: startedAt,
          finishedAt: finishedAt,
          currentPage: currentPage,
          updatedAt: Value<DateTime>(timestamp),
        ),
      );
    });
  }

  /// Enregistre la page en cours, en la ramenant dans les bornes du livre.
  Future<void> updateCurrentPage({
    required int entryId,
    required int page,
    DateTime? now,
  }) async {
    final timestamp = now ?? DateTime.now();

    await transaction(() async {
      final entry = await (select(readingEntries)
            ..where(($ReadingEntriesTable t) => t.id.equals(entryId)))
          .getSingleOrNull();
      if (entry == null) {
        return;
      }

      final book = await (select(books)
            ..where(($BooksTable t) => t.id.equals(entry.bookId)))
          .getSingleOrNull();

      final clamped =
          ReadingProgress.clampPage(page: page, pageCount: book?.pageCount);

      await (update(readingEntries)
            ..where(($ReadingEntriesTable t) => t.id.equals(entryId)))
          .write(
        ReadingEntriesCompanion(
          currentPage: Value<int>(clamped),
          updatedAt: Value<DateTime>(timestamp),
        ),
      );
    });
  }

  /// Met à jour la note, l'avis ou les dates d'une lecture.
  ///
  /// Chaque paramètre omis est laissé intact ; passer `Value(null)` efface.
  Future<void> updateEntry(
    int entryId, {
    Value<int?> rating = const Value<int?>.absent(),
    Value<String?> review = const Value<String?>.absent(),
    Value<DateTime?> startedAt = const Value<DateTime?>.absent(),
    Value<DateTime?> finishedAt = const Value<DateTime?>.absent(),
    DateTime? now,
  }) async {
    await (update(readingEntries)
          ..where(($ReadingEntriesTable t) => t.id.equals(entryId)))
        .write(
      ReadingEntriesCompanion(
        rating: rating,
        review: review,
        startedAt: startedAt,
        finishedAt: finishedAt,
        updatedAt: Value<DateTime>(now ?? DateTime.now()),
      ),
    );
  }

  /// Démarre une relecture : l'entrée courante est archivée telle quelle et une
  /// nouvelle prend sa place sur l'étagère « en cours ».
  Future<int> startReread({required int bookId, DateTime? now}) {
    final timestamp = now ?? DateTime.now();

    return transaction(() async {
      await (update(readingEntries)
            ..where(($ReadingEntriesTable t) =>
                t.bookId.equals(bookId) & t.isCurrent.equals(true)))
          .write(
        ReadingEntriesCompanion(
          isCurrent: const Value<bool>(false),
          updatedAt: Value<DateTime>(timestamp),
        ),
      );

      return into(readingEntries).insert(
        ReadingEntriesCompanion.insert(
          bookId: bookId,
          shelf: Shelf.reading,
          startedAt: Value<DateTime?>(timestamp),
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );
    });
  }

  /// Supprime une lecture archivée. L'entrée courante ne peut pas être
  /// supprimée : un livre garde toujours au moins une lecture.
  Future<bool> deleteArchivedEntry(int entryId) async {
    final deleted = await (delete(readingEntries)
          ..where(($ReadingEntriesTable t) =>
              t.id.equals(entryId) & t.isCurrent.equals(false)))
        .go();
    return deleted > 0;
  }
}
