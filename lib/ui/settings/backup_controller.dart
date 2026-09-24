import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../core/failure.dart';
import '../../domain/models/backup.dart';
import '../providers/settings_providers.dart';

/// Ce qu'une opération de sauvegarde renvoie à l'écran.
sealed class BackupOutcome {
  const BackupOutcome();
}

/// L'utilisateur a fermé le sélecteur de fichiers sans rien choisir.
class BackupCancelled extends BackupOutcome {
  const BackupCancelled();
}

class BackupExported extends BackupOutcome {
  const BackupExported(this.fileName);

  final String fileName;
}

/// Un fichier a été lu et décrit, sans rien écrire : l'écran peut maintenant
/// demander confirmation.
@immutable
class BackupInspected extends BackupOutcome {
  const BackupInspected({required this.summary, required this.contents});

  final BackupSummary summary;

  /// Le contenu déjà lu, pour ne pas redemander le fichier à la confirmation.
  final String contents;
}

class BackupImported extends BackupOutcome {
  const BackupImported(this.report);

  final ImportReport report;
}

class BackupFailed extends BackupOutcome {
  const BackupFailed(this.error);

  final AppException error;
}

/// Export et import, avec un état « occupé » pour bloquer les boutons.
///
/// L'import se fait en deux temps : [inspect] lit le fichier et le décrit,
/// [applyImport] écrit seulement après confirmation de l'utilisateur.
class BackupController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<BackupOutcome> export() async {
    return _run(() async {
      final repository = ref.read(backupRepositoryProvider);
      final json = await repository.exportJson();
      final fileName = repository.suggestedFileName();

      final saved = await ref
          .read(fileExchangeProvider)
          .saveText(fileName: fileName, contents: json);

      return saved ? BackupExported(fileName) : const BackupCancelled();
    });
  }

  Future<BackupOutcome> inspect() async {
    return _run(() async {
      final contents = await ref.read(fileExchangeProvider).pickText();
      if (contents == null) {
        return const BackupCancelled();
      }

      final summary = await ref.read(backupRepositoryProvider).inspect(contents);
      return BackupInspected(summary: summary, contents: contents);
    });
  }

  Future<BackupOutcome> applyImport(
    String contents, {
    required ImportMode mode,
  }) {
    return _run(() async {
      final report = await ref
          .read(backupRepositoryProvider)
          .import(contents, mode: mode);
      return BackupImported(report);
    });
  }

  Future<BackupOutcome> _run(Future<BackupOutcome> Function() action) async {
    state = true;
    try {
      return await action();
    } on AppException catch (error) {
      return BackupFailed(error);
    } finally {
      state = false;
    }
  }
}

final NotifierProvider<BackupController, bool> backupControllerProvider =
    NotifierProvider<BackupController, bool>(BackupController.new);
