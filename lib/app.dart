import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'domain/models/app_theme_mode.dart';
import 'ui/home_shell.dart';
import 'ui/providers/settings_providers.dart';

/// Racine de l'application : thèmes clair et sombre, interface en français.
class BiblivreApp extends ConsumerWidget {
  const BiblivreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Biblivre',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (mode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      locale: const Locale('fr'),
      supportedLocales: const <Locale>[Locale('fr')],
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}
