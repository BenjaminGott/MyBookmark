import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/prefs/preferences_service.dart';
import 'ui/providers/settings_providers.dart';

Future<void> main() async {
  // Charge les noms de mois et de jours en français avant le premier écran.
  await initializeDateFormatting('fr_FR');

  // Le thème est lu avant le premier rendu : pas de passage du clair au sombre
  // sous les yeux de l'utilisateur au lancement.
  final preferences = await PreferencesService.load();

  runApp(
    ProviderScope(
      overrides: [preferencesServiceProvider.overrideWithValue(preferences)],
      child: const BiblivreApp(),
    ),
  );
}
