import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/year_review/local_year_review_repository.dart';
import '../../domain/models/year_review.dart';
import '../../domain/repositories/year_review_repository.dart';
import '../../domain/services/year_review_builder.dart';
import '../../domain/services/year_review_season.dart';
import '../providers/database_providers.dart';
import '../providers/settings_providers.dart';

final Provider<YearReviewRepository> yearReviewRepositoryProvider =
    Provider<YearReviewRepository>((ref) {
      return LocalYearReviewRepository(
        database: ref.watch(databaseProvider),
        preferences: ref.watch(preferencesServiceProvider),
      );
    });

/// L'heure qu'il est. Remplacée dans les tests pour se placer en janvier.
final Provider<DateTime Function()> clockProvider =
    Provider<DateTime Function()>((ref) => DateTime.now);

/// Une ligne de « Mes bilans » : l'année, et son bilan s'il a été créé.
class YearReviewSummary {
  const YearReviewSummary({required this.year, this.review});

  final int year;
  final YearReview? review;
}

/// Les années qui ont un bilan, ou qui pourraient en avoir un, la plus
/// récente d'abord. L'année en cours n'en fait partie qu'une fois finie : son
/// bilan n'a de sens qu'en janvier suivant.
final FutureProvider<List<YearReviewSummary>> yearReviewYearsProvider =
    FutureProvider<List<YearReviewSummary>>((ref) async {
      final repository = ref.watch(yearReviewRepositoryProvider);
      final now = ref.watch(clockProvider)();
      final readings = await repository.finishedReadings();
      final years =
          <int>{
              ...const YearReviewBuilder().yearsWithReadings(readings),
              ...repository.savedYears(),
            }.where((year) => year < now.year).toList()
            ..sort((a, b) => b.compareTo(a));
      return <YearReviewSummary>[
        for (final year in years)
          YearReviewSummary(year: year, review: repository.load(year)),
      ];
    });

/// Le bilan d'une année : celui qui est enregistré, sinon il est calculé et
/// enregistré à cette occasion. Il reste ensuite figé.
final yearReviewProvider = FutureProvider.family<YearReview?, int>((
  ref,
  year,
) async {
  final repository = ref.watch(yearReviewRepositoryProvider);
  final saved = repository.load(year);
  if (saved != null) {
    return saved;
  }
  return _buildAndSave(repository, ref.read(clockProvider), year);
});

/// Recalcule le bilan de [year] avec les lectures d'aujourd'hui (« Mettre à
/// jour »), l'enregistre et le renvoie.
Future<YearReview?> refreshYearReview(WidgetRef ref, int year) async {
  final review = await _buildAndSave(
    ref.read(yearReviewRepositoryProvider),
    ref.read(clockProvider),
    year,
  );
  ref
    ..invalidate(yearReviewProvider(year))
    ..invalidate(yearReviewYearsProvider);
  return review;
}

Future<YearReview?> _buildAndSave(
  YearReviewRepository repository,
  DateTime Function() clock,
  int year,
) async {
  final review = const YearReviewBuilder().build(
    year: year,
    readings: await repository.finishedReadings(),
    now: clock(),
  );
  if (review != null) {
    await repository.save(review);
  }
  return review;
}

/// Ce que l'app montre du bilan de l'an dernier à ce lancement : l'onglet
/// en janvier, et la fenêtre de janvier ou de février tant qu'elle n'a pas
/// été vue deux fois. `null` le reste de l'année.
final FutureProvider<YearReviewSeasonState?> yearReviewSeasonProvider =
    FutureProvider<YearReviewSeasonState?>((ref) async {
      final repository = ref.watch(yearReviewRepositoryProvider);
      return const YearReviewSeason().at(
        now: ref.watch(clockProvider)(),
        readings: await repository.finishedReadings(),
        savedYears: repository.savedYears(),
        shownCount: repository.noticeCount,
      );
    });
