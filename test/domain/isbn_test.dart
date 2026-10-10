import 'package:biblivre/domain/services/isbn.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Isbn.fromBarcode', () {
    test('accepte le code-barres d\'un livre', () {
      // Le Petit Prince, Folio.
      expect(Isbn.fromBarcode('9782070612758'), '9782070612758');
      expect(Isbn.fromBarcode('9791032102503'), '9791032102503');
    });

    test('refuse un code-barres qui n\'est pas un livre', () {
      // Un EAN-13 valide, mais d'un produit (préfixe 300).
      expect(Isbn.fromBarcode('3017620422003'), isNull);
    });

    test('refuse une clé de contrôle fausse', () {
      expect(Isbn.fromBarcode('9782070612759'), isNull);
      expect(Isbn.fromBarcode(null), isNull);
      expect(Isbn.fromBarcode(''), isNull);
    });
  });

  group('Isbn.fromQuery', () {
    test('reconnaît un ISBN-13, avec ou sans tirets', () {
      expect(Isbn.fromQuery('978-2-07-061275-8'), '9782070612758');
      expect(Isbn.fromQuery('978 2070612758'), '9782070612758');
    });

    test('reconnaît un ISBN-10, X compris', () {
      expect(Isbn.fromQuery('2-07-061275-9'), '2070612759');
      expect(Isbn.fromQuery('080442957x'), '080442957X');
    });

    test('laisse passer une recherche ordinaire', () {
      expect(Isbn.fromQuery('dune'), isNull);
      expect(Isbn.fromQuery('1984'), isNull);
      expect(Isbn.fromQuery('2070612752'), isNull);
    });
  });
}
