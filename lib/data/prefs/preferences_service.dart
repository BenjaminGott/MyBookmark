import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_language.dart';
import '../../domain/models/app_theme_mode.dart';

/// Les réglages simples, hors base de données : thème, langue et objectif
/// annuel.
///
/// `shared_preferences` suffit ici : ce sont deux valeurs isolées, sans
/// relation avec les livres, et les perdre serait sans gravité.
class PreferencesService {
  PreferencesService(this._preferences);

  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _goalPrefix = 'reading_goal_';

  /// Nul quand les préférences n'ont pas pu être chargées.
  final SharedPreferences? _preferences;

  static Future<PreferencesService> load() async {
    return PreferencesService(await SharedPreferences.getInstance());
  }

  /// Charge les préférences, ou repart sur les valeurs par défaut.
  ///
  /// Un réglage d'apparence ne vaut pas un écran noir au lancement : si le
  /// stockage du téléphone refuse de répondre, l'application démarre quand même
  /// avec le thème système, et les écritures suivantes seront simplement sans
  /// effet.
  static Future<PreferencesService> loadOrDefaults() async {
    try {
      return await load();
    } on Object {
      return PreferencesService(null);
    }
  }

  AppThemeMode get themeMode =>
      AppThemeMode.fromWire(_preferences?.getString(_themeKey));

  Future<void> setThemeMode(AppThemeMode mode) async {
    await _preferences?.setString(_themeKey, mode.wireName);
  }

  /// La langue choisie, ou `null` si l'utilisateur n'en a encore choisi
  /// aucune (premier lancement).
  AppLanguage? get language =>
      AppLanguage.fromWire(_preferences?.getString(_languageKey));

  Future<void> setLanguage(AppLanguage language) async {
    await _preferences?.setString(_languageKey, language.wireName);
  }

  /// Objectif de lecture d'une année, prévu pour le défi annuel à venir.
  int? readingGoal(int year) => _preferences?.getInt('$_goalPrefix$year');

  Future<void> setReadingGoal(int year, int? books) async {
    final preferences = _preferences;
    if (preferences == null) {
      return;
    }
    final key = '$_goalPrefix$year';
    if (books == null || books <= 0) {
      await preferences.remove(key);
      return;
    }
    await preferences.setInt(key, books);
  }
}
