import 'dart:convert';

import 'package:biblivre/core/failure.dart';
import 'package:biblivre/data/backup/backup_codec.dart';
import 'package:biblivre/data/local/app_database.dart';
import 'package:biblivre/data/repositories/backup_repository_json.dart';
import 'package:biblivre/domain/models/backup.dart';
import 'package:biblivre/domain/models/library_query.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'test_database.dart';

void main() {
  group('BackupCodec', () {
    test('fait un aller-retour sans rien perdre', () {
      final archive = BackupArchive(
        exportedAt: DateTime(2026, 9, 22, 14, 30),
        tags: const <String>['SF', 'Polars'],
        books: <BackupBook>[
          BackupBook(
            olKey: '/works/OL893415W',
            title: 'Dune',
            author: 'Frank Herbert',
            pageCount: 658,
            coverId: 8231856,
            coverUrl: 'https://covers.openlibrary.org/b/id/8231856-L.jpg',
            firstPublishYear: 1965,
            description: 'Une histoire de sable.',
            isbn: '9780441013593',
            isManual: false,
            createdAt: DateTime(2026, 1, 1),
            tags: const <String>['SF'],
            readings: <BackupReading>[
              BackupReading(
                shelf: Shelf.read,
                rating: 4,
                review: 'Lu à vingt ans.',
                startedAt: DateTime(2020, 1, 1),
                finishedAt: DateTime(2020, 2, 1),
                currentPage: 658,
                isCurrent: false,
                createdAt: DateTime(2020, 1, 1),
              ),
              BackupReading(
                shelf: Shelf.reading,
                currentPage: 120,
                isCurrent: true,
                startedAt: DateTime(2026, 9, 1),
                createdAt: DateTime(2026, 9, 1),
              ),
            ],
          ),
        ],
      );

      final decoded = BackupCodec.decode(BackupCodec.encode(archive));

      expect(decoded.version, kBackupFormatVersion);
      expect(decoded.exportedAt, DateTime(2026, 9, 22, 14, 30));
      expect(decoded.tags, <String>['SF', 'Polars']);
      expect(decoded.books, hasLength(1));

      final book = decoded.books.single;
      expect(book.olKey, '/works/OL893415W');
      expect(book.title, 'Dune');
      expect(book.author, 'Frank Herbert');
      expect(book.pageCount, 658);
      expect(book.coverId, 8231856);
      expect(book.firstPublishYear, 1965);
      expect(book.description, 'Une histoire de sable.');
      expect(book.isbn, '9780441013593');
      expect(book.tags, <String>['SF']);
      expect(book.readings, hasLength(2));

      final past = book.readings.first;
      expect(past.shelf, Shelf.read);
      expect(past.rating, 4);
      expect(past.review, 'Lu à vingt ans.');
      expect(past.startedAt, DateTime(2020, 1, 1));
      expect(past.finishedAt, DateTime(2020, 2, 1));
      expect(past.isCurrent, isFalse);
      expect(book.readings.last.isCurrent, isTrue);
    });

    test('produit un JSON lisible et sans identifiants locaux', () {
      final json = BackupCodec.encode(
        BackupArchive(
          exportedAt: DateTime.utc(2026, 9, 22),
          books: const <BackupBook>[
            BackupBook(title: 'Dune', isManual: true, readings: <BackupReading>[]),
          ],
        ),
      );

      expect(json, contains('\n'), reason: 'le fichier doit être indenté');
      expect(json, isNot(contains('"id"')));
      expect(json, isNot(contains('bookId')));

      final decoded = jsonDecode(json) as Map<String, Object?>;
      expect(decoded['version'], 1);
      expect(decoded['exportedAt'], '2026-09-22T00:00:00.000Z');
    });

    test('refuse un fichier qui n\'est pas du JSON', () {
      expect(
        () => BackupCodec.decode('ceci n\'est pas du json'),
        throwsA(isA<MalformedBackupException>()),
      );
    });

    test('refuse un JSON qui n\'est pas une sauvegarde', () {
      expect(
        () => BackupCodec.decode('{"hello": "world"}'),
        throwsA(isA<MalformedBackupException>()),
      );
      expect(
        () => BackupCodec.decode('[]'),
        throwsA(isA<MalformedBackupException>()),
      );
    });

    test('refuse une version plus récente que celle qu\'on sait lire', () {
      expect(
        () => BackupCodec.decode('{"version": 99, "books": []}'),
        throwsA(
          isA<UnsupportedBackupVersionException>()
              .having((error) => error.version, 'version', 99),
        ),
      );
    });

    test('refuse un livre sans titre', () {
      expect(
        () => BackupCodec.decode(
          '{"version": 1, "books": [{"author": "Anonyme"}]}',
        ),
        throwsA(isA<MalformedBackupException>()),
      );
    });

    test('refuse une étagère inconnue', () {
      expect(
        () => BackupCodec.decode(
          '{"version": 1, "books": [{"title": "Dune", '
          '"readings": [{"shelf": "abandonne"}]}]}',
        ),
        throwsA(isA<MalformedBackupException>()),
      );
    });

    test('ignore les valeurs aberrantes sans tout rejeter', () {
      final archive = BackupCodec.decode(
        '{"version": 1, "books": [{"title": "Dune", "pageCount": -3, '
        '"createdAt": "pas une date", "readings": [{"shelf": "read", '
        '"rating": 42, "currentPage": -1}]}]}',
      );

      final book = archive.books.single;
      expect(book.pageCount, isNull);
      expect(book.createdAt, isNull);
      // Une note hors bornes serait refusée par la base : on l'oublie.
      expect(book.readings.single.rating, isNull);
      expect(book.readings.single.currentPage, 0);
    });
  });

  group('JsonBackupRepository', () {
    late AppDatabase db;
    late JsonBackupRepository repository;

    setUp(() {
      db = createTestDatabase();
      repository = JsonBackupRepository(database: db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<int> seedDune({Shelf shelf = Shelf.read, int? rating}) async {
      final bookId = await db.booksDao.addBook(
        title: 'Dune',
        author: 'Frank Herbert',
        olKey: '/works/OL893415W',
        pageCount: 658,
        coverId: 8231856,
        coverUrl: 'https://covers.openlibrary.org/b/id/8231856-L.jpg',
        firstPublishYear: 1965,
        description: 'Une histoire de sable.',
        shelf: shelf,
        now: DateTime(2026, 1, 1),
      );
      if (rating != null) {
        final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
        await db.readingEntriesDao
            .updateEntry(entry!.id, rating: Value<int?>(rating));
      }
      return bookId;
    }

    test('propose un nom de fichier daté', () {
      expect(
        repository.suggestedFileName(now: DateTime(2026, 9, 22)),
        'mybookmark-2026-09-22.json',
      );
      expect(
        repository.suggestedFileName(now: DateTime(2026, 3, 7)),
        'mybookmark-2026-03-07.json',
      );
    });

    test('exporte puis réimporte à l\'identique dans une base vide', () async {
      final bookId = await seedDune(rating: 5);
      final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
      await db.readingEntriesDao.updateEntry(
        entry!.id,
        review: const Value<String?>('Un monument.'),
      );
      final tagId = await db.tagsDao.ensureTag('SF');
      await db.tagsDao.attachTag(bookId: bookId, tagId: tagId);

      final json = await repository.exportJson();

      // On repart d'une base neuve, comme sur un autre téléphone.
      final other = createTestDatabase();
      addTearDown(other.close);
      final otherRepository = JsonBackupRepository(database: other);

      final report =
          await otherRepository.import(json, mode: ImportMode.merge);
      expect(report.booksImported, 1);
      expect(report.booksSkipped, 0);
      expect(report.readingsImported, 1);

      final item = (await other.booksDao.watchLibrary().first).single;
      expect(item.book.title, 'Dune');
      expect(item.book.author, 'Frank Herbert');
      expect(item.book.olKey, '/works/OL893415W');
      expect(item.book.pageCount, 658);
      expect(item.book.coverUrl,
          'https://covers.openlibrary.org/b/id/8231856-L.jpg');
      expect(item.book.description, 'Une histoire de sable.');
      expect(item.book.createdAt, DateTime(2026, 1, 1));
      expect(item.shelf, Shelf.read);
      expect(item.currentEntry.rating, 5);
      expect(item.currentEntry.review, 'Un monument.');
      expect(item.tags.map((tag) => tag.name), <String>['SF']);
    });

    test('conserve l\'historique des relectures', () async {
      final bookId = await seedDune(rating: 3);
      await db.readingEntriesDao
          .startReread(bookId: bookId, now: DateTime(2026, 6, 1));

      final json = await repository.exportJson();
      final other = createTestDatabase();
      addTearDown(other.close);

      final report = await JsonBackupRepository(database: other)
          .import(json, mode: ImportMode.merge);

      expect(report.readingsImported, 2);
      final entries = await other.readingEntriesDao
          .watchEntriesForBook(
            (await other.booksDao.watchLibrary().first).single.book.id,
          )
          .first;
      expect(entries, hasLength(2));
      expect(entries.where((entry) => entry.isCurrent), hasLength(1));
      expect(entries.firstWhere((entry) => !entry.isCurrent).rating, 3);
    });

    test('décrit un fichier avant d\'y toucher', () async {
      await seedDune();
      final json = await repository.exportJson();

      final summary = await repository.inspect(json);

      expect(summary.version, 1);
      expect(summary.bookCount, 1);
      expect(summary.readingCount, 1);
      // Le même fichier réimporté ici : le livre est déjà présent.
      expect(summary.alreadyPresentCount, 1);
      expect(summary.libraryCount, 1);
      expect(summary.newBookCount, 0);

      // L'inspection n'écrit rien.
      expect(await db.booksDao.watchLibrary().first, hasLength(1));
    });

    test('la fusion ignore les livres déjà présents', () async {
      await seedDune(rating: 5);
      final json = await repository.exportJson();

      // La note est changée après l'export : la fusion ne doit pas l'écraser.
      final entry = await db.readingEntriesDao.findCurrentEntry(
        (await db.booksDao.watchLibrary().first).single.book.id,
      );
      await db.readingEntriesDao
          .updateEntry(entry!.id, rating: const Value<int?>(2));

      final report = await repository.import(json, mode: ImportMode.merge);

      expect(report.booksImported, 0);
      expect(report.booksSkipped, 1);
      final item = (await db.booksDao.watchLibrary().first).single;
      expect(item.currentEntry.rating, 2, reason: 'la note locale est gardée');
    });

    test('la fusion ajoute les livres absents', () async {
      await seedDune();
      final json = await repository.exportJson();

      final other = createTestDatabase();
      addTearDown(other.close);
      await other.booksDao.addBook(title: 'Zazie', shelf: Shelf.toRead);

      final report = await JsonBackupRepository(database: other)
          .import(json, mode: ImportMode.merge);

      expect(report.booksImported, 1);
      expect(report.booksSkipped, 0);
      final titles = (await other.booksDao
              .watchLibrary(
                const LibraryQuery(sort: LibrarySort.title, descending: false),
              )
              .first)
          .map((item) => item.book.title);
      expect(titles, <String>['Dune', 'Zazie']);
    });

    test('dédoublonne les livres manuels sur le titre et l\'auteur', () async {
      await db.booksDao.addBook(
        title: 'Carnet de bord',
        author: 'Moi',
        shelf: Shelf.reading,
        isManual: true,
      );
      final json = await repository.exportJson();

      final other = createTestDatabase();
      addTearDown(other.close);
      // Même livre, écrit différemment : accents, casse et ponctuation.
      await other.booksDao.addBook(
        title: 'CARNET DE BORD !',
        author: 'moi',
        shelf: Shelf.toRead,
        isManual: true,
      );

      final report = await JsonBackupRepository(database: other)
          .import(json, mode: ImportMode.merge);

      expect(report.booksSkipped, 1);
      expect(report.booksImported, 0);
      expect(await other.booksDao.watchLibrary().first, hasLength(1));
    });

    test('le remplacement efface la bibliothèque existante', () async {
      await seedDune();
      final json = await repository.exportJson();

      final other = createTestDatabase();
      addTearDown(other.close);
      await other.booksDao.addBook(title: 'À jeter', shelf: Shelf.toRead);
      final tagId = await other.tagsDao.ensureTag('À jeter aussi');
      await other.tagsDao.attachTag(
        bookId: (await other.booksDao.watchLibrary().first).single.book.id,
        tagId: tagId,
      );

      final report = await JsonBackupRepository(database: other)
          .import(json, mode: ImportMode.replace);

      expect(report.mode, ImportMode.replace);
      expect(report.booksImported, 1);
      final items = await other.booksDao.watchLibrary().first;
      expect(items.map((item) => item.book.title), <String>['Dune']);
      expect(await other.tagsDao.watchAllTags().first, isEmpty);
    });

    test('un fichier vide vide la bibliothèque en remplacement', () async {
      await seedDune();
      final empty = BackupCodec.encode(
        BackupArchive(exportedAt: DateTime.now(), books: const <BackupBook>[]),
      );

      final report = await repository.import(empty, mode: ImportMode.replace);

      expect(report.booksImported, 0);
      expect(await db.booksDao.watchLibrary().first, isEmpty);
    });

    test('répare un fichier sans lecture courante', () async {
      const json = '{"version": 1, "books": [{"title": "Dune", '
          '"readings": [{"shelf": "read", "isCurrent": false}, '
          '{"shelf": "reading", "isCurrent": false}]}]}';

      await repository.import(json, mode: ImportMode.merge);

      final items = await db.booksDao.watchLibrary().first;
      // Sans entrée courante, le livre n'apparaîtrait pas du tout.
      expect(items, hasLength(1));
      expect(items.single.shelf, Shelf.reading);
    });

    test('donne une étagère à un livre qui n\'en a aucune', () async {
      const json = '{"version": 1, "books": [{"title": "Dune"}]}';

      await repository.import(json, mode: ImportMode.merge);

      final items = await db.booksDao.watchLibrary().first;
      expect(items.single.shelf, Shelf.toRead);
    });

    test('recrée les étagères personnalisées sans livre', () async {
      await db.tagsDao.ensureTag('Vide');
      final json = await repository.exportJson();

      final other = createTestDatabase();
      addTearDown(other.close);
      await JsonBackupRepository(database: other)
          .import(json, mode: ImportMode.merge);

      expect(
        (await other.tagsDao.watchAllTags().first).map((tag) => tag.name),
        <String>['Vide'],
      );
    });

    test('sauve une date de fin incohérente sans perdre l\'import', () async {
      const json = '{"version": 1, "books": [{"title": "Dune", "readings": '
          '[{"shelf": "read", "isCurrent": true, '
          '"startedAt": "2026-05-10T00:00:00.000Z", '
          '"finishedAt": "2026-01-01T00:00:00.000Z"}]}]}';

      await repository.import(json, mode: ImportMode.merge);

      final item = (await db.booksDao.watchLibrary().first).single;
      expect(item.currentEntry.startedAt, isNotNull);
      // La date impossible est écartée, le livre est quand même importé.
      expect(item.currentEntry.finishedAt, isNull);
    });
  });
}
