import '../models/year_review.dart';
import '../services/year_review_season.dart';

/// Les bilans annuels : la matière pour les calculer, et les bilans figés.
abstract class YearReviewRepository {
  /// Toutes les lectures terminées, relectures comprises.
  Future<List<FinishedReading>> finishedReadings();

  /// Le bilan enregistré pour [year], ou `null` s'il n'a jamais été créé (ou
  /// s'il n'est plus lisible).
  YearReview? load(int year);

  Future<void> save(YearReview review);

  /// Les années qui ont un bilan enregistré.
  Set<int> savedYears();

  /// Combien de fois [notice] a été montrée pour le bilan de [year].
  int noticeCount(YearReviewNotice notice, int year);

  Future<void> markNoticeShown(YearReviewNotice notice, int year);
}
