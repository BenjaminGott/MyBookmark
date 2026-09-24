import 'package:biblivre/data/prefs/preferences_service.dart';
import 'package:biblivre/domain/models/app_language.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Fichier à part : le stockage simulé resterait installé pour les tests de
// preferences_service_test.dart, qui vérifient justement son absence.
void main() {
  test('garde la langue choisie d\'un lancement à l\'autre', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final first = await PreferencesService.load();
    expect(first.language, isNull);

    await first.setLanguage(AppLanguage.english);

    final second = await PreferencesService.load();
    expect(second.language, AppLanguage.english);
  });
}
