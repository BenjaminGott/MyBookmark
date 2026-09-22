import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../domain/models/app_theme_mode.dart';
import '../../domain/models/backup.dart';
import '../providers/settings_providers.dart';
import 'backup_controller.dart';

/// Réglages : apparence, et sauvegarde de la bibliothèque.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeModeProvider);
    final busy = ref.watch(backupControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        children: <Widget>[
          const _SectionTitle('Apparence'),
          RadioGroup<AppThemeMode>(
            groupValue: theme,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeModeProvider.notifier).select(mode);
              }
            },
            child: const Column(
              children: <Widget>[
                RadioListTile<AppThemeMode>(
                  value: AppThemeMode.system,
                  title: Text('Comme le système'),
                ),
                RadioListTile<AppThemeMode>(
                  value: AppThemeMode.light,
                  title: Text('Clair'),
                ),
                RadioListTile<AppThemeMode>(
                  value: AppThemeMode.dark,
                  title: Text('Sombre'),
                ),
              ],
            ),
          ),
          const Divider(),
          const _SectionTitle('Mes données'),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Tout est enregistré sur ce téléphone, sans compte ni serveur. '
              'L\'export est le seul moyen de garder une copie de votre '
              'bibliothèque ou de la transférer sur un autre appareil.',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Exporter ma bibliothèque'),
            subtitle: const Text('Enregistre un fichier JSON'),
            enabled: !busy,
            onTap: () => _export(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: const Text('Importer une sauvegarde'),
            subtitle: const Text('Depuis un fichier JSON'),
            enabled: !busy,
            onTap: () => _import(context, ref),
          ),
          if (busy)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final outcome = await ref.read(backupControllerProvider.notifier).export();
    if (!context.mounted) {
      return;
    }

    switch (outcome) {
      case BackupExported(fileName: final name):
        _tell(context, 'Bibliothèque exportée dans $name');
      case BackupFailed(message: final message):
        _tell(context, message);
      case BackupCancelled():
        break;
      case BackupInspected():
      case BackupImported():
        break;
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final outcome = await ref.read(backupControllerProvider.notifier).inspect();
    if (!context.mounted) {
      return;
    }

    switch (outcome) {
      case BackupFailed(message: final message):
        _tell(context, message);
      case BackupCancelled():
        return;
      case BackupInspected(summary: final summary, contents: final contents):
        final mode = await _askMode(context, summary);
        if (mode == null || !context.mounted) {
          return;
        }
        final applied = await ref
            .read(backupControllerProvider.notifier)
            .applyImport(contents, mode: mode);
        if (!context.mounted) {
          return;
        }
        switch (applied) {
          case BackupImported(report: final report):
            _tell(context, _describe(report));
          case BackupFailed(message: final message):
            _tell(context, message);
          default:
            break;
        }
      case BackupExported():
      case BackupImported():
        break;
    }
  }

  /// Demande quoi faire du fichier, en montrant ce qu'il contient.
  ///
  /// Quand la bibliothèque est vide, la question ne se pose pas : il n'y a rien
  /// à écraser, on fusionne directement.
  Future<ImportMode?> _askMode(
    BuildContext context,
    BackupSummary summary,
  ) async {
    if (summary.libraryCount == 0) {
      return ImportMode.merge;
    }

    return showDialog<ImportMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importer cette sauvegarde ?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Fichier du '
              '${Formatters.longDate(summary.exportedAt) ?? 'date inconnue'} : '
              '${summary.bookCount} livre${summary.bookCount > 1 ? 's' : ''}, '
              '${summary.readingCount} lecture'
              '${summary.readingCount > 1 ? 's' : ''}.',
            ),
            const SizedBox(height: 12),
            Text(
              '${summary.alreadyPresentCount} de ces livres sont déjà dans '
              'votre bibliothèque, qui en compte ${summary.libraryCount}.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Fusionner ajoute les ${0} livres absents et ne touche à rien '
              'd\'autre. Remplacer efface toute votre bibliothèque actuelle.',
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ImportMode.replace),
            child: const Text('Remplacer tout'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ImportMode.merge),
            child: const Text('Fusionner'),
          ),
        ],
      ),
    );
  }

  static String _describe(ImportReport report) {
    final parts = <String>[
      if (report.mode == ImportMode.replace)
        'Bibliothèque remplacée'
      else
        'Sauvegarde fusionnée',
      '${report.booksImported} livre${report.booksImported > 1 ? 's' : ''} '
          'importé${report.booksImported > 1 ? 's' : ''}',
      if (report.booksSkipped > 0)
        '${report.booksSkipped} déjà présent${report.booksSkipped > 1 ? 's' : ''}',
    ];
    return '${parts.join(' · ')}.';
  }

  static void _tell(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
