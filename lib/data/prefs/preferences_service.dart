import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_theme_mode.dart';

/// Les réglages simples, hors base de données : thème et objectif annuel.
///
/// `shared_preferences` suffit ici : ce sont deux valeurs isolées, sans
/// relation avec les livres, et les perdre serait sans gravité.
class PreferencesService {
  PreferencesService(this._preferences);

  static const String _themeKey = 'theme_mode';
  static const String _goalPrefix = 'reading_goal_';

  final SharedPreferences _preferences;

  static Future<PreferencesService> load() async {
    return PreferencesService(await SharedPreferences.getInstance());
  }

  AppThemeMode get themeMode =>
      AppThemeMode.fromWire(_preferences.getString(_themeKey));

  Future<void> setThemeMode(AppThemeMode mode) =>
      _preferences.setString(_themeKey, mode.wireName);

  /// Objectif de lecture d'une année, prévu pour le défi annuel à venir.
  int? readingGoal(int year) => _preferences.getInt('$_goalPrefix$year');

  Future<void> setReadingGoal(int year, int? books) {
    final key = '$_goalPrefix$year';
    if (books == null || books <= 0) {
      return _preferences.remove(key);
    }
    return _preferences.setInt(key, books);
  }
}
