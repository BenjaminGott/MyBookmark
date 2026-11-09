import 'package:biblivre/domain/models/year_review.dart';
import 'package:biblivre/l10n/app_localizations.dart';
import 'package:biblivre/ui/widgets/book_cover.dart';
import 'package:biblivre/ui/year_review/year_review_slides.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

YearReview _review(int count) => YearReview(
  year: 2026,
  createdAt: DateTime(2027),
  books: <YearReviewBook>[
    for (var i = 0; i < count; i++)
      YearReviewBook(
        title: 'Livre $i',
        author: 'Auteur',
        pageCount: 300,
        rating: 4,
        finishedAt: DateTime(2026, 1 + i % 12, 2),
      ),
  ],
  pagesRead: 300 * count,
  booksPerMonth: List<int>.generate(12, (m) => m < count ? 1 : 0),
);

void main() {
  group('coverGridLayout', () {
    const space = Size(304, 330);

    test('un seul livre : une grande couverture, bornée', () {
      final layout = coverGridLayout(count: 1, space: space);
      expect(layout.columns, 1);
      expect(layout.width, 200);
    });

    test('quatre livres : un carré de deux sur deux', () {
      expect(coverGridLayout(count: 4, space: space).columns, 2);
    });

    test('moins de livres, plus grandes couvertures', () {
      final widths = <double>[
        for (final count in <int>[1, 2, 6])
          coverGridLayout(count: count, space: space).width,
      ];
      for (var i = 1; i < widths.length; i++) {
        expect(widths[i], lessThanOrEqualTo(widths[i - 1]));
      }
    });

    test('la mosaïque tient toujours dans la place donnée', () {
      for (var count = 1; count <= 8; count++) {
        final layout = coverGridLayout(count: count, space: space);
        final rows = (count / layout.columns).ceil();
        expect(
          layout.columns * layout.width + 10 * (layout.columns - 1),
          lessThanOrEqualTo(space.width + 0.001),
        );
        expect(
          rows * layout.width * 1.5 + 10 * (rows - 1),
          lessThanOrEqualTo(space.height + 0.001),
        );
      }
    });
  });

  for (final count in <int>[1, 2, 3, 5, 9]) {
    testWidgets('$count livre(s) : la première page s\'adapte sans déborder', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final slides = yearReviewSlides(_review(count));

      for (final slide in <Widget>[slides.first, slides.last]) {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Material(child: slide),
          ),
        );
        expect(tester.takeException(), isNull);
      }

      // Première page : une seule couverture est bien plus grande que six.
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Material(child: slides.first),
        ),
      );
      final width = tester.getSize(find.byType(BookCover).first).width;
      expect(width, count == 1 ? greaterThan(150) : greaterThan(80));
    });
  }
}
