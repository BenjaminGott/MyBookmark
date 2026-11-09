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
  static const String _reviewKey = 'review_asked_at';
  static const String _yearReviewPrefix = 'year_review_';
  static const String _noticePrefix = 'year_review_notice_';

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

  /// La dernière fois que l'avis Google Play a été demandé.
  DateTime? get reviewAskedAt {
    final millis = _preferences?.getInt(_reviewKey);
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> setReviewAskedAt(DateTime when) async {
    await _preferences?.setInt(_reviewKey, when.millisecondsSinceEpoch);
  }

  /// Le bilan figé d'une année, en JSON, ou `null` s'il n'a pas été créé.
  String? yearReviewJson(int year) =>
      _preferences?.getString('$_yearReviewPrefix$year');

  Future<void> setYearReviewJson(int year, String json) async {
    await _preferences?.setString('$_yearReviewPrefix$year', json);
  }

  /// Combien de fois la fenêtre [season] (« january », « february ») du
  /// bilan de [year] a été montrée.
  int yearReviewNoticeCount(String season, int year) =>
      _preferences?.getInt('$_noticePrefix${season}_$year') ?? 0;

  Future<void> setYearReviewNoticeCount(
    String season,
    int year,
    int count,
  ) async {
    await _preferences?.setInt('$_noticePrefix${season}_$year', count);
  }

  /// Les années qui ont un bilan enregistré.
  Set<int> get savedYearReviews => <int>{
        for (final key in _preferences?.getKeys() ?? const <String>{})
          if (key.startsWith(_yearReviewPrefix))
            ?int.tryParse(key.substring(_yearReviewPrefix.length)),
      };
}
