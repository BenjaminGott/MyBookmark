/// Échange de fichiers avec le système : c'est ainsi que l'export sort de
/// l'application et que l'import y entre.
abstract class FileExchange {
  /// Propose d'enregistrer [contents] sous [fileName].
  ///
  /// Renvoie `false` si l'utilisateur annule.
  Future<bool> saveText({required String fileName, required String contents});

  /// Demande un fichier et renvoie son contenu, ou `null` en cas d'annulation.
  Future<String?> pickText();
}
