import 'package:biblivre/domain/services/text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizer = TextNormalizer();

  group('TextNormalizer', () {
    test('met le texte en minuscules', () {
      expect(normalizer.normalize('Le Comte DE Monte-Cristo'),
          'le comte de monte cristo');
    });

    test('retire les accents latins', () {
      expect(normalizer.normalize('À la recherche du temps perdu'),
          'a la recherche du temps perdu');
      expect(normalizer.normalize('Éloge de la fuite'), 'eloge de la fuite');
      expect(normalizer.normalize('Garçon manqué'), 'garcon manque');
      expect(normalizer.normalize('Hyppolite Œhlenschläger'),
          'hyppolite oehlenschlager');
    });

    test('retire aussi les accents écrits en forme décomposée', () {
      // « é » écrit « e » + U+0301 plutôt qu'en un seul caractère.
      expect(normalizer.normalize('crépuscule'), 'crepuscule');
    });

    test('ne touche pas au cyrillique', () {
      expect(normalizer.normalize('Война и мир'), 'война и мир');
      // Le i bref russe (й) est une lettre à part entière, pas un и accentué.
      expect(normalizer.normalize('Толстой'), 'толстой');
    });

    test('ne touche pas au grec', () {
      expect(normalizer.normalize('Οδύσσεια'), 'οδύσσεια');
    });

    test('ne touche pas à l\'arabe', () {
      expect(normalizer.normalize('ألف ليلة وليلة'), 'ألف ليلة وليلة');
    });

    test('développe les ligatures', () {
      expect(normalizer.normalize('Cœur'), 'coeur');
      expect(normalizer.normalize('Æsop'), 'aesop');
      expect(normalizer.normalize('Straße'), 'strasse');
      expect(normalizer.normalize('œuvres'), 'oeuvres');
    });

    test('remplace la ponctuation par des espaces', () {
      expect(normalizer.normalize("L'Étranger, d'Albert Camus."),
          'l etranger d albert camus');
      expect(normalizer.normalize('Vingt mille lieues — sous les mers !'),
          'vingt mille lieues sous les mers');
    });

    test('réduit les espaces multiples et coupe les bords', () {
      expect(normalizer.normalize('   dune    messie   '), 'dune messie');
      expect(normalizer.normalize('\t1984\n'), '1984');
    });

    test('conserve les chiffres', () {
      expect(normalizer.normalize('Fahrenheit 451'), 'fahrenheit 451');
    });

    test('accepte une saisie vide ou uniquement ponctuée', () {
      expect(normalizer.normalize(''), '');
      expect(normalizer.normalize('   '), '');
      expect(normalizer.normalize('!?...'), '');
    });
  });
}
