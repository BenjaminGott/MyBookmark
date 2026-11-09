import '../models/shelf.dart';
import '../models/year_review.dart';

/// Calcule le bilan d'une année à partir des lectures terminées.
///
/// Une lecture compte pour l'année de sa date de fin, comme sur Goodreads :
/// un livre fini le 31 décembre compte, un livre commencé en décembre et fini
/// en janvier compte pour l'année suivante. Seules les lectures rangées dans
/// « Lu » comptent : un livre remis « À lire » après coup n'est plus terminé.
class YearReviewBuilder {
  const YearReviewBuilder();

  /// Les années qui ont au moins une lecture terminée, la plus récente
  /// d'abord.
  List<int> yearsWithReadings(List<FinishedReading> readings) {
    final years = <int>{
      for (final reading in readings)
        if (_isFinished(reading)) reading.entry.finishedAt!.year,
    }.toList()..sort((a, b) => b.compareTo(a));
    return years;
  }

  /// Le bilan de [year], ou `null` si aucun livre n'a été terminé cette
  /// année-là.
  YearReview? build({
    required int year,
    required List<FinishedReading> readings,
    required DateTime now,
  }) {
    final finished = <FinishedReading>[
      for (final reading in readings)
        if (_isFinished(reading) && reading.entry.finishedAt!.year == year)
          reading,
    ]..sort((a, b) => a.entry.finishedAt!.compareTo(b.entry.finishedAt!));
    if (finished.isEmpty) {
      return null;
    }

    final perMonth = List<int>.filled(12, 0);
    var pages = 0;
    final durations = <int>[];
    final ratings = <int>[];
    final authors = <String, int>{};
    // Le nom tel qu'il est écrit la première fois, pour l'affichage.
    final authorNames = <String, String>{};

    for (final reading in finished) {
      final entry = reading.entry;
      final finishedAt = entry.finishedAt!;
      perMonth[finishedAt.month - 1]++;

      final pageCount = reading.book.pageCount;
      if (pageCount != null && pageCount > 0) {
        pages += pageCount;
      }

      final startedAt = entry.startedAt;
      if (startedAt != null && !finishedAt.isBefore(startedAt)) {
        // Un livre commencé et fini le même jour compte pour une journée.
        durations.add(finishedAt.difference(startedAt).inDays + 1);
      }

      final rating = entry.rating;
      if (rating != null) {
        ratings.add(rating);
      }

      final author = reading.book.author?.trim();
      if (author != null && author.isNotEmpty) {
        final key = author.toLowerCase();
        authors[key] = (authors[key] ?? 0) + 1;
        authorNames.putIfAbsent(key, () => author);
      }
    }

    // L'auteur le plus lu, seulement s'il revient : un auteur lu une fois
    // parmi d'autres lus une fois n'a rien de remarquable.
    String? topAuthor;
    var topCount = 0;
    authors.forEach((key, count) {
      if (count >= 2 && count > topCount) {
        topAuthor = authorNames[key];
        topCount = count;
      }
    });

    return YearReview(
      year: year,
      createdAt: now,
      books: <YearReviewBook>[
        for (final reading in finished)
          YearReviewBook(
            title: reading.book.title,
            author: reading.book.author,
            coverUrl: reading.book.coverUrl,
            pageCount:
                reading.book.pageCount != null && reading.book.pageCount! > 0
                ? reading.book.pageCount
                : null,
            rating: reading.entry.rating,
            finishedAt: reading.entry.finishedAt!,
          ),
      ],
      pagesRead: pages,
      booksPerMonth: perMonth,
      averageDays: durations.isEmpty
          ? null
          : (durations.reduce((a, b) => a + b) / durations.length).round(),
      averageRating: ratings.isEmpty
          ? null
          : ratings.reduce((a, b) => a + b) / ratings.length,
      topAuthor: topAuthor,
      topAuthorCount: topCount,
    );
  }

  /// Faut-il afficher l'annonce du bilan de l'an dernier ?
  ///
  /// En janvier seulement, si le bilan n'existe pas encore et qu'au moins un
  /// livre a été terminé l'an dernier. Renvoie l'année concernée.
  int? yearToAnnounce({
    required DateTime now,
    required List<FinishedReading> readings,
    required Set<int> savedYears,
  }) {
    if (now.month != DateTime.january) {
      return null;
    }
    final lastYear = now.year - 1;
    if (savedYears.contains(lastYear)) {
      return null;
    }
    return yearsWithReadings(readings).contains(lastYear) ? lastYear : null;
  }

  static bool _isFinished(FinishedReading reading) =>
      reading.entry.shelf == Shelf.read && reading.entry.finishedAt != null;
}
