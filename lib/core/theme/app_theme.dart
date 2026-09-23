import 'package:flutter/material.dart';

/// Les deux thèmes de l'application, tirés des couleurs du logo.
class AppTheme {
  const AppTheme._();

  /// Le vert du fond du logo.
  static const Color green = Color(0xFF135450);

  /// Le jaune du livre-hibou.
  static const Color yellow = Color(0xFFF2C04F);

  /// Le blanc cassé de ses pages.
  static const Color paper = Color(0xFFF4F6F2);

  static ThemeData get light => _build(_lightScheme);
  static ThemeData get dark => _build(_darkScheme);

  /// En clair : le vert porte l'interface, le jaune la ponctue.
  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: green,
    brightness: Brightness.light,
  ).copyWith(
    primary: green,
    onPrimary: paper,
    // Le bouton flottant reprend le livre-hibou : jaune, texte vert.
    primaryContainer: yellow,
    onPrimaryContainer: green,
    secondaryContainer: const Color(0xFFF9E3AE),
    onSecondaryContainer: green,
    tertiary: const Color(0xFF7A5A00),
    tertiaryContainer: yellow,
    onTertiaryContainer: green,
  );

  /// En sombre : le logo tel quel, du jaune sur du vert.
  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: green,
    brightness: Brightness.dark,
  ).copyWith(
    primary: yellow,
    onPrimary: green,
    primaryContainer: const Color(0xFF1D6B66),
    onPrimaryContainer: paper,
    secondaryContainer: const Color(0xFF1D6B66),
    onSecondaryContainer: paper,
    tertiary: yellow,
    onTertiary: green,
  );

  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
