import 'dart:convert';
import 'dart:io';

import 'package:biblivre/app.dart';
import 'package:biblivre/data/prefs/preferences_service.dart';
import 'package:biblivre/domain/models/app_language.dart';
import 'package:biblivre/l10n/app_localizations.dart';
import 'package:biblivre/ui/providers/settings_providers.dart';
import 'package:biblivre/ui/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

Iterable<String> _messages(Map<String, dynamic> arb) =>
    arb.keys.where((key) => !key.startsWith('@'));

void main() {
  // Comme au lancement de l'application (voir main.dart).
  setUpAll(initializeDateFormatting);

  group('Traductions', () {
    test('chaque texte français a sa traduction anglaise', () {
      final french = _messages(_arb('fr')).toSet();
      final english = _messages(_arb('en')).toSet();

      expect(english.difference(french), isEmpty, reason: 'clés en trop');
      expect(french.difference(english), isEmpty, reason: 'clés manquantes');
    });

    test('le nom de l\'application suit la langue', () {
      expect(
        lookupAppLocalizations(const Locale('fr')).appTitle,
        'Mon marque-page',
      );
      expect(lookupAppLocalizations(const Locale('en')).appTitle, 'MyBookmark');
    });

    test('les pluriels sont accordés dans les deux langues', () {
      final fr = lookupAppLocalizations(const Locale('fr'));
      final en = lookupAppLocalizations(const Locale('en'));

      expect(fr.pageCount(1), '1 page');
      expect(fr.pageCount(658), '658 pages');
      expect(en.starCount(1), '1 star');
      expect(en.starCount(3), '3 stars');
      expect(fr.booksImported(2), '2 livres importés');
      expect(en.booksImported(1), '1 book imported');
    });

    test('les dates sont écrites à la façon de chaque langue', () {
      final date = DateTime(2026, 3, 14);

      expect(
        lookupAppLocalizations(const Locale('fr')).longDate(date),
        '14 mars 2026',
      );
      expect(
        lookupAppLocalizations(const Locale('en')).longDate(date),
        'March 14, 2026',
      );
    });
  });

  group('Langue par défaut', () {
    test('suit la langue du téléphone quand elle est prise en charge', () {
      expect(
        resolveLocale(const <Locale>[
          Locale('fr', 'BE'),
        ], AppLocalizations.supportedLocales),
        const Locale('fr'),
      );
    });

    test('passe à l\'anglais pour une langue non prise en charge', () {
      expect(
        resolveLocale(const <Locale>[
          Locale('de'),
          Locale('ja'),
        ], AppLocalizations.supportedLocales),
        const Locale('en'),
      );
    });
  });

  group('Premier lancement', () {
    Future<ProviderContainer> pumpWelcome(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final container = ProviderContainer(
        overrides: [
          preferencesServiceProvider.overrideWithValue(
            PreferencesService(null),
          ),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WelcomeScreen(),
          ),
        ),
      );
      await tester.pump();
      return container;
    }

    testWidgets('propose les deux langues', (tester) async {
      await pumpWelcome(tester);

      expect(find.text('Français'), findsOne);
      expect(find.text('English'), findsOne);
    });

    testWidgets('se traduit dès qu\'on choisit une langue', (tester) async {
      final container = await pumpWelcome(tester);

      await tester.tap(find.text('English'));
      await tester.pump();

      expect(find.text('Choose your language'), findsOne);
      expect(find.text('Continue'), findsOne);
      // Rien n'est enregistré avant d'avoir continué.
      expect(container.read(languageProvider), isNull);

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(container.read(languageProvider), AppLanguage.english);
    });

    testWidgets('enregistre le français', (tester) async {
      final container = await pumpWelcome(tester);

      await tester.tap(find.text('Français'));
      await tester.pump();
      await tester.tap(find.text('Continuer'));
      await tester.pump();

      expect(container.read(languageProvider), AppLanguage.french);
    });
  });
}
