import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/failure.dart';
import '../../domain/repositories/story_sharing.dart';

/// Partage en story Instagram, par l'intent `ADD_TO_STORY` de Meta.
///
/// L'intent lui-même est lancé côté Android, dans `MainActivity` : il faut un
/// `FileProvider` et une permission de lecture accordée à Instagram, ce que
/// Dart ne sait pas faire seul.
class InstagramStorySharing implements StorySharing {
  const InstagramStorySharing();

  static const MethodChannel _channel = MethodChannel(
    'com.benjamin.biblivre/instagram_story',
  );

  @override
  Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } on MissingPluginException {
      // Pas d'Android derrière (tests, autre plateforme) : pas de story.
      return false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<void> sharePng({
    required Uint8List bytes,
    required String fileName,
    required bool asSticker,
    required Color topColor,
    required Color bottomColor,
  }) async {
    final File file;
    try {
      // Le dossier temporaire est celui que le `FileProvider` expose.
      final directory = await getTemporaryDirectory();
      file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
    } on FileSystemException {
      throw const FileAccessException(
        'Impossible de préparer l\'image à partager.',
      );
    } on MissingPlatformDirectoryException {
      throw const FileAccessException(
        'Impossible de préparer l\'image à partager.',
      );
    }

    try {
      await _channel.invokeMethod<void>('share', <String, Object>{
        'path': file.path,
        'asSticker': asSticker,
        'topColor': _hex(topColor),
        'bottomColor': _hex(bottomColor),
      });
    } on PlatformException {
      throw const FileAccessException('Instagram n\'a pas pu être ouvert.');
    } on MissingPluginException {
      throw const FileAccessException('Instagram n\'a pas pu être ouvert.');
    }
  }

  /// Instagram attend ses couleurs sous la forme `#RRGGBB`.
  static String _hex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
