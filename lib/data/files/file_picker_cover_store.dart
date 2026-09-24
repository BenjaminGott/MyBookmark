import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/failure.dart';
import '../../domain/repositories/cover_store.dart';

/// [CoverStore] qui passe par le sélecteur de fichiers du système.
class FilePickerCoverStore implements CoverStore {
  const FilePickerCoverStore();

  static const String _folder = 'covers';

  @override
  Future<String?> pickFromGallery() async {
    final PlatformFile? picked;
    try {
      picked = await FilePicker.pickFile(
        dialogTitle: 'Choisir une couverture',
        type: FileType.image,
      );
    } on PlatformException {
      throw const FileAccessException();
    }
    if (picked == null) {
      return null;
    }

    try {
      final folder = await _coversFolder();
      final extension = picked.extension?.toLowerCase() ?? 'jpg';
      // Un nom neuf à chaque choix : l'ancienne image, encore en cache sous
      // son nom, ne risque pas de s'afficher à la place de la nouvelle.
      final name = '${DateTime.now().microsecondsSinceEpoch}.$extension';
      final copy = File('${folder.path}${Platform.pathSeparator}$name');
      await copy.writeAsBytes(await picked.readAsBytes(), flush: true);
      return copy.uri.toString();
    } on PlatformException {
      throw const FileAccessException(AppErrorReason.imageRead);
    } on FileSystemException {
      throw const FileAccessException(AppErrorReason.imageCopy);
    }
  }

  @override
  Future<void> discard(String? coverUrl) async {
    final uri = coverUrl == null ? null : Uri.tryParse(coverUrl);
    if (uri == null || !uri.isScheme('file')) {
      return;
    }

    final file = File(uri.toFilePath());
    final folder = await _coversFolder();
    // Seules nos propres copies sont effacées, jamais un fichier ailleurs.
    if (file.parent.path != folder.path) {
      return;
    }
    try {
      await file.delete();
    } on FileSystemException {
      // Déjà disparue : rien à faire.
    }
  }

  Future<Directory> _coversFolder() async {
    final documents = await getApplicationDocumentsDirectory();
    return Directory('${documents.path}${Platform.pathSeparator}$_folder')
        .create(recursive: true);
  }
}
