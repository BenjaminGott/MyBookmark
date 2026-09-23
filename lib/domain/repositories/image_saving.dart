import 'dart:typed_data';

/// Enregistrement d'une image dans la galerie du téléphone.
abstract class ImageSaving {
  /// Enregistre [bytes], une image PNG, sous le nom [name] (sans extension).
  Future<void> savePng({required Uint8List bytes, required String name});
}
