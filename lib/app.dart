import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';

/// Racine de l'application : thèmes clair et sombre, interface en français.
class BiblivreApp extends StatelessWidget {
  const BiblivreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biblivre',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: const Locale('fr'),
      supportedLocales: const <Locale>[Locale('fr')],
      localizationsDelegates: const <LocalizationsDelegate<Object>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const _HomePlaceholder(),
    );
  }
}

/// Écran temporaire, remplacé par « Ma bibliothèque » à la fonctionnalité 3.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Biblivre')),
      body: const Center(child: Text('Bibliothèque en construction')),
    );
  }
}
