/// Calcul de l'avancement d'une lecture.
///
/// Le nombre de pages d'un livre est souvent absent ou faux chez Open Library :
/// toutes les méthodes acceptent donc un total nul, négatif ou `null` et
/// répondent alors « progression inconnue » plutôt que de lever une erreur.
class ReadingProgress {
  const ReadingProgress._();

  /// Fraction lue, entre 0.0 et 1.0, ou `null` si elle ne peut pas être établie.
  static double? fraction({required int currentPage, required int? pageCount}) {
    if (pageCount == null || pageCount <= 0) {
      return null;
    }
    if (currentPage <= 0) {
      return 0;
    }
    if (currentPage >= pageCount) {
      return 1;
    }
    return currentPage / pageCount;
  }

  /// Pourcentage arrondi à l'entier, ou `null` si la progression est inconnue.
  static int? percent({required int currentPage, required int? pageCount}) {
    final value = fraction(currentPage: currentPage, pageCount: pageCount);
    return value == null ? null : (value * 100).round();
  }

  /// Ramène une page saisie dans les bornes acceptables.
  ///
  /// Une page négative devient 0. Si le total est connu, une page qui le
  /// dépasse est ramenée au total ; s'il est inconnu, la saisie est conservée.
  static int clampPage({required int page, required int? pageCount}) {
    if (page <= 0) {
      return 0;
    }
    if (pageCount != null && pageCount > 0 && page > pageCount) {
      return pageCount;
    }
    return page;
  }

  /// Nombre de pages restantes, ou `null` si le total est inconnu.
  static int? remainingPages({required int currentPage, required int? pageCount}) {
    if (pageCount == null || pageCount <= 0) {
      return null;
    }
    final remaining = pageCount - clampPage(page: currentPage, pageCount: pageCount);
    return remaining < 0 ? 0 : remaining;
  }
}
