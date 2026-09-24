import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show PlatformException;

import '../../core/failure.dart';
import '../../domain/repositories/file_exchange.dart';

/// Échange de fichiers via le sélecteur système d'Android.
///
/// Passer par le sélecteur évite toute permission de stockage : l'utilisateur
/// choisit lui-même l'emplacement, et l'application n'accède qu'à ce fichier.
class FilePickerExchange implements FileExchange {
  const FilePickerExchange();

  @override
  Future<bool> saveText({
    required String fileName,
    required String contents,
  }) async {
    try {
      final saved = await FilePicker.saveFile(
        fileName: fileName,
        bytes: utf8.encode(contents),
        mimeType: 'application/json',
        dialogTitle: 'Enregistrer la sauvegarde',
      );
      return saved != null;
    } on PlatformException {
      throw const FileAccessException(
        AppErrorReason.exportLocation,
      );
    }
  }

  @override
  Future<String?> pickText() async {
    final PlatformFile? file;
    try {
      file = await FilePicker.pickFile(
        dialogTitle: 'Choisir une sauvegarde',
        type: FileType.custom,
        allowedExtensions: <String>['json'],
      );
    } on PlatformException {
      throw const FileAccessException();
    }

    if (file == null) {
      return null;
    }

    try {
      return utf8.decode(await file.readAsBytes());
    } on PlatformException {
      throw const FileAccessException(AppErrorReason.fileRead);
    } on FormatException {
      throw const MalformedBackupException(
        AppErrorReason.backupNotText,
      );
    }
  }
}
