import 'dart:typed_data';

/// Partage d'une image via la feuille de partage du système.
abstract class ImageSharing {
  /// Écrit [bytes] dans un fichier temporaire et ouvre la feuille de partage.
  ///
  /// [fileName] est le nom proposé aux applications réceptrices.
  Future<void> sharePng({
    required Uint8List bytes,
    required String fileName,
    String? text,
  });
}
