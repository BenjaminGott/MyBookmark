import 'dart:convert';

import 'package:biblivre/data/remote/dto/ol_search_response.dart';
import 'package:biblivre/domain/models/book_search_result.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un extrait réel de `search.json`, réduit aux champs demandés par l'appli.
const String _realSearchResponse = '''
{
  "numFound": 1428,
  "start": 0,
  "numFoundExact": true,
  "docs": [
    {
      "key": "/works/OL893415W",
      "title": "Dune",
      "author_name": ["Frank Herbert"],
      "number_of_pages_median": 658,
      "cover_i": 8231856,
      "first_publish_year": 1965
    },
    {
      "key": "/works/OL27479W",
      "title": "Le Petit Prince",
      "author_name": ["Antoine de Saint-Exupéry", "Richard Howard"],
      "first_publish_year": 1943,
      "cover_i": 10471189
    }
  ]
}
''';

void main() {
  group('parseSearchResponse', () {
    test('lit une réponse complète', () {
      final results = OpenLibraryParser.parseSearchResponse(
        jsonDecode(_realSearchResponse),
      );

      expect(results, hasLength(2));

      final dune = results.first;
      expect(dune.olKey, '/works/OL893415W');
      expect(dune.title, 'Dune');
      expect(dune.author, 'Frank Herbert');
      expect(dune.pageCount, 658);
      expect(dune.coverId, 8231856);
      expect(dune.firstPublishYear, 1965);
      expect(
        dune.coverUrl(),
        'https://covers.openlibrary.org/b/id/8231856-M.jpg',
      );
    });

    test('ne garde que le premier auteur', () {
      final results = OpenLibraryParser.parseSearchResponse(
        jsonDecode(_realSearchResponse),
      );
      expect(results.last.author, 'Antoine de Saint-Exupéry');
    });

    test('accepte un livre sans pages et sans couverture', () {
      final results = OpenLibraryParser.parseSearchResponse(
        jsonDecode(_realSearchResponse),
      );

      final petitPrince = results.last;
      expect(petitPrince.pageCount, isNull);
      expect(petitPrince.coverId, 10471189);
      expect(petitPrince.hasCover, isTrue);
    });

    test('renvoie une couverture nulle quand cover_i manque', () {
      final results = OpenLibraryParser.parseSearchResponse(<String, Object?>{
        'docs': <Object?>[
          <String, Object?>{'key': '/works/OL1W', 'title': 'Sans image'},
        ],
      });

      expect(results.single.hasCover, isFalse);
      expect(results.single.coverUrl(), isNull);
    });

    test('décline la taille de couverture demandée', () {
      final results = OpenLibraryParser.parseSearchResponse(
        jsonDecode(_realSearchResponse),
      );

      expect(
        results.first.coverUrl(CoverSize.large),
        'https://covers.openlibrary.org/b/id/8231856-L.jpg',
      );
    });

    test('écarte les documents sans clé ni titre', () {
      final results = OpenLibraryParser.parseSearchResponse(<String, Object?>{
        'docs': <Object?>[
          <String, Object?>{'title': 'Sans clé'},
          <String, Object?>{'key': '/works/OL2W'},
          <String, Object?>{'key': '/works/OL3W', 'title': '   '},
          <String, Object?>{'key': '/works/OL4W', 'title': 'Correct'},
        ],
      });

      expect(results.map((result) => result.title), <String>['Correct']);
    });

    test('survit à des types inattendus', () {
      final results = OpenLibraryParser.parseSearchResponse(<String, Object?>{
        'docs': <Object?>[
          'une chaîne au lieu d\'un objet',
          42,
          null,
          <String, Object?>{
            'key': '/works/OL5W',
            'title': 'Types douteux',
            // Open Library renvoie parfois un nombre sous forme de texte, ou
            // une médiane décimale.
            'number_of_pages_median': '321',
            'cover_i': 12.0,
            'first_publish_year': 'pas une année',
            'author_name': <Object?>[null, 'Auteur valide'],
          },
        ],
      });

      final book = results.single;
      expect(book.pageCount, 321);
      expect(book.coverId, 12);
      expect(book.firstPublishYear, isNull);
      expect(book.author, 'Auteur valide');
    });

    test('traite un nombre de pages nul ou négatif comme inconnu', () {
      final results = OpenLibraryParser.parseSearchResponse(<String, Object?>{
        'docs': <Object?>[
          <String, Object?>{
            'key': '/works/OL6W',
            'title': 'Pages absurdes',
            'number_of_pages_median': 0,
          },
          <String, Object?>{
            'key': '/works/OL7W',
            'title': 'Pages négatives',
            'number_of_pages_median': -3,
          },
        ],
      });

      expect(results.every((result) => result.pageCount == null), isTrue);
    });

    test('renvoie une liste vide sur une réponse vide ou cassée', () {
      expect(OpenLibraryParser.parseSearchResponse(null), isEmpty);
      expect(OpenLibraryParser.parseSearchResponse('pas du json'), isEmpty);
      expect(
        OpenLibraryParser.parseSearchResponse(<String, Object?>{'docs': 0}),
        isEmpty,
      );
      expect(
        OpenLibraryParser.parseSearchResponse(
          <String, Object?>{'numFound': 0, 'docs': <Object?>[]},
        ),
        isEmpty,
      );
    });
  });

  group('parseWorkDescription', () {
    test('lit un résumé écrit directement en chaîne', () {
      final description = OpenLibraryParser.parseWorkDescription(
        <String, Object?>{'description': '  Une histoire de sable.  '},
      );
      expect(description, 'Une histoire de sable.');
    });

    test('lit un résumé encapsulé dans un objet typé', () {
      final description =
          OpenLibraryParser.parseWorkDescription(<String, Object?>{
        'description': <String, Object?>{
          'type': '/type/text',
          'value': 'Une histoire de sable.',
        },
      });
      expect(description, 'Une histoire de sable.');
    });

    test('coupe la ligne de crédit collée en fin de résumé', () {
      final description =
          OpenLibraryParser.parseWorkDescription(<String, Object?>{
        'description': 'Le vrai résumé.\n'
            '----------\n'
            'Source : quatrième de couverture',
      });
      expect(description, 'Le vrai résumé.');
    });

    test('renvoie null quand il n\'y a pas de résumé', () {
      expect(
        OpenLibraryParser.parseWorkDescription(<String, Object?>{}),
        isNull,
      );
      expect(
        OpenLibraryParser.parseWorkDescription(
          <String, Object?>{'description': ''},
        ),
        isNull,
      );
      expect(
        OpenLibraryParser.parseWorkDescription(
          <String, Object?>{'description': 42},
        ),
        isNull,
      );
      expect(OpenLibraryParser.parseWorkDescription(null), isNull);
    });
  });
}
