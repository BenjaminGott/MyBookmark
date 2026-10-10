/// Les ISBN : reconnaître celui d'un code-barres ou d'une recherche.
///
/// Un livre porte au dos un code-barres EAN-13 qui est son ISBN-13 : il
/// commence par 978 ou 979. Les autres EAN-13 (un paquet de café…) sont
/// refusés, comme les numéros dont la clé de contrôle est fausse.
class Isbn {
  const Isbn._();

  /// L'ISBN-13 lu dans un code-barres, ou `null` si ce n'est pas un livre.
  static String? fromBarcode(String? raw) {
    final digits = (raw ?? '').replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^97[89]\d{10}$').hasMatch(digits)) {
      return null;
    }
    return _validIsbn13(digits) ? digits : null;
  }

  /// L'ISBN tapé dans une recherche (10 ou 13 chiffres, tirets et espaces
  /// permis), sans ses séparateurs ; `null` si la recherche n'en est pas un.
  static String? fromQuery(String query) {
    final compact = query.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
    if (RegExp(r'^97[89]\d{10}$').hasMatch(compact)) {
      return _validIsbn13(compact) ? compact : null;
    }
    if (RegExp(r'^\d{9}[\dX]$').hasMatch(compact)) {
      return _validIsbn10(compact) ? compact : null;
    }
    return null;
  }

  static bool _validIsbn13(String digits) {
    var sum = 0;
    for (var i = 0; i < 13; i++) {
      sum += int.parse(digits[i]) * (i.isEven ? 1 : 3);
    }
    return sum % 10 == 0;
  }

  static bool _validIsbn10(String digits) {
    var sum = 0;
    for (var i = 0; i < 10; i++) {
      final value = digits[i] == 'X' ? 10 : int.parse(digits[i]);
      sum += value * (10 - i);
    }
    return sum % 11 == 0;
  }
}
