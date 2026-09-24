import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show PlatformException;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/failure.dart';
import '../../domain/repositories/image_sharing.dart';

/// Partage d'image via `share_plus`.
///
/// L'image passe par un fichier du dossier temporaire de l'application : c'est
/// ce que les autres applications savent recevoir. Android nettoie ce dossier
/// tout seul, rien n'est conservé.
class SharePlusImageSharing implements ImageSharing {
  const SharePlusImageSharing();

  @override
  Future<void> sharePng({
    required Uint8List bytes,
    required String fileName,
    String? text,
  }) async {
    final File file;
    try {
      final directory = await getTemporaryDirectory();
      file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
    } on FileSystemException {
      throw const FileAccessException(
        AppErrorReason.imagePrepare,
      );
    } on MissingPlatformDirectoryException {
      throw const FileAccessException(
        AppErrorReason.imagePrepare,
      );
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(file.path, mimeType: 'image/png')],
          text: text,
        ),
      );
    } on PlatformException {
      throw const FileAccessException(AppErrorReason.shareFailed);
    }
  }
}
