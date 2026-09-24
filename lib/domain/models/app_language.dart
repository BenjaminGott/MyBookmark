/// La langue de l'interface choisie par l'utilisateur.
///
/// Comme [AppThemeMode], la valeur stockée reste indépendante de Flutter.
enum AppLanguage {
  /// Suit la langue du téléphone (anglais si elle n'est pas prise en charge).
  system('system', null),
  french('fr', 'fr'),
  english('en', 'en'),
  spanish('es', 'es'),
  german('de', 'de'),
  italian('it', 'it'),
  portuguese('pt', 'pt');

  const AppLanguage(this.wireName, this.languageCode);

  final String wireName;

  /// Code de langue imposé à l'interface, ou `null` pour suivre le système.
  final String? languageCode;

  /// `null` quand aucune langue n'a encore été choisie : c'est le signe d'un
  /// premier lancement.
  static AppLanguage? fromWire(String? value) {
    for (final language in AppLanguage.values) {
      if (language.wireName == value) {
        return language;
      }
    }
    return null;
  }
}
