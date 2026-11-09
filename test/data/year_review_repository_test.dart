import 'package:biblivre/data/local/app_database.dart';
import 'package:biblivre/data/prefs/preferences_service.dart';
import 'package:biblivre/data/year_review/local_year_review_repository.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/domain/services/year_review_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;
  late LocalYearReviewRepository repository;

  setUp(() async {
    db = createTestDatabase();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    repository = LocalYearReviewRepository(
      database: db,
      preferences: await PreferencesService.load(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  test('ne garde que les lectures terminées, avec leur livre', () async {
    final done = await db.booksDao.addBook(
      title: 'Dune',
      author: 'Frank Herbert',
      shelf: Shelf.reading,
      now: DateTime(2026, 5, 1),
    );
    final entry = await db.readingEntriesDao.findCurrentEntry(done);
    await db.readingEntriesDao.moveToShelf(
      entryId: entry!.id,
      shelf: Shelf.read,
      now: DateTime(2026, 6, 1),
    );
    await db.booksDao.addBook(title: 'Pas fini', shelf: Shelf.reading);

    final readings = await repository.finishedReadings();

    expect(readings, hasLength(1));
    expect(readings.single.book.title, 'Dune');
    expect(readings.single.entry.finishedAt, DateTime(2026, 6, 1));
  });

  test('enregistre un bilan et le relit tel quel', () async {
    await db.booksDao.addBook(title: 'Dune', shelf: Shelf.read);
    final readings = await repository.finishedReadings();
    final review = const YearReviewBuilder().build(
      year: readings.single.entry.finishedAt!.year,
      readings: readings,
      now: DateTime(2027, 1, 2),
    )!;

    expect(repository.load(review.year), isNull);
    await repository.save(review);

    expect(repository.savedYears(), <int>{review.year});
    final loaded = repository.load(review.year)!;
    expect(loaded.books, review.books);
    expect(loaded.createdAt, DateTime(2027, 1, 2));
  });
}
