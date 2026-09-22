/// Le thème choisi par l'utilisateur.
///
/// Doublon volontaire de `ThemeMode` de Flutter : le domaine et la couche de
/// données n'importent pas Flutter, et la valeur stockée doit rester stable
/// indépendamment du framework.
enum AppThemeMode {
  system('system'),
  light('light'),
  dark('dark');

  const AppThemeMode(this.wireName);

  final String wireName;

  static AppThemeMode fromWire(String? value) {
    for (final mode in AppThemeMode.values) {
      if (mode.wireName == value) {
        return mode;
      }
    }
    return AppThemeMode.system;
  }
}
