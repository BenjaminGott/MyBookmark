import '../models/backup.dart';

/// Export et import de toute la bibliothèque en JSON, et import d'un export
/// Goodreads.
///
/// C'est le seul moyen de sortir ses données de l'application : il n'y a ni
/// compte, ni serveur, ni synchronisation.
abstract class BackupRepository {
  /// Sérialise toute la base en JSON.
  Future<String> exportJson();

  /// Nom de fichier proposé à l'enregistrement, daté du jour.
  String suggestedFileName({DateTime? now});

  /// Lit un fichier sans rien écrire, pour pouvoir demander confirmation en
  /// connaissance de cause.
  Future<BackupSummary> inspect(
    String contents, {
    BackupFormat format = BackupFormat.mybookmark,
  });

  /// Applique un fichier, en fusion ou en remplacement.
  Future<ImportReport> import(
    String contents, {
    required ImportMode mode,
    BackupFormat format = BackupFormat.mybookmark,
  });
}
