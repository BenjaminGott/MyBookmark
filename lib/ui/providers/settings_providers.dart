import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/files/file_picker_exchange.dart';
import '../../data/prefs/preferences_service.dart';
import '../../data/repositories/backup_repository_json.dart';
import '../../domain/models/app_theme_mode.dart';
import '../../domain/repositories/backup_repository.dart';
import '../../domain/repositories/file_exchange.dart';
import 'database_providers.dart';
import 'search_providers.dart';

/// Les préférences, chargées avant le premier écran dans `main`.
///
/// Ce provider est remplacé au démarrage : le lire sans l'avoir fourni est un
/// oubli de câblage, pas un cas à gérer à l'exécution.
final Provider<PreferencesService> preferencesServiceProvider =
    Provider<PreferencesService>((ref) {
  throw UnimplementedError(
    'preferencesServiceProvider doit être fourni au démarrage.',
  );
});

/// Le thème choisi, lu au lancement puis conservé en mémoire.
class ThemeModeController extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() => ref.read(preferencesServiceProvider).themeMode;

  Future<void> select(AppThemeMode mode) async {
    state = mode;
    await ref.read(preferencesServiceProvider).setThemeMode(mode);
  }
}

final NotifierProvider<ThemeModeController, AppThemeMode> themeModeProvider =
    NotifierProvider<ThemeModeController, AppThemeMode>(ThemeModeController.new);

final Provider<BackupRepository> backupRepositoryProvider =
    Provider<BackupRepository>((ref) {
  return JsonBackupRepository(
    database: ref.watch(databaseProvider),
    normalizer: ref.watch(textNormalizerProvider),
  );
});

final Provider<FileExchange> fileExchangeProvider =
    Provider<FileExchange>((ref) => const FilePickerExchange());
