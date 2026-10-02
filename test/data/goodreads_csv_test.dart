import 'package:biblivre/core/failure.dart';
import 'package:biblivre/data/backup/goodreads_csv.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un vrai export Goodreads, réduit à trois livres.
const String _export =
    'Book Id,Title,Author,Author l-f,Additional Authors,ISBN,ISBN13,My Rating,'
    'Publisher,Binding,Number of Pages,Year Published,Original Publication '
    'Year,Date Read,Date Added,Bookshelves,Bookshelves with positions,'
    'Exclusive Shelf,My Review,Spoiler,Private Notes,Read Count,Owned Copies\n'
    '39775955,"Ensnared (The Accidental Billionaires, #1)",J.S. Scott,'
    '"Scott, J.S.",,"=""1503960463""","=""9781503960466""",0,'
    'Montlake Romance,Kindle Edition,248,2018,2018,,2026/10/02,'
    'did-not-finish,did-not-finish (#1),did-not-finish,,,,0,0\n'
    '53205794,"The Last Watch (The Divide, #1)",J.S. Dewes,"Dewes, J.S.",,'
    '"=""1250236347""","=""9781250236340""",0,Tor Trade,Paperback,480,2021,'
    '2021,,2026/10/02,to-read,to-read (#1),to-read,,,,0,0\n'
    '240411785,"Le Chevalier et la Phalène (Le Royaume d\'Eauroche, #1)",'
    'Rachel Gillig,"Gillig, Rachel",Benjamin Peylet,"=""2378768044""",'
    '"=""9782378768041""",0,DE SAXUS,Hardcover,448,2025,2025,2026/09/22,'
    '2026/09/22,currently-reading,currently-reading (#1),currently-reading,'
    ',,,2,0\n';

void main() {
  group('GoodreadsCsv', () {
    final books = GoodreadsCsv.decode(_export).books;

    test('lit tous les livres, sans la série dans le titre', () {
      expect(books.map((book) => book.title), <String>[
        'Ensnared',
        'The Last Watch',
        'Le Chevalier et la Phalène',
      ]);
      expect(books.last.author, 'Rachel Gillig');
      expect(books.last.pageCount, 448);
      expect(books.last.firstPublishYear, 2025);
    });

    test('range chaque livre sur la bonne étagère', () {
      expect(books[1].readings.single.shelf, Shelf.toRead);
      expect(books[2].readings.single.shelf, Shelf.reading);
      expect(books[2].readings.single.startedAt, DateTime(2026, 9, 22));
      expect(books[2].createdAt, DateTime(2026, 9, 22));
    });

    test('garde une étagère inconnue comme étiquette', () {
      expect(books.first.readings.single.shelf, Shelf.toRead);
      expect(books.first.tags, <String>['did-not-finish']);
      expect(books[1].tags, isEmpty);
    });

    test('nettoie l\'ISBN et en tire la couverture Open Library', () {
      expect(books.last.isbn, '9782378768041');
      expect(
        books.last.coverUrl,
        'https://covers.openlibrary.org/b/isbn/9782378768041-L.jpg'
        '?default=false',
      );
    });

    test('une note de 0 veut dire « pas de note »', () {
      expect(books.first.readings.single.rating, isNull);
    });

    test('un livre lu est lu jusqu\'au bout, avec note et avis', () {
      final read = GoodreadsCsv.decode(
        'Title,Author,Exclusive Shelf,My Rating,Number of Pages,Date Read,'
        'My Review\n'
        'Dune,Frank Herbert,read,4,658,2024/03/05,"Grand.<br/>Très <i>grand</i>."\n',
      ).books.single.readings.single;

      expect(read.shelf, Shelf.read);
      expect(read.rating, 4);
      expect(read.currentPage, 658);
      expect(read.finishedAt, DateTime(2024, 3, 5));
      expect(read.review, 'Grand.\nTrès grand.');
    });

    test('refuse un fichier qui n\'est pas un export Goodreads', () {
      expect(
        () => GoodreadsCsv.decode('nom,prenom\nDupont,Jean\n'),
        throwsA(
          isA<MalformedBackupException>().having(
            (error) => error.reason,
            'reason',
            AppErrorReason.malformedGoodreads,
          ),
        ),
      );
      expect(
        () => GoodreadsCsv.decode(''),
        throwsA(isA<MalformedBackupException>()),
      );
    });
  });

  group('parseCsv', () {
    test('gère guillemets, guillemets doublés et retours à la ligne', () {
      expect(parseCsv('﻿a,"b, c","d ""e""",\r\n"f\ng",h\n'), <List<String>>[
        <String>['a', 'b, c', 'd "e"', ''],
        <String>['f\ng', 'h'],
      ]);
    });
  });
}
