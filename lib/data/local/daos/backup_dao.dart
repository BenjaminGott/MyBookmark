import 'package:drift/drift.dart';

import '../../../domain/models/backup.dart';
import '../../../domain/models/shelf.dart';
import '../app_database.dart';
import '../tables/books.dart';
import '../tables/reading_entries.dart';
import '../tables/tags.dart';

part 'backup_dao.g.dart';

/// Lecture et écriture de la base entière, pour l'export et l'import.
@DriftAccessor(tables: <Type>[Books, ReadingEntries, Tags, BookTags])
class BackupDao extends DatabaseAccessor<AppDatabase> with _$BackupDaoMixin {
  BackupDao(super.attachedDatabase);

  /// Toute la bibliothèque, livres en tête, chacun avec ses lectures et ses
  /// étagères.
  Future<List<BackupBook>> readAllBooks() async {
    final bookRows = await (select(books)
          ..orderBy(<OrderingTerm Function($BooksTable)>[
            ($BooksTable t) => OrderingTerm(expression: t.createdAt),
          ]))
        .get();
    final entryRows = await (select(readingEntries)
          ..orderBy(<OrderingTerm Function($ReadingEntriesTable)>[
            ($ReadingEntriesTable t) => OrderingTerm(expression: t.createdAt),
          ]))
        .get();
    final linkRows = await select(bookTags).get();
    final tagRows = await select(tags).get();

    final tagNames = <int, String>{
      for (final tag in tagRows) tag.id: tag.name,
    };

    final entriesByBook = <int, List<ReadingEntryRow>>{};
    for (final entry in entryRows) {
      entriesByBook.putIfAbsent(entry.bookId, () => <ReadingEntryRow>[]).add(entry);
    }

    final tagsByBook = <int, List<String>>{};
    for (final link in linkRows) {
      final name = tagNames[link.tagId];
      if (name != null) {
        tagsByBook.putIfAbsent(link.bookId, () => <String>[]).add(name);
      }
    }

    return <BackupBook>[
      for (final book in bookRows)
        BackupBook(
          olKey: book.olKey,
          title: book.title,
          author: book.author,
          pageCount: book.pageCount,
          coverId: book.coverId,
          coverUrl: book.coverUrl,
          firstPublishYear: book.firstPublishYear,
          description: book.description,
          isbn: book.isbn,
          isManual: book.isManual,
          createdAt: book.createdAt,
          tags: tagsByBook[book.id] ?? const <String>[],
          readings: <BackupReading>[
            for (final entry in entriesByBook[book.id] ?? const <ReadingEntryRow>[])
              BackupReading(
                shelf: entry.shelf,
                rating: entry.rating,
                review: entry.review,
                startedAt: entry.startedAt,
                finishedAt: entry.finishedAt,
                currentPage: entry.currentPage,
                isCurrent: entry.isCurrent,
                createdAt: entry.createdAt,
              ),
          ],
        ),
    ];
  }

  Future<List<String>> readAllTagNames() async {
    final rows = await select(tags).get();
    return rows.map((TagRow row) => row.name).toList();
  }

  Future<int> countBooks() async {
    final count = countAll();
    final query = selectOnly(books)..addColumns(<Expression<Object>>[count]);
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  /// Les identifiants des livres déjà présents, sous la forme utilisée pour le
  /// dédoublonnage : clé Open Library, ou titre + auteur normalisés.
  Future<Set<String>> readBookIdentities(
    String Function(String title, String? author) manualIdentity,
  ) async {
    final rows = await select(books).get();
    return <String>{
      for (final row in rows)
        row.olKey ?? manualIdentity(row.title, row.author),
    };
  }

  /// Efface toute la bibliothèque. Les lectures et les liens d'étagères
  /// partent en cascade ; les étagères elles-mêmes sont supprimées à part.
  Future<void> deleteEverything() async {
    await transaction(() async {
      await delete(bookTags).go();
      await delete(readingEntries).go();
      await delete(books).go();
      await delete(tags).go();
    });
  }

  /// Insère un livre, ses lectures et ses étagères, en une transaction.
  ///
  /// Renvoie le nombre de lectures réellement insérées.
  Future<int> insertBackupBook(BackupBook book, {required DateTime now}) {
    return transaction(() async {
      final createdAt = book.createdAt ?? now;

      final bookId = await into(books).insert(
        BooksCompanion.insert(
          title: book.title,
          olKey: Value<String?>(book.olKey),
          author: Value<String?>(book.author),
          pageCount: Value<int?>(book.pageCount),
          coverId: Value<int?>(book.coverId),
          coverUrl: Value<String?>(book.coverUrl),
          firstPublishYear: Value<int?>(book.firstPublishYear),
          description: Value<String?>(book.description),
          isbn: Value<String?>(book.isbn),
          isManual: Value<bool>(book.isManual),
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
      );

      final readings = _withSingleCurrent(book.readings);
      for (final reading in readings) {
        final readingCreatedAt = reading.createdAt ?? createdAt;
        await into(readingEntries).insert(
          ReadingEntriesCompanion.insert(
            bookId: bookId,
            shelf: reading.shelf,
            rating: Value<int?>(reading.rating),
            review: Value<String?>(reading.review),
            startedAt: Value<DateTime?>(reading.startedAt),
            finishedAt: Value<DateTime?>(_coherentEnd(reading)),
            currentPage: Value<int>(reading.currentPage),
            isCurrent: Value<bool>(reading.isCurrent),
            createdAt: readingCreatedAt,
            updatedAt: readingCreatedAt,
          ),
        );
      }

      for (final name in book.tags) {
        final tagId = await attachedDatabase.tagsDao.ensureTag(name, now: now);
        await into(bookTags).insert(
          BookTagsCompanion.insert(bookId: bookId, tagId: tagId),
          mode: InsertMode.insertOrIgnore,
        );
      }

      return readings.length;
    });
  }

  /// Garantit l'invariant « une seule lecture courante par livre ».
  ///
  /// Un fichier modifié à la main peut en annoncer zéro ou plusieurs : la
  /// dernière lecture de la liste devient alors la courante.
  static List<BackupReading> _withSingleCurrent(List<BackupReading> readings) {
    if (readings.isEmpty) {
      // Un livre sans lecture n'aurait pas d'étagère : on lui en crée une.
      return const <BackupReading>[
        BackupReading(
          shelf: Shelf.toRead,
          currentPage: 0,
          isCurrent: true,
        ),
      ];
    }

    final currentCount =
        readings.where((reading) => reading.isCurrent).length;
    if (currentCount == 1) {
      return readings;
    }

    return <BackupReading>[
      for (var i = 0; i < readings.length; i++)
        _copyWithCurrent(readings[i], isCurrent: i == readings.length - 1),
    ];
  }

  static BackupReading _copyWithCurrent(
    BackupReading reading, {
    required bool isCurrent,
  }) {
    return BackupReading(
      shelf: reading.shelf,
      rating: reading.rating,
      review: reading.review,
      startedAt: reading.startedAt,
      finishedAt: reading.finishedAt,
      currentPage: reading.currentPage,
      isCurrent: isCurrent,
      createdAt: reading.createdAt,
    );
  }

  /// La base refuse une fin antérieure au début : une telle incohérence dans le
  /// fichier fait perdre la date de fin, pas tout l'import.
  static DateTime? _coherentEnd(BackupReading reading) {
    final start = reading.startedAt;
    final end = reading.finishedAt;
    if (start != null && end != null && end.isBefore(start)) {
      return null;
    }
    return end;
  }
}
