/// Les étagères d'un livre : les trois principales, plus « Abandonné » pour
/// les livres laissés en route.
///
/// [wireName] est la seule représentation textuelle stable : elle sert à la
/// fois pour le stockage en base et pour l'export JSON. Ne jamais persister
/// [Enum.name] ni l'index, qui changeraient au moindre renommage.
enum Shelf {
  toRead('to_read'),
  reading('reading'),
  read('read'),
  abandoned('abandoned');

  const Shelf(this.wireName);

  final String wireName;

  /// Les étagères proposées à l'ajout d'un livre : on n'ajoute pas un livre
  /// pour l'abandonner aussitôt.
  static const List<Shelf> forNewBook = <Shelf>[toRead, reading, read];

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
