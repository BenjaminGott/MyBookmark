import 'dart:convert';

import 'package:biblivre/domain/models/book.dart';
import 'package:biblivre/domain/models/reading_entry.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/domain/models/year_review.dart';
import 'package:biblivre/domain/services/year_review_builder.dart';
import 'package:flutter_test/flutter_test.dart';

var _nextId = 1;

FinishedReading _reading(
  String title, {
  required DateTime? finished,
  DateTime? started,
  String? author,
  int? pages,
  int? rating,
  Shelf shelf = Shelf.read,
}) {
  final id = _nextId++;
  final created = DateTime(2020);
  return FinishedReading(
    book: Book(
      id: id,
      title: title,
      author: author,
      pageCount: pages,
      isManual: true,
      createdAt: created,
      updatedAt: created,
    ),
    entry: ReadingEntry(
      id: id,
      bookId: id,
      shelf: shelf,
      currentPage: 0,
      isCurrent: true,
      rating: rating,
      startedAt: started,
      finishedAt: finished,
      createdAt: created,
      updatedAt: created,
    ),
  );
}

void main() {
  const builder = YearReviewBuilder();
  final now = DateTime(2027, 1, 3);

  final readings = <FinishedReading>[
    _reading(
      'Dune',
      finished: DateTime(2026, 3, 10),
      started: DateTime(2026, 3, 1),
      author: 'Frank Herbert',
      pages: 600,
      rating: 4,
    ),
    _reading(
      'Les Enfants de Dune',
      finished: DateTime(2026, 3, 30),
      started: DateTime(2026, 3, 21),
      author: 'frank herbert ',
      pages: 500,
      rating: 5,
    ),
    _reading('Carnet', finished: DateTime(2026, 11, 2)),
    // Fini l'an d'avant : compte pour 2025.
    _reading('Ancien', finished: DateTime(2025, 12, 31), pages: 100),
    // Remis « À lire » : n'est plus terminé.
    _reading('Repris', finished: DateTime(2026, 5, 5), shelf: Shelf.toRead),
    // Pas fini.
    _reading('En cours', finished: null, shelf: Shelf.reading),
  ];

  test('liste les années qui ont des lectures, la plus récente d\'abord', () {
    expect(builder.yearsWithReadings(readings), <int>[2026, 2025]);
  });

  test('calcule le bilan de l\'année', () {
    final review = builder.build(year: 2026, readings: readings, now: now)!;

    expect(review.bookCount, 3);
    expect(review.books.map((book) => book.title), <String>[
      'Dune',
      'Les Enfants de Dune',
      'Carnet',
    ]);
    expect(review.pagesRead, 1100);
    expect(review.booksPerMonth[2], 2);
    expect(review.booksPerMonth[10], 1);
    expect(review.busiestMonth, 3);
    expect(review.averageDays, 10);
    expect(review.averageRating, 4.5);
    expect(review.favorite!.title, 'Les Enfants de Dune');
    expect(review.longest!.title, 'Dune');
    // Même auteur malgré la casse et les espaces : écrit comme la 1re fois.
    expect(review.topAuthor, 'Frank Herbert');
    expect(review.topAuthorCount, 2);
    expect(review.createdAt, now);
  });

  test('pas de bilan pour une année sans livre terminé', () {
    expect(builder.build(year: 2024, readings: readings, now: now), isNull);
  });

  test('un auteur lu une seule fois n\'est pas « le plus lu »', () {
    final review = builder.build(year: 2025, readings: readings, now: now)!;
    expect(review.topAuthor, isNull);
    expect(review.averageDays, isNull);
    expect(review.favorite, isNull);
  });

  test('survit à un aller-retour en JSON', () {
    final review = builder.build(year: 2026, readings: readings, now: now)!;
    final copy = YearReview.fromJson(
      (jsonDecode(jsonEncode(review.toJson())) as Map).cast<String, Object?>(),
    );
    expect(copy.books, review.books);
    expect(copy.pagesRead, review.pagesRead);
    expect(copy.booksPerMonth, review.booksPerMonth);
    expect(copy.averageRating, review.averageRating);
    expect(copy.topAuthor, review.topAuthor);
    expect(copy.createdAt, review.createdAt);
  });
}
