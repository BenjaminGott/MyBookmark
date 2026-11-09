import '../models/year_review.dart';
import 'year_review_builder.dart';

/// Les deux fenêtres qui accompagnent le bilan de l'année écoulée.
enum YearReviewNotice {
  /// En janvier : « Votre bilan est prêt », qui mène à l'onglet du bilan.
  january,

  /// En février : l'onglet a disparu, le bilan est dans Réglages.
  february,
}

/// Ce que l'app montre du bilan de l'an dernier à ce lancement.
class YearReviewSeasonState {
  const YearReviewSeasonState({
    required this.year,
    this.tab = false,
    this.notice,
  });

  /// L'année écoulée, celle du bilan concerné.
  final int year;

  /// Vrai en janvier : le bilan a son propre onglet.
  final bool tab;

  /// La fenêtre à afficher maintenant, s'il y en a une.
  final YearReviewNotice? notice;
}

/// Le calendrier du bilan annuel.
///
/// Tout janvier, le bilan de l'année écoulée a son onglet, et une fenêtre y
/// mène aux deux premiers lancements du mois. En février, l'onglet disparaît
/// et une fenêtre, aux deux premiers lancements, explique que le bilan est
/// maintenant dans Réglages, Mes bilans. Rien de tout cela si l'année écoulée
/// n'a aucun livre terminé.
class YearReviewSeason {
  const YearReviewSeason();

  /// Combien de fois chaque fenêtre est montrée.
  static const int noticeRepeats = 2;

  YearReviewSeasonState? at({
    required DateTime now,
    required List<FinishedReading> readings,
    required Set<int> savedYears,
    required int Function(YearReviewNotice notice, int year) shownCount,
  }) {
    if (now.month != DateTime.january && now.month != DateTime.february) {
      return null;
    }
    final year = now.year - 1;
    final hasReview =
        savedYears.contains(year) ||
        const YearReviewBuilder().yearsWithReadings(readings).contains(year);
    if (!hasReview) {
      return null;
    }
    final notice = now.month == DateTime.january
        ? YearReviewNotice.january
        : YearReviewNotice.february;
    return YearReviewSeasonState(
      year: year,
      tab: notice == YearReviewNotice.january,
      notice: shownCount(notice, year) < noticeRepeats ? notice : null,
    );
  }
}
