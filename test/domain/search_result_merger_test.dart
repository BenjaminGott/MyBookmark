import 'package:biblivre/domain/models/book_search_result.dart';
import 'package:biblivre/domain/services/search_result_merger.dart';
import 'package:flutter_test/flutter_test.dart';

BookSearchResult _ol(String title, {String? author, int key = 1}) =>
    BookSearchResult(olKey: '/works/OL${key}W', title: title, author: author);

BookSearchResult _apple(String title, {String? author, int id = 1}) =>
    BookSearchResult(
      olKey: 'apple:$id',
      title: title,
      author: author,
      artworkUrl: 'https://apple.test/$id.jpg',
    );

void main() {
  const merger = SearchResultMerger();

  group('isSameBook', () {
    test('reconnaît un titre identique aux accents près', () {
      expect(
        merger.isSameBook(
          _ol('Les Misérables', author: 'Victor Hugo'),
          _apple('Les miserables', author: 'Hugo, Victor'),
        ),
        isTrue,
      );
    });

    test('reconnaît un titre prolongé par un sous-titre', () {
      expect(
        merger.isSameBook(
          _ol('Dune', author: 'Frank Herbert'),
          _apple('Dune - Tome 1', author: 'Frank Herbert'),
        ),
        isTrue,
      );
    });

    test('refuse le même titre chez deux auteurs différents', () {
      expect(
        merger.isSameBook(
          _ol('Le Horla', author: 'Guy de Maupassant'),
          _apple('Le Horla', author: 'Jean Dupont'),
        ),
        isFalse,
      );
    });

    test('refuse un simple mot en commun au début', () {
      expect(
        merger.isSameBook(
          _ol('Dune', author: 'Frank Herbert'),
          _apple('Dunes et déserts', author: 'Frank Herbert'),
        ),
        isFalse,
      );
    });

    test('sans auteur, exige le titre exact', () {
      expect(merger.isSameBook(_ol('Dune'), _apple('Dune')), isTrue);
      expect(merger.isSameBook(_ol('Dune'), _apple('Dune - Tome 1')), isFalse);
    });
  });

  group('merge', () {
    test('garde l\'ordre affiché et ajoute les inconnus à la fin', () {
      final merged = merger.merge(
        <BookSearchResult>[_apple('Dune', id: 1), _apple('Salammbô', id: 2)],
        <BookSearchResult>[_ol('Hypérion', key: 9), _ol('Dune', key: 5)],
      );

      expect(
        merged.map((r) => r.olKey),
        <String>['/works/OL5W', 'apple:2', '/works/OL9W'],
      );
      expect(merged.first.artworkUrl, 'https://apple.test/1.jpg');
    });

    test('ne complète un livre qu\'une seule fois', () {
      final merged = merger.merge(
        <BookSearchResult>[_ol('Dune', key: 1)],
        <BookSearchResult>[_apple('Dune', id: 1), _apple('Dune', id: 2)],
      );

      expect(merged.map((r) => r.olKey), <String>['/works/OL1W', 'apple:2']);
    });

    test('ne fusionne jamais deux résultats de la même source', () {
      final merged = merger.merge(
        <BookSearchResult>[_ol('Dune', key: 1)],
        <BookSearchResult>[_ol('Dune', key: 2)],
      );

      expect(merged, hasLength(2));
    });
  });
}
