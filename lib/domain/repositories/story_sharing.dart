import 'dart:typed_data';
import 'dart:ui' show Color;

/// Partage direct dans une story Instagram.
///
/// Contrairement à la feuille de partage du système, Instagram reçoit ici
/// l'image comme **sticker** posé sur un fond qu'on lui décrit : la
/// transparence des coins arrondis est conservée, au lieu d'être remplie de
/// noir comme lorsque l'image devient le fond de la story.
abstract class StorySharing {
  /// Vrai si Instagram est installé et sait recevoir une story.
  Future<bool> isAvailable();

  /// Ouvre l'éditeur de story d'Instagram.
  ///
  /// Avec [asSticker], [bytes] est posé en sticker sur un dégradé allant de
  /// [topColor] à [bottomColor]. Sans lui, l'image occupe tout le fond : c'est
  /// ce qui convient à une image déjà au format 9:16.
  Future<void> sharePng({
    required Uint8List bytes,
    required String fileName,
    required bool asSticker,
    required Color topColor,
    required Color bottomColor,
  });
}
