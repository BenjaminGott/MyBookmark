/// Les trois étagères principales d'un livre.
///
/// [wireName] est la seule représentation textuelle stable : elle sert à la
/// fois pour le stockage en base et pour l'export JSON. Ne jamais persister
/// [Enum.name] ni l'index, qui changeraient au moindre renommage.
enum Shelf {
  toRead('to_read'),
  reading('reading'),
  read('read');

  const Shelf(this.wireName);

  final String wireName;

  static Shelf? tryParse(String value) {
    for (final shelf in Shelf.values) {
      if (shelf.wireName == value) {
        return shelf;
      }
    }
    return null;
  }

  /// Lance une [FormatException] si [value] n'est pas une étagère connue.
  static Shelf parse(String value) {
    final shelf = tryParse(value);
    if (shelf == null) {
      throw FormatException('Étagère inconnue : "$value"');
    }
    return shelf;
  }
}
