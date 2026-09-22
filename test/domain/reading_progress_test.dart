import 'package:biblivre/domain/services/reading_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReadingProgress.fraction', () {
    test('calcule la fraction lue', () {
      expect(ReadingProgress.fraction(currentPage: 50, pageCount: 200), 0.25);
    });

    test('vaut null quand le nombre de pages est inconnu', () {
      expect(ReadingProgress.fraction(currentPage: 50, pageCount: null), isNull);
      expect(ReadingProgress.fraction(currentPage: 50, pageCount: 0), isNull);
      expect(ReadingProgress.fraction(currentPage: 50, pageCount: -10), isNull);
    });

    test('reste bornée entre 0 et 1', () {
      expect(ReadingProgress.fraction(currentPage: -5, pageCount: 200), 0);
      expect(ReadingProgress.fraction(currentPage: 0, pageCount: 200), 0);
      expect(ReadingProgress.fraction(currentPage: 999, pageCount: 200), 1);
    });
  });

  group('ReadingProgress.percent', () {
    test('arrondit à l\'entier le plus proche', () {
      expect(ReadingProgress.percent(currentPage: 1, pageCount: 3), 33);
      expect(ReadingProgress.percent(currentPage: 2, pageCount: 3), 67);
    });

    test('vaut null quand le nombre de pages est inconnu', () {
      expect(ReadingProgress.percent(currentPage: 10, pageCount: null), isNull);
    });
  });

  group('ReadingProgress.clampPage', () {
    test('ramène une page négative à zéro', () {
      expect(ReadingProgress.clampPage(page: -3, pageCount: 200), 0);
    });

    test('plafonne au nombre de pages connu', () {
      expect(ReadingProgress.clampPage(page: 500, pageCount: 200), 200);
    });

    test('laisse passer la saisie quand le total est inconnu', () {
      expect(ReadingProgress.clampPage(page: 500, pageCount: null), 500);
      expect(ReadingProgress.clampPage(page: 500, pageCount: 0), 500);
    });
  });

  group('ReadingProgress.remainingPages', () {
    test('compte les pages restantes', () {
      expect(ReadingProgress.remainingPages(currentPage: 50, pageCount: 200), 150);
    });

    test('ne descend jamais sous zéro', () {
      expect(ReadingProgress.remainingPages(currentPage: 999, pageCount: 200), 0);
    });

    test('vaut null quand le total est inconnu', () {
      expect(
        ReadingProgress.remainingPages(currentPage: 50, pageCount: null),
        isNull,
      );
    });
  });
}
