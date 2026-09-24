import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/prefs/preferences_service.dart';
import 'ui/providers/settings_providers.dart';

Future<void> main() async {
  // Obligatoire avant tout appel de plateforme : `shared_preferences` passe par
  // un canal qui n'existe pas encore sans cette ligne, et l'exception se
  // produirait avant le premier écran — l'application n'afficherait que du noir.
  WidgetsFlutterBinding.ensureInitialized();

  // Charge les noms de mois et de jours de chaque langue avant le premier
  // écran.
  await initializeDateFormatting();

  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(
          await PreferencesService.loadOrDefaults(),
        ),
      ],
      child: const MyBookmarkApp(),
    ),
  );
}
