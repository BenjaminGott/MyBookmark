import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

void main() {
  // Charge les noms de mois et de jours en français avant le premier écran.
  initializeDateFormatting('fr_FR');

  runApp(const ProviderScope(child: BiblivreApp()));
}
