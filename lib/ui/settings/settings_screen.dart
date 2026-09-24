import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_language.dart';
import '../../domain/models/app_theme_mode.dart';
import '../../domain/models/backup.dart';
import '../l10n/app_language_label.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../providers/settings_providers.dart';
import 'backup_controller.dart';

/// Réglages : apparence, langue, et sauvegarde de la bibliothèque.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider) ?? AppLanguage.system;
    final busy = ref.watch(backupControllerProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: <Widget>[
          _SectionTitle(l10n.appearance),
          RadioGroup<AppThemeMode>(
            groupValue: theme,
            onChanged: (mode) {
              if (mode != null) {
                ref.read(themeModeProvider.notifier).select(mode);
              }
            },
            child: Column(
              children: <Widget>[
                RadioListTile<AppThemeMode>(
                  value: AppThemeMode.system,
                  title: Text(l10n.themeSystem),
                ),
                RadioListTile<AppThemeMode>(
                  value: AppThemeMode.light,
                  title: Text(l10n.themeLight),
                ),
                RadioListTile<AppThemeMode>(
                  value: AppThemeMode.dark,
                  title: Text(l10n.themeDark),
                ),
              ],
            ),
          ),
          const Divider(),
          _SectionTitle(l10n.language),
          RadioGroup<AppLanguage>(
            groupValue: language,
            onChanged: (value) {
              if (value != null) {
                ref.read(languageProvider.notifier).select(value);
              }
            },
            child: Column(
              children: <Widget>[
                for (final option in AppLanguage.values)
                  RadioListTile<AppLanguage>(
                    value: option,
                    title: Text(option.label(l10n)),
                  ),
              ],
            ),
          ),
          const Divider(),
          _SectionTitle(l10n.myData),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(l10n.dataExplanation),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l10n.exportLibrary),
            subtitle: Text(l10n.exportSubtitle),
            enabled: !busy,
            onTap: () => _export(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: Text(l10n.importBackup),
            subtitle: Text(l10n.importSubtitle),
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
        _tell(context, context.l10n.exportedTo(name));
      case BackupFailed(:final error):
        _tell(context, error.describe(context.l10n));
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
      case BackupFailed(:final error):
        _tell(context, error.describe(context.l10n));
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
            _tell(context, _describe(context.l10n, report));
          case BackupFailed(:final error):
            _tell(context, error.describe(context.l10n));
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

    final l10n = context.l10n;
    final missing = summary.newBookCount;

    return showDialog<ImportMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.importTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${l10n.importFileDated(summary.exportedAt)} '
              '${l10n.importBookCount(summary.bookCount)}, '
              '${l10n.importReadingCount(summary.readingCount)}.',
            ),
            const SizedBox(height: 12),
            Text(
              l10n.importAlreadyPresent(
                summary.alreadyPresentCount,
                summary.libraryCount,
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.importChoice(missing < 0 ? 0 : missing)),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ImportMode.replace),
            child: Text(l10n.replaceAll),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ImportMode.merge),
            child: Text(l10n.merge),
          ),
        ],
      ),
    );
  }

  static String _describe(AppLocalizations l10n, ImportReport report) {
    final parts = <String>[
      if (report.mode == ImportMode.replace)
        l10n.libraryReplaced
      else
        l10n.backupMerged,
      l10n.booksImported(report.booksImported),
      if (report.booksSkipped > 0) l10n.booksSkipped(report.booksSkipped),
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
