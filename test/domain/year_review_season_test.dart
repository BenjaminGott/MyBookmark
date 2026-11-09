import 'package:biblivre/domain/models/book.dart';
import 'package:biblivre/domain/models/reading_entry.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/domain/models/year_review.dart';
import 'package:biblivre/domain/services/year_review_season.dart';
import 'package:flutter_test/flutter_test.dart';

FinishedReading _finished(DateTime date) {
  final created = DateTime(2020);
  return FinishedReading(
    book: Book(
      id: 1,
      title: 'Dune',
      isManual: true,
      createdAt: created,
      updatedAt: created,
    ),
    entry: ReadingEntry(
      id: 1,
      bookId: 1,
      shelf: Shelf.read,
      currentPage: 0,
      isCurrent: true,
      finishedAt: date,
      createdAt: created,
      updatedAt: created,
    ),
  );
}

void main() {
  const season = YearReviewSeason();
  final readings = <FinishedReading>[_finished(DateTime(2026, 7, 1))];

  YearReviewSeasonState? at(
    DateTime now, {
    int shown = 0,
    List<FinishedReading>? from,
    Set<int> saved = const <int>{},
  }) => season.at(
    now: now,
    readings: from ?? readings,
    savedYears: saved,
    shownCount: (_, _) => shown,
  );

  test('en janvier : onglet et fenêtre de janvier', () {
    final state = at(DateTime(2027, 1, 20))!;
    expect(state.year, 2026);
    expect(state.tab, isTrue);
    expect(state.notice, YearReviewNotice.january);
  });

  test('la fenêtre ne revient plus après deux fois, l\'onglet reste', () {
    expect(at(DateTime(2027, 1, 3), shown: 1)!.notice, isNotNull);
    final state = at(DateTime(2027, 1, 3), shown: 2)!;
    expect(state.notice, isNull);
    expect(state.tab, isTrue);
  });

  test('en février : plus d\'onglet, fenêtre « déménagé » deux fois', () {
    final state = at(DateTime(2027, 2, 1))!;
    expect(state.tab, isFalse);
    expect(state.notice, YearReviewNotice.february);
    expect(at(DateTime(2027, 2, 9), shown: 2)!.notice, isNull);
  });

  test('rien le reste de l\'année', () {
    expect(at(DateTime(2027, 3, 1)), isNull);
    expect(at(DateTime(2026, 12, 31)), isNull);
  });

  test('rien si l\'année écoulée n\'a aucun livre terminé', () {
    expect(at(DateTime(2027, 1, 5), from: <FinishedReading>[]), isNull);
  });

  test('un bilan déjà enregistré suffit, même sans lecture en base', () {
    final state = at(
      DateTime(2027, 1, 5),
      from: <FinishedReading>[],
      saved: {2026},
    );
    expect(state!.tab, isTrue);
  });
}
