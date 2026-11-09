import 'package:biblivre/domain/models/book.dart';
import 'package:biblivre/domain/models/reading_entry.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/domain/models/year_review.dart';
import 'package:biblivre/domain/repositories/year_review_repository.dart';
import 'package:biblivre/l10n/app_localizations.dart';
import 'package:biblivre/ui/year_review/year_review_providers.dart';
import 'package:biblivre/ui/year_review/year_review_screen.dart';
import 'package:biblivre/ui/year_review/year_reviews_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un dépôt en mémoire : des lectures données, des bilans dans une table.
class _FakeRepository implements YearReviewRepository {
  _FakeRepository(this.readings);

  final List<FinishedReading> readings;
  final Map<int, YearReview> saved = <int, YearReview>{};

  @override
  Future<List<FinishedReading>> finishedReadings() async => readings;

  @override
  YearReview? load(int year) => saved[year];

  @override
  Future<void> save(YearReview review) async => saved[review.year] = review;

  @override
  Set<int> savedYears() => saved.keys.toSet();
}

FinishedReading _reading(
  int id,
  String title,
  DateTime finished, {
  String? author,
  int? rating,
}) {
  final created = DateTime(2020);
  return FinishedReading(
    book: Book(
      id: id,
      title: title,
      author: author,
      pageCount: 300,
      isManual: true,
      createdAt: created,
      updatedAt: created,
    ),
    entry: ReadingEntry(
      id: id,
      bookId: id,
      shelf: Shelf.read,
      currentPage: 300,
      isCurrent: true,
      rating: rating,
      startedAt: finished.subtract(const Duration(days: 9)),
      finishedAt: finished,
      createdAt: created,
      updatedAt: created,
    ),
  );
}

void main() {
  late _FakeRepository repository;

  setUp(() {
    repository = _FakeRepository(<FinishedReading>[
      _reading(
        1,
        'Emma',
        DateTime(2026, 3, 20),
        author: 'Jane Austen',
        rating: 5,
      ),
      _reading(2, 'Persuasion', DateTime(2026, 8, 2), author: 'Jane Austen'),
      _reading(3, 'Dune', DateTime(2025, 6, 1)),
    ]);
  });

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          yearReviewRepositoryProvider.overrideWithValue(repository),
          clockProvider.overrideWithValue(() => DateTime(2027, 1, 5)),
        ],
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Mes bilans liste les années passées, la plus récente d\'abord', (
    tester,
  ) async {
    await pump(tester, const YearReviewsScreen());

    expect(find.text('Bilan 2026'), findsOne);
    expect(find.text('Bilan 2025'), findsOne);
    // Pas encore ouverts : rien n'est encore figé.
    expect(find.text('Nouveau'), findsNWidgets(2));
    expect(
      tester.getTopLeft(find.text('Bilan 2026')).dy,
      lessThan(tester.getTopLeft(find.text('Bilan 2025')).dy),
    );
  });

  testWidgets('ouvrir un bilan le crée et l\'enregistre, figé', (tester) async {
    await pump(tester, const YearReviewScreen(year: 2026));

    expect(find.text('MON ANNÉE EN LECTURE'), findsOne);
    expect(find.text('2026'), findsOne);
    expect(tester.takeException(), isNull);
    expect(repository.saved[2026]!.bookCount, 2);

    // Un livre ajouté ensuite ne change pas le bilan enregistré.
    repository.readings.add(_reading(4, 'Emma bis', DateTime(2026, 12, 1)));
    expect(repository.load(2026)!.bookCount, 2);
  });

  testWidgets('toucher à droite avance d\'une page', (tester) async {
    await pump(tester, const YearReviewScreen(year: 2026));

    await tester.tapAt(const Offset(350, 400));
    await tester.pumpAndSettle();

    expect(find.text('livres terminés'), findsOne);
    expect(tester.takeException(), isNull);
  });

  testWidgets('« Mettre à jour » recalcule le bilan', (tester) async {
    await pump(tester, const YearReviewScreen(year: 2026));
    repository.readings.add(_reading(4, 'Emma bis', DateTime(2026, 12, 1)));

    await tester.tap(find.byTooltip('Mettre à jour'));
    await tester.pumpAndSettle();

    expect(repository.load(2026)!.bookCount, 3);
    expect(find.text('Bilan mis à jour'), findsOne);
  });

  testWidgets('une année sans livre terminé le dit simplement', (tester) async {
    await pump(tester, const YearReviewScreen(year: 2020));

    expect(find.text('Aucun livre terminé en 2020.'), findsOne);
    expect(repository.saved, isEmpty);
  });
}
