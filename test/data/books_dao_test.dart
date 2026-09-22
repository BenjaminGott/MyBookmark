import 'package:biblivre/data/local/app_database.dart';
import 'package:biblivre/domain/models/library_query.dart';
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

  group('addBook', () {
    test('crée le livre et sa lecture en cours', () async {
      final now = DateTime(2026, 3, 14, 10);

      final bookId = await db.booksDao.addBook(
        title: 'Dune',
        author: 'Frank Herbert',
        olKey: '/works/OL893415W',
        pageCount: 658,
        coverId: 8231856,
        coverUrl: 'https://covers.openlibrary.org/b/id/8231856-M.jpg',
        firstPublishYear: 1965,
        shelf: Shelf.toRead,
        now: now,
      );

      final items = await db.booksDao.watchLibrary().first;
      expect(items, hasLength(1));

      final item = items.single;
      expect(item.book.id, bookId);
      expect(item.book.title, 'Dune');
      expect(item.book.author, 'Frank Herbert');
      expect(item.book.pageCount, 658);
      expect(item.book.isManual, isFalse);
      expect(item.book.createdAt, now);
      expect(item.currentEntry.shelf, Shelf.toRead);
      expect(item.currentEntry.isCurrent, isTrue);
      expect(item.currentEntry.currentPage, 0);
      expect(item.currentEntry.rating, isNull);
      // Rien n'est daté tant que le livre n'est pas commencé.
      expect(item.currentEntry.startedAt, isNull);
      expect(item.currentEntry.finishedAt, isNull);
    });

    test('date le début quand le livre est ajouté en cours de lecture',
        () async {
      final now = DateTime(2026, 3, 14, 10);
      await db.booksDao.addBook(title: 'Dune', shelf: Shelf.reading, now: now);

      final entry = (await db.booksDao.watchLibrary().first).single.currentEntry;
      expect(entry.startedAt, now);
      expect(entry.finishedAt, isNull);
    });

    test('date la fin quand le livre est ajouté comme déjà lu', () async {
      final now = DateTime(2026, 3, 14, 10);
      await db.booksDao.addBook(title: 'Dune', shelf: Shelf.read, now: now);

      final entry = (await db.booksDao.watchLibrary().first).single.currentEntry;
      expect(entry.startedAt, now);
      expect(entry.finishedAt, now);
    });

    test('accepte un livre sans auteur, sans pages et sans couverture',
        () async {
      await db.booksDao.addBook(title: 'Carnet sans titre', shelf: Shelf.toRead);

      final item = (await db.booksDao.watchLibrary().first).single;
      expect(item.book.author, isNull);
      expect(item.book.pageCount, isNull);
      expect(item.book.hasCover, isFalse);
      expect(item.book.hasKnownPageCount, isFalse);
      expect(item.progressPercent, isNull);
    });

    test('refuse deux fois la même œuvre Open Library', () async {
      await db.booksDao.addBook(
        title: 'Dune',
        olKey: '/works/OL893415W',
        shelf: Shelf.toRead,
      );

      await expectLater(
        db.booksDao.addBook(
          title: 'Dune (réédition)',
          olKey: '/works/OL893415W',
          shelf: Shelf.toRead,
        ),
        throwsA(isA<SqliteException>()),
      );
    });

    test('laisse coexister plusieurs livres saisis à la main', () async {
      await db.booksDao
          .addBook(title: 'Carnet A', shelf: Shelf.toRead, isManual: true);
      await db.booksDao
          .addBook(title: 'Carnet B', shelf: Shelf.toRead, isManual: true);

      expect(await db.booksDao.watchLibrary().first, hasLength(2));
    });

    test('rejette un nombre de pages nul ou négatif', () async {
      await expectLater(
        db.booksDao.addBook(title: 'Dune', pageCount: 0, shelf: Shelf.toRead),
        throwsA(isA<SqliteException>()),
      );
    });

    test('rejette un titre vide', () async {
      await expectLater(
        db.booksDao.addBook(title: '   ', shelf: Shelf.toRead),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('watchLibrary', () {
    Future<void> seed() async {
      await db.booksDao.addBook(
        title: 'Dune',
        author: 'Herbert',
        shelf: Shelf.read,
        now: DateTime(2026, 1, 1),
      );
      await db.booksDao.addBook(
        title: 'Anna Karénine',
        author: 'Tolstoï',
        shelf: Shelf.reading,
        now: DateTime(2026, 2, 1),
      );
      await db.booksDao.addBook(
        title: 'Zazie dans le métro',
        shelf: Shelf.toRead,
        now: DateTime(2026, 3, 1),
      );
    }

    test('filtre par étagère', () async {
      await seed();

      final reading = await db.booksDao
          .watchLibrary(const LibraryQuery(shelf: Shelf.reading))
          .first;
      expect(reading.map((item) => item.book.title), <String>['Anna Karénine']);

      final toRead = await db.booksDao
          .watchLibrary(const LibraryQuery(shelf: Shelf.toRead))
          .first;
      expect(
        toRead.map((item) => item.book.title),
        <String>['Zazie dans le métro'],
      );
    });

    test('trie par titre sans tenir compte de la casse', () async {
      await seed();

      final items = await db.booksDao
          .watchLibrary(
            const LibraryQuery(sort: LibrarySort.title, descending: false),
          )
          .first;
      expect(
        items.map((item) => item.book.title),
        <String>['Anna Karénine', 'Dune', 'Zazie dans le métro'],
      );
    });

    test("trie par date d'ajout, du plus récent au plus ancien", () async {
      await seed();

      final items = await db.booksDao.watchLibrary().first;
      expect(
        items.map((item) => item.book.title),
        <String>['Zazie dans le métro', 'Anna Karénine', 'Dune'],
      );
    });

    test('renvoie les livres sans auteur en dernier', () async {
      await seed();

      final items = await db.booksDao
          .watchLibrary(
            const LibraryQuery(sort: LibrarySort.author, descending: false),
          )
          .first;
      expect(items.last.book.title, 'Zazie dans le métro');
      expect(items.last.book.author, isNull);
    });

    test('renvoie les livres sans note en dernier, dans les deux sens',
        () async {
      await seed();
      final noted = (await db.booksDao.watchLibrary().first)
          .firstWhere((item) => item.book.title == 'Dune');
      await db.readingEntriesDao
          .updateEntry(noted.currentEntry.id, rating: const Value<int?>(4));

      for (final descending in <bool>[true, false]) {
        final items = await db.booksDao
            .watchLibrary(
              LibraryQuery(sort: LibrarySort.rating, descending: descending),
            )
            .first;
        expect(items.first.book.title, 'Dune', reason: 'descending=$descending');
        expect(items.last.rating, isNull);
      }
    });

    test("réagit à un ajout sans qu'on redemande la liste", () async {
      final emissions = <int>[];
      final subscription = db.booksDao
          .watchLibrary()
          .listen((items) => emissions.add(items.length));
      addTearDown(subscription.cancel);

      await pumpEventQueue();
      await db.booksDao.addBook(title: 'Dune', shelf: Shelf.toRead);
      await pumpEventQueue();
      await db.booksDao.addBook(title: 'Zazie', shelf: Shelf.toRead);
      await pumpEventQueue();

      expect(emissions, <int>[0, 1, 2]);
    });
  });

  group('recherche et suppression', () {
    test('retrouve un livre par sa clé Open Library', () async {
      await db.booksDao.addBook(
        title: 'Dune',
        olKey: '/works/OL893415W',
        shelf: Shelf.toRead,
      );

      expect((await db.booksDao.findByOlKey('/works/OL893415W'))?.title, 'Dune');
      expect(await db.booksDao.findByOlKey('/works/inconnu'), isNull);
    });

    test('liste les clés déjà présentes en ignorant les livres manuels',
        () async {
      await db.booksDao.addBook(
        title: 'Dune',
        olKey: '/works/OL893415W',
        shelf: Shelf.toRead,
      );
      await db.booksDao
          .addBook(title: 'Carnet', shelf: Shelf.toRead, isManual: true);

      expect(
        await db.booksDao.watchKnownOlKeys().first,
        <String>{'/works/OL893415W'},
      );
    });

    test('supprime le livre et ses lectures en cascade', () async {
      final bookId =
          await db.booksDao.addBook(title: 'Dune', shelf: Shelf.reading);
      await db.readingEntriesDao.startReread(bookId: bookId);
      expect(
        await db.readingEntriesDao.watchEntriesForBook(bookId).first,
        hasLength(2),
      );

      await db.booksDao.deleteBook(bookId);

      expect(await db.booksDao.watchLibrary().first, isEmpty);
      expect(
        await db.readingEntriesDao.watchEntriesForBook(bookId).first,
        isEmpty,
      );
    });

    test('corrige un nombre de pages faux', () async {
      final bookId = await db.booksDao
          .addBook(title: 'Dune', pageCount: 12, shelf: Shelf.reading);

      await db.booksDao.updateBook(
        bookId,
        changes: const BooksCompanion(pageCount: Value<int>(658)),
        now: DateTime(2026, 5, 1),
      );

      final book = await db.booksDao.findById(bookId);
      expect(book?.pageCount, 658);
      expect(book?.updatedAt, DateTime(2026, 5, 1));
    });
  });
}
