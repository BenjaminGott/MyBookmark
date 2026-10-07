/// Quand demander un avis : au bon moment, et sans insister.
///
/// Seulement après un livre terminé, quand on en a déjà fini au moins
/// [minFinishedBooks] (l'application a eu le temps de servir), et pas plus
/// d'une fois tous les [interval].
class ReviewPolicy {
  const ReviewPolicy._();

  static const int minFinishedBooks = 2;
  static const Duration interval = Duration(days: 60);

  static bool shouldAsk({
    required int finishedBooks,
    required DateTime? lastAsked,
    required DateTime now,
  }) {
    if (finishedBooks < minFinishedBooks) {
      return false;
    }
    return lastAsked == null || now.difference(lastAsked) >= interval;
  }
}
