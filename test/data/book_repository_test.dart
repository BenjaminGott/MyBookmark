import 'package:biblivre/core/cancellation.dart';
import 'package:biblivre/core/failure.dart';
import 'package:biblivre/data/local/app_database.dart';
import 'package:biblivre/data/repositories/book_repository_drift.dart';
import 'package:biblivre/domain/models/book_search_result.dart';
import 'package:biblivre/domain/models/library_query.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/domain/repositories/search_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

/// Une source de résumés sous contrôle : elle répond, se taise, ou tombe.
class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository({this.description, this.failure});

  final String? description;
  final AppException? failure;
  int calls = 0;

  @override
  Stream<List<BookSearchResult>> search(
    String rawQuery, {
    CancellationToken? token,
  }) =>
      Stream<List<BookSearchResult>>.value(const <BookSearchResult>[]);

  @override
  Future<String?> loadDescription(
    String olKey, {
    CancellationToken? token,
  }) async {
    calls++;
    final error = failure;
    if (error != null) {
      throw error;
    }
    return description;
  }
}

const BookSearchResult _dune = BookSearchResult(
  olKey: '/works/OL893415W',
  title: 'Dune',
  author: 'Frank Herbert',
  pageCount: 658,
  coverId: 8231856,
  firstPublishYear: 1965,
);

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  DriftBookRepository buildRepository(_FakeSearchRepository search) =>
      DriftBookRepository(database: db, searchRepository: search);

  group('addFromSearch', () {
    test('recopie toutes les métadonnées en base', () async {
      final search = _FakeSearchRepository(description: 'Une histoire de sable.');
      final repository = buildRepository(search);

      final bookId = await repository.addFromSearch(_dune, Shelf.toRead);

      final book = await repository.findById(bookId);
      expect(book!.olKey, '/works/OL893415W');
      expect(book.title, 'Dune');
      expect(book.author, 'Frank Herbert');
      expect(book.pageCount, 658);
      expect(book.coverId, 8231856);
      expect(book.firstPublishYear, 1965);
      expect(book.description, 'Une histoire de sable.');
      expect(book.isManual, isFalse);
    });

    test('stocke une couverture en grande taille pour la fiche livre', () async {
      final repository = buildRepository(_FakeSearchRepository());

      final bookId = await repository.addFromSearch(_dune, Shelf.toRead);

      final book = await repository.findById(bookId);
      expect(book!.coverUrl, 'https://covers.openlibrary.org/b/id/8231856-L.jpg');
    });

    test('garde la couverture et le résumé d\'Apple Books', () async {
      final search = _FakeSearchRepository(description: 'En anglais.');
      final repository = buildRepository(search);

      final bookId = await repository.addFromSearch(
        _dune.copyWith(
          artworkUrl: 'https://apple.test/200x300bb.jpg',
          largeArtworkUrl: 'https://apple.test/600x900bb.jpg',
          description: 'Sur Arrakis, la planète des sables.',
        ),
        Shelf.toRead,
      );

      final book = await repository.findById(bookId);
      expect(book!.coverUrl, 'https://apple.test/600x900bb.jpg');
      expect(book.description, 'Sur Arrakis, la planète des sables.');
      expect(search.calls, 0, reason: 'résumé déjà connu, pas d\'appel');
    });

    test('ajoute quand même le livre si le résumé est injoignable', () async {
      final search = _FakeSearchRepository(failure: const NetworkException());
      final repository = buildRepository(search);

      final bookId = await repository.addFromSearch(_dune, Shelf.reading);

      final book = await repository.findById(bookId);
      expect(book!.title, 'Dune');
      expect(book.description, isNull);
      expect(search.calls, 1);
    });

    test('range le livre sur l\'étagère demandée', () async {
      final repository = buildRepository(_FakeSearchRepository());

      await repository.addFromSearch(_dune, Shelf.reading);

      final item =
          (await repository.watchLibrary(const LibraryQuery()).first).single;
      expect(item.shelf, Shelf.reading);
      expect(item.currentEntry.startedAt, isNotNull);
    });

    test('refuse un doublon avec un message compréhensible', () async {
      final repository = buildRepository(_FakeSearchRepository());
      await repository.addFromSearch(_dune, Shelf.toRead);

      await expectLater(
        repository.addFromSearch(_dune, Shelf.read),
        throwsA(
          isA<DuplicateBookException>().having(
            (error) => error.message,
            'message',
            'Ce livre est déjà dans votre bibliothèque.',
          ),
        ),
      );
    });

    test('signale le livre comme déjà connu', () async {
      final repository = buildRepository(_FakeSearchRepository());
      expect(await repository.watchKnownOlKeys().first, isEmpty);

      await repository.addFromSearch(_dune, Shelf.toRead);

      expect(
        await repository.watchKnownOlKeys().first,
        <String>{'/works/OL893415W'},
      );
    });

    test('ne rappelle plus jamais le réseau une fois le livre ajouté', () async {
      final search = _FakeSearchRepository(description: 'Un résumé.');
      final repository = buildRepository(search);
      final bookId = await repository.addFromSearch(_dune, Shelf.reading);
      expect(search.calls, 1);

      // Tout ce que les écrans font ensuite est purement local.
      await repository.watchLibrary(const LibraryQuery()).first;
      await repository.watchBook(bookId).first;
      await repository.watchEntries(bookId).first;
      await repository.findById(bookId);
      final entryId =
          (await repository.watchBook(bookId).first)!.currentEntry.id;
      await repository.updateProgress(entryId: entryId, page: 100);
      await repository.rate(entryId: entryId, rating: 5);
      await repository.moveToShelf(entryId: entryId, shelf: Shelf.read);

      expect(search.calls, 1, reason: 'aucun nouvel appel réseau attendu');
    });
  });

  group('addManual', () {
    test('marque le livre comme saisi à la main', () async {
      final repository = buildRepository(_FakeSearchRepository());

      final bookId = await repository.addManual(
        title: '  Carnet de bord  ',
        shelf: Shelf.reading,
        author: '   ',
        pageCount: 120,
      );

      final book = await repository.findById(bookId);
      expect(book!.isManual, isTrue);
      expect(book.title, 'Carnet de bord');
      // Un champ laissé vide ne devient pas une chaîne vide en base.
      expect(book.author, isNull);
      expect(book.olKey, isNull);
    });

    test('n\'appelle jamais le réseau', () async {
      final search = _FakeSearchRepository(description: 'Jamais lu');
      final repository = buildRepository(search);

      await repository.addManual(title: 'Carnet', shelf: Shelf.toRead);

      expect(search.calls, 0);
    });
  });

  group('écritures', () {
    test('corrige un nombre de pages faux', () async {
      final repository = buildRepository(_FakeSearchRepository());
      final bookId = await repository.addManual(
        title: 'Dune',
        shelf: Shelf.reading,
        pageCount: 12,
      );

      await repository.editBook(
        bookId: bookId,
        title: 'Dune',
        author: 'Frank Herbert',
        pageCount: 658,
        firstPublishYear: 1965,
        description: null,
        coverId: null,
        coverUrl: 'file:///covers/dune.jpg',
      );

      final book = await repository.findById(bookId);
      expect(book!.pageCount, 658);
      expect(book.coverUrl, 'file:///covers/dune.jpg');
      expect(book.author, 'Frank Herbert');
    });

    test('traduit une note hors bornes en échec d\'enregistrement', () async {
      final repository = buildRepository(_FakeSearchRepository());
      final bookId =
          await repository.addManual(title: 'Dune', shelf: Shelf.read);
      final entryId =
          (await repository.watchBook(bookId).first)!.currentEntry.id;

      await expectLater(
        repository.rate(entryId: entryId, rating: 9),
        throwsA(isA<StorageException>()),
      );
    });

    test('supprime un livre et son historique', () async {
      final repository = buildRepository(_FakeSearchRepository());
      final bookId =
          await repository.addManual(title: 'Dune', shelf: Shelf.read);
      await repository.startReread(bookId);

      await repository.deleteBook(bookId);

      expect(await repository.watchBook(bookId).first, isNull);
      expect(await repository.watchEntries(bookId).first, isEmpty);
    });
  });
}
