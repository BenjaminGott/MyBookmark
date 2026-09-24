/// Ce qui a échoué, sans le dire avec des mots.
///
/// Les couches data et domain ne connaissent pas la langue de l'utilisateur :
/// elles nomment la raison, et l'interface la traduit (voir
/// `ui/l10n/error_text.dart`). Jamais de trace technique à l'écran.
enum AppErrorReason {
  network,
  timeout,
  server,
  malformedResponse,
  cancelled,
  duplicateBook,
  saveFailed,
  bookReadFailed,
  libraryReadFailed,
  malformedBackup,
  backupUntitledBook,
  backupUnknownShelf,
  backupNotText,
  backupTooRecent,
  fileAccess,
  fileRead,
  exportLocation,
  imageRead,
  imageCopy,
  imagePrepare,
  shareFailed,
  instagramFailed,
  photoAccess,
  notEnoughSpace,
  imageSaveFailed,
}

/// Les échecs que l'application sait nommer, et donc expliquer à l'utilisateur.
sealed class AppException implements Exception {
  const AppException(this.reason);

  final AppErrorReason reason;

  @override
  String toString() => '$runtimeType: ${reason.name}';
}

/// Le téléphone n'a pas de réseau, ou le serveur est injoignable.
class NetworkException extends AppException {
  const NetworkException() : super(AppErrorReason.network);
}

/// La requête a mis trop de temps.
///
/// Nommée ainsi pour ne pas entrer en collision avec `TimeoutException` de
/// `dart:async`, que le client réseau attrape par ailleurs.
class RequestTimeoutException extends AppException {
  const RequestTimeoutException() : super(AppErrorReason.timeout);
}

/// Le service de livres a répondu, mais avec une erreur.
class ServerException extends AppException {
  const ServerException(this.statusCode) : super(AppErrorReason.server);

  final int statusCode;

  @override
  String toString() => 'ServerException($statusCode)';
}

/// La réponse est arrivée mais reste incompréhensible.
class MalformedResponseException extends AppException {
  const MalformedResponseException() : super(AppErrorReason.malformedResponse);
}

/// La requête a été abandonnée parce qu'une plus récente l'a remplacée.
///
/// Ce n'est pas une erreur à montrer : l'interface l'ignore simplement.
class RequestCancelledException extends AppException {
  const RequestCancelledException() : super(AppErrorReason.cancelled);
}

/// Le livre est déjà en bibliothèque : sa clé Open Library y est déjà.
class DuplicateBookException extends AppException {
  const DuplicateBookException() : super(AppErrorReason.duplicateBook);
}

/// L'accès à la base a échoué : contrainte violée, disque plein…
class StorageException extends AppException {
  const StorageException([super.reason = AppErrorReason.saveFailed]);
}

/// Le fichier choisi n'est pas une sauvegarde lisible.
class MalformedBackupException extends AppException {
  const MalformedBackupException([
    super.reason = AppErrorReason.malformedBackup,
  ]);
}

/// Le fichier vient d'une version plus récente de l'application.
class UnsupportedBackupVersionException extends AppException {
  const UnsupportedBackupVersionException(this.version)
    : super(AppErrorReason.backupTooRecent);

  final int version;
}

/// La lecture ou l'écriture d'un fichier, ou d'une image, a échoué.
class FileAccessException extends AppException {
  const FileAccessException([super.reason = AppErrorReason.fileAccess]);
}
