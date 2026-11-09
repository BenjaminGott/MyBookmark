import 'dart:convert';

import '../../domain/models/year_review.dart';
import '../../domain/repositories/year_review_repository.dart';
import '../local/app_database.dart';
import '../prefs/preferences_service.dart';

/// Les lectures viennent de la base, les bilans figés sont rangés dans les
/// préférences : un petit JSON par année, sans migration de la base.
class LocalYearReviewRepository implements YearReviewRepository {
  const LocalYearReviewRepository({
    required this.database,
    required this.preferences,
  });

  final AppDatabase database;
  final PreferencesService preferences;

  @override
  Future<List<FinishedReading>> finishedReadings() =>
      database.readingEntriesDao.finishedReadings();

  @override
  YearReview? load(int year) {
    final json = preferences.yearReviewJson(year);
    if (json == null) {
      return null;
    }
    try {
      return YearReview.fromJson(
        (jsonDecode(json) as Map<Object?, Object?>).cast<String, Object?>(),
      );
    } on Object {
      // Un bilan illisible sera simplement recréé.
      return null;
    }
  }

  @override
  Future<void> save(YearReview review) =>
      preferences.setYearReviewJson(review.year, jsonEncode(review.toJson()));

  @override
  Set<int> savedYears() => preferences.savedYearReviews;
}
