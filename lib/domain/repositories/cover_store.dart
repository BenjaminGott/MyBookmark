/// Les couvertures choisies par l'utilisateur dans sa galerie.
///
/// L'image est copiée dans les fichiers de l'application : elle survit ainsi
/// au ménage de la galerie. Le livre ne garde que son URI `file://`, dans la
/// même colonne que les couvertures distantes.
abstract class CoverStore {
  /// Fait choisir une image et renvoie l'URI de sa copie, ou `null` si
  /// l'utilisateur a renoncé.
  Future<String?> pickFromGallery();

  /// Efface une copie faite par [pickFromGallery]. Une URL distante, ou nulle,
  /// est ignorée.
  Future<void> discard(String? coverUrl);
}
