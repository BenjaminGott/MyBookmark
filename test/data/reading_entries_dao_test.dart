import 'package:biblivre/data/local/app_database.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> addDune({int? pageCount = 658, Shelf shelf = Shelf.toRead}) {
    return db.booksDao.addBook(
      title: 'Dune',
      author: 'Frank Herbert',
      pageCount: pageCount,
      shelf: shelf,
      now: DateTime(2026, 1, 1),
    );
  }

  Future<int> currentEntryId(int bookId) async {
    final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
    return entry!.id;
  }

  group('moveToShelf', () {
    test('date le début au passage en lecture', () async {
      final bookId = await addDune();
      final entryId = await currentEntryId(bookId);

      await db.readingEntriesDao.moveToShelf(
        entryId: entryId,
        shelf: Shelf.reading,
        now: DateTime(2026, 4, 2),
      );

      final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      expect(entry!.shelf, Shelf.reading);
      expect(entry.startedAt, DateTime(2026, 4, 2));
      expect(entry.finishedAt, isNull);
    });

    test('date la fin et cale la page sur la dernière au passage en lu',
        () async {
      final bookId = await addDune();
      final entryId = await currentEntryId(bookId);

      await db.readingEntriesDao.moveToShelf(
        entryId: entryId,
        shelf: Shelf.read,
        now: DateTime(2026, 4, 20),
      );

      final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      expect(entry!.shelf, Shelf.read);
      expect(entry.finishedAt, DateTime(2026, 4, 20));
      expect(entry.currentPage, 658);
    });

    test('laisse la page à zéro si le nombre de pages est inconnu', () async {
      final bookId = await addDune(pageCount: null);
      final entryId = await currentEntryId(bookId);

      await db.readingEntriesDao
          .moveToShelf(entryId: entryId, shelf: Shelf.read);

      final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      expect(entry!.currentPage, 0);
    });

    test("n'écrase pas une date déjà saisie", () async {
      final bookId = await addDune();
      final entryId = await currentEntryId(bookId);
      await db.readingEntriesDao.updateEntry(
        entryId,
        startedAt: Value<DateTime?>(DateTime(2025, 12, 24)),
      );

      await db.readingEntriesDao.moveToShelf(
        entryId: entryId,
        shelf: Shelf.reading,
        now: DateTime(2026, 4, 2),
      );

      final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      expect(entry!.startedAt, DateTime(2025, 12, 24));
    });

    test('ne date rien au retour sur « à lire »', () async {
      final bookId = await addDune();
      final entryId = await currentEntryId(bookId);

      await db.readingEntriesDao
          .moveToShelf(entryId: entryId, shelf: Shelf.toRead);

      final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      expect(entry!.shelf, Shelf.toRead);
      expect(entry.startedAt, isNull);
      expect(entry.finishedAt, isNull);
    });
  });

  group('updateCurrentPage', () {
    test('enregistre la page saisie', () async {
      final bookId = await addDune();
      final entryId = await currentEntryId(bookId);

      await db.readingEntriesDao.updateCurrentPage(entryId: entryId, page: 120);

      final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      expect(entry!.currentPage, 120);
    });

    test('plafonne au nombre de pages du livre', () async {
      final bookId = await addDune();
      final entryId = await currentEntryId(bookId);

      await db.readingEntriesDao.updateCurrentPage(entryId: entryId, page: 5000);

      final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      expect(entry!.currentPage, 658);
    });

    test('ramène une page négative à zéro', () async {
      final bookId = await addDune();
      final entryId = await currentEntryId(bookId);

      await db.readingEntriesDao.updateCurrentPage(entryId: entryId, page: -10);

      final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      expect(entry!.currentPage, 0);
    });

    test('accepte n\'importe quelle page si le total est inconnu', () async {
      final bookId = await addDune(pageCount: null);
      final entryId = await currentEntryId(bookId);

      await db.readingEntriesDao.updateCurrentPage(entryId: entryId, page: 4200);

      final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      expect(entry!.currentPage, 4200);
    });
  });

  group('note et avis', () {
    test('accepte une note seule, un avis seul, ou les deux', () async {
      final bookId = await addDune();
      final entryId = await currentEntryId(bookId);

      await db.readingEntriesDao
          .updateEntry(entryId, rating: const Value<int?>(5));
      var entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      expect(entry!.rating, 5);
      expect(entry.hasReview, isFalse);

      await db.readingEntriesDao.updateEntry(
        entryId,
        review: const Value<String?>('Un monument.'),
      );
      entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      expect(entry!.rating, 5);
      expect(entry.review, 'Un monument.');
      expect(entry.isRated, isTrue);
    });

    test('efface la note sans toucher à l\'avis', () async {
      final bookId = await addDune();
      final entryId = await currentEntryId(bookId);
      await db.readingEntriesDao.updateEntry(
        entryId,
        rating: const Value<int?>(3),
        review: const Value<String?>('Mitigé.'),
      );

      await db.readingEntriesDao
          .updateEntry(entryId, rating: const Value<int?>(null));

      final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      expect(entry!.rating, isNull);
      expect(entry.review, 'Mitigé.');
    });

    test('refuse une note hors de 1 à 5', () async {
      final bookId = await addDune();
      final entryId = await currentEntryId(bookId);

      await expectLater(
        db.readingEntriesDao.updateEntry(entryId, rating: const Value<int?>(6)),
        throwsA(isA<SqliteException>()),
      );
      await expectLater(
        db.readingEntriesDao.updateEntry(entryId, rating: const Value<int?>(0)),
        throwsA(isA<SqliteException>()),
      );
    });

    test('refuse une fin de lecture antérieure au début', () async {
      final bookId = await addDune();
      final entryId = await currentEntryId(bookId);

      await expectLater(
        db.readingEntriesDao.updateEntry(
          entryId,
          startedAt: Value<DateTime?>(DateTime(2026, 5, 10)),
          finishedAt: Value<DateTime?>(DateTime(2026, 5, 1)),
        ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('relecture', () {
    test('archive la lecture précédente et en ouvre une neuve', () async {
      final bookId = await addDune(shelf: Shelf.read);
      final firstId = await currentEntryId(bookId);
      await db.readingEntriesDao.updateEntry(
        firstId,
        rating: const Value<int?>(4),
        review: const Value<String?>('Lu à 20 ans.'),
      );

      final secondId = await db.readingEntriesDao
          .startReread(bookId: bookId, now: DateTime(2026, 9, 1));

      final entries =
          await db.readingEntriesDao.watchEntriesForBook(bookId).first;
      expect(entries, hasLength(2));

      // La lecture en cours arrive en tête.
      expect(entries.first.id, secondId);
      expect(entries.first.isCurrent, isTrue);
      expect(entries.first.shelf, Shelf.reading);
      expect(entries.first.startedAt, DateTime(2026, 9, 1));
      expect(entries.first.rating, isNull);

      // L'ancienne garde sa note et son avis.
      final archived = entries.last;
      expect(archived.id, firstId);
      expect(archived.isCurrent, isFalse);
      expect(archived.shelf, Shelf.read);
      expect(archived.rating, 4);
      expect(archived.review, 'Lu à 20 ans.');
    });

    test('un livre n\'a jamais qu\'une seule lecture courante', () async {
      final bookId = await addDune(shelf: Shelf.read);
      await db.readingEntriesDao.startReread(bookId: bookId);
      await db.readingEntriesDao.startReread(bookId: bookId);

      final entries =
          await db.readingEntriesDao.watchEntriesForBook(bookId).first;
      expect(entries, hasLength(3));
      expect(entries.where((entry) => entry.isCurrent), hasLength(1));
    });

    test('la bibliothèque affiche l\'étagère de la lecture courante', () async {
      final bookId = await addDune(shelf: Shelf.read);
      await db.readingEntriesDao.startReread(bookId: bookId);

      final items = await db.booksDao.watchLibrary().first;
      expect(items, hasLength(1), reason: 'le livre ne doit pas être dupliqué');
      expect(items.single.shelf, Shelf.reading);
    });

    test('supprime une lecture archivée mais jamais la courante', () async {
      final bookId = await addDune(shelf: Shelf.read);
      final firstId = await currentEntryId(bookId);
      await db.readingEntriesDao.startReread(bookId: bookId);
      final secondId = await currentEntryId(bookId);

      expect(await db.readingEntriesDao.deleteArchivedEntry(secondId), isFalse);
      expect(await db.readingEntriesDao.deleteArchivedEntry(firstId), isTrue);

      final entries =
          await db.readingEntriesDao.watchEntriesForBook(bookId).first;
      expect(entries.map((entry) => entry.id), <int>[secondId]);
    });
  });
}
