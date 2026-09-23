/// Les échecs que l'application sait nommer, et donc expliquer à l'utilisateur.
///
/// Chaque cas porte son propre message en français : l'interface n'a jamais à
/// inventer un texte ni à afficher une trace technique.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// Le téléphone n'a pas de réseau, ou le serveur est injoignable.
class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Pas de connexion. Vérifiez votre réseau et réessayez.',
  ]);
}

/// La requête a mis trop de temps.
///
/// Nommée ainsi pour ne pas entrer en collision avec `TimeoutException` de
/// `dart:async`, que le client réseau attrape par ailleurs.
class RequestTimeoutException extends AppException {
  const RequestTimeoutException([
    super.message = 'La recherche met trop de temps à répondre.',
  ]);
}

/// Le service de livres a répondu, mais avec une erreur.
class ServerException extends AppException {
  const ServerException(this.statusCode)
      : super('Le service de livres a renvoyé une erreur. Réessayez plus tard.');

  final int statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// La réponse est arrivée mais reste incompréhensible.
class MalformedResponseException extends AppException {
  const MalformedResponseException([
    super.message = 'Réponse illisible du service de livres.',
  ]);
}

/// La requête a été abandonnée parce qu'une plus récente l'a remplacée.
///
/// Ce n'est pas une erreur à montrer : l'interface l'ignore simplement.
class RequestCancelledException extends AppException {
  const RequestCancelledException([super.message = 'Requête annulée.']);
}

/// Le livre est déjà en bibliothèque : sa clé Open Library y est déjà.
class DuplicateBookException extends AppException {
  const DuplicateBookException([
    super.message = 'Ce livre est déjà dans votre bibliothèque.',
  ]);
}

/// L'écriture en base a échoué : contrainte violée, disque plein…
class StorageException extends AppException {
  const StorageException([
    super.message = 'Enregistrement impossible. Vérifiez la saisie.',
  ]);
}

/// Le fichier choisi n'est pas un export de Biblivre.
class MalformedBackupException extends AppException {
  const MalformedBackupException([
    super.message = 'Ce fichier n\'est pas une sauvegarde Biblivre valide.',
  ]);
}

/// Le fichier vient d'une version plus récente de l'application.
class UnsupportedBackupVersionException extends AppException {
  const UnsupportedBackupVersionException(this.version)
      : super('Cette sauvegarde vient d\'une version plus récente de '
            'Biblivre. Mettez l\'application à jour pour la lire.');

  final int version;
}

/// La lecture ou l'écriture du fichier a échoué.
class FileAccessException extends AppException {
  const FileAccessException([
    super.message = 'Impossible d\'accéder au fichier choisi.',
  ]);
}
