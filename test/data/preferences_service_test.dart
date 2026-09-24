import 'package:biblivre/data/prefs/preferences_service.dart';
import 'package:biblivre/domain/models/app_language.dart';
import 'package:biblivre/domain/models/app_theme_mode.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppThemeMode', () {
    test('relit la valeur stockée', () {
      expect(AppThemeMode.fromWire('dark'), AppThemeMode.dark);
      expect(AppThemeMode.fromWire('light'), AppThemeMode.light);
      expect(AppThemeMode.fromWire('system'), AppThemeMode.system);
    });

    test('retombe sur le thème système si la valeur est inconnue ou absente',
        () {
      expect(AppThemeMode.fromWire(null), AppThemeMode.system);
      expect(AppThemeMode.fromWire(''), AppThemeMode.system);
      expect(AppThemeMode.fromWire('sépia'), AppThemeMode.system);
    });
  });

  group('AppLanguage', () {
    test('relit la langue stockée', () {
      expect(AppLanguage.fromWire('fr'), AppLanguage.french);
      expect(AppLanguage.fromWire('en'), AppLanguage.english);
      expect(AppLanguage.fromWire('system'), AppLanguage.system);
    });

    test('ne choisit rien tant que la langue n\'a pas été choisie', () {
      // `null` déclenche l'écran d'accueil du premier lancement.
      expect(AppLanguage.fromWire(null), isNull);
      expect(AppLanguage.fromWire('klingon'), isNull);
    });
  });

  group('PreferencesService', () {
    // Ici, aucun canal de plateforme n'est disponible : `shared_preferences`
    // échoue exactement comme il le faisait au lancement de l'application.
    // Ce test garde la trace du démarrage à écran noir qu'on a corrigé.
    test('démarre sur les valeurs par défaut quand le stockage échoue',
        () async {
      final preferences = await PreferencesService.loadOrDefaults();

      expect(preferences.themeMode, AppThemeMode.system);
      expect(preferences.readingGoal(2026), isNull);
    });

    test('accepte les écritures sans rien casser quand le stockage échoue',
        () async {
      final preferences = await PreferencesService.loadOrDefaults();

      // Aucune de ces écritures ne doit lever : perdre un réglage
      // d'apparence est sans gravité, planter au démarrage ne l'est pas.
      await preferences.setThemeMode(AppThemeMode.dark);
      await preferences.setReadingGoal(2026, 40);
      await preferences.setReadingGoal(2026, null);

      expect(preferences.themeMode, AppThemeMode.system);
    });

    test('load() laisse remonter l\'échec, à la différence de loadOrDefaults',
        () async {
      // `load()` reste franc : c'est `loadOrDefaults` qui décide de dégrader.
      await expectLater(PreferencesService.load(), throwsA(isA<Object>()));
    });
  });
}
