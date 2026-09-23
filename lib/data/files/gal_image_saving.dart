import 'dart:typed_data';

import 'package:flutter/services.dart' show MissingPluginException;
import 'package:gal/gal.dart';

import '../../core/failure.dart';
import '../../domain/repositories/image_saving.dart';

/// Enregistrement dans la galerie via `gal`, dans un album « Biblivre ».
///
/// Le PNG est enregistré tel quel : les coins transparents du bloc le restent.
/// À partir d'Android 10, aucune permission n'est demandée pour écrire dans
/// l'album de l'application ; avant, `gal` la demande au premier usage.
class GalImageSaving implements ImageSaving {
  const GalImageSaving();

  static const String album = 'Biblivre';

  @override
  Future<void> savePng({required Uint8List bytes, required String name}) async {
    try {
      if (!await Gal.hasAccess(toAlbum: true) &&
          !await Gal.requestAccess(toAlbum: true)) {
        throw const FileAccessException(
          'Autorisez l\'accès aux photos pour enregistrer l\'image.',
        );
      }
      await Gal.putImageBytes(bytes, album: album, name: name);
    } on GalException catch (error) {
      throw FileAccessException(switch (error.type) {
        GalExceptionType.accessDenied =>
          'Autorisez l\'accès aux photos pour enregistrer l\'image.',
        GalExceptionType.notEnoughSpace =>
          'Plus assez de place sur le téléphone.',
        _ => 'L\'image n\'a pas pu être enregistrée.',
      });
    } on MissingPluginException {
      throw const FileAccessException('L\'image n\'a pas pu être enregistrée.');
    }
  }
}
