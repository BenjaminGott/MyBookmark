import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'domain/models/app_language.dart';
import 'domain/models/app_theme_mode.dart';
import 'l10n/app_localizations.dart';
import 'ui/home_shell.dart';
import 'ui/providers/settings_providers.dart';
import 'ui/welcome/welcome_screen.dart';

/// Racine de l'application : thèmes clair et sombre, interface en français
/// ou en anglais.
class MyBookmarkApp extends ConsumerWidget {
  const MyBookmarkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final code = language?.languageCode;

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (mode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      // Sans choix explicite, Flutter prend la langue du téléphone parmi
      // celles prises en charge, et l'anglais à défaut.
      locale: code == null ? null : Locale(code),
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback: resolveLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Premier lancement : on demande la langue avant tout le reste.
      home: language == null ? const WelcomeScreen() : const HomeShell(),
    );
  }
}

/// Choisit la langue de l'interface parmi celles du téléphone : la première
/// prise en charge, sinon l'anglais.
Locale resolveLocale(List<Locale>? preferred, Iterable<Locale> supported) {
  for (final locale in preferred ?? const <Locale>[]) {
    for (final candidate in supported) {
      if (candidate.languageCode == locale.languageCode) {
        return candidate;
      }
    }
  }
  return const Locale('en');
}

/// La langue que prendrait l'interface en suivant le téléphone.
AppLanguage systemLanguage() {
  final locales = WidgetsBinding.instance.platformDispatcher.locales;
  final resolved = resolveLocale(locales, AppLocalizations.supportedLocales);
  return resolved.languageCode == 'fr'
      ? AppLanguage.french
      : AppLanguage.english;
}
