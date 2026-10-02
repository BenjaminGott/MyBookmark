/// Ouvre un lien hors de l'application : messagerie, Play Store, navigateur.
abstract class ExternalLinks {
  /// Renvoie `false` si aucune application ne sait ouvrir [uri].
  Future<bool> open(Uri uri);
}
