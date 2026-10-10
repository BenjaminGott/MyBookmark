import 'dart:convert';
import 'dart:io';

import 'package:biblivre/app.dart';
import 'package:biblivre/data/prefs/preferences_service.dart';
import 'package:biblivre/domain/models/app_language.dart';
import 'package:biblivre/l10n/app_localizations.dart';
import 'package:biblivre/ui/l10n/language_dropdown.dart';
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
    for (final code in <String>['en', 'es', 'de', 'it', 'pt']) {
      test('chaque texte français a sa traduction en « $code »', () {
        final french = _messages(_arb('fr')).toSet();
        final translated = _messages(_arb(code)).toSet();

        expect(translated.difference(french), isEmpty, reason: 'clés en trop');
        expect(
          french.difference(translated),
          isEmpty,
          reason: 'clés manquantes',
        );
      });
    }

    test('chaque langue sait formater ses pluriels et ses dates', () {
      final date = DateTime(2026, 3, 14);
      for (final locale in AppLocalizations.supportedLocales) {
        final l10n = lookupAppLocalizations(locale);
        // Aucun message ne doit lever, et chaque pluriel dépend du nombre.
        expect(l10n.pageCount(1), isNot(l10n.pageCount(2)), reason: '$locale');
        expect(l10n.booksImported(0), isNotEmpty, reason: '$locale');
        expect(
          l10n.importAlreadyPresent(3, 10),
          contains('10'),
          reason: '$locale',
        );
        expect(l10n.longDate(date), contains('2026'), reason: '$locale');
      }
    });

    test('les nouvelles langues sont bien traduites', () {
      expect(
        lookupAppLocalizations(const Locale('es')).navLibrary,
        'Biblioteca',
      );
      expect(
        lookupAppLocalizations(const Locale('de')).navSettings,
        'Einstellungen',
      );
      expect(
        lookupAppLocalizations(const Locale('it')).shelfToRead,
        'Da leggere',
      );
      expect(lookupAppLocalizations(const Locale('pt')).shelfReading, 'Lendo');
      expect(
        lookupAppLocalizations(
          const Locale('de'),
        ).longDate(DateTime(2026, 3, 14)),
        '14. März 2026',
      );
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
          Locale('ru'),
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

    Future<void> openLanguages(WidgetTester tester) async {
      await tester.tap(find.byType(LanguageDropdown));
      await tester.pumpAndSettle();
    }

    Future<void> chooseLanguage(WidgetTester tester, String name) async {
      await openLanguages(tester);
      await tester.tap(find.text(name).last);
      await tester.pumpAndSettle();
    }

    testWidgets('propose toutes les langues', (tester) async {
      await pumpWelcome(tester);
      await openLanguages(tester);

      for (final name in <String>[
        'Français',
        'English',
        'Español',
        'Deutsch',
        'Italiano',
        'Português',
      ]) {
        expect(find.text(name), findsWidgets, reason: name);
      }
    });

    testWidgets('se traduit aussi en allemand', (tester) async {
      await pumpWelcome(tester);

      await chooseLanguage(tester, 'Deutsch');

      expect(find.text('Wähle deine Sprache'), findsOne);
      expect(find.text('Weiter'), findsOne);
    });

    testWidgets('se traduit dès qu\'on choisit une langue', (tester) async {
      final container = await pumpWelcome(tester);

      await chooseLanguage(tester, 'English');

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

      await chooseLanguage(tester, 'Français');
      await tester.tap(find.text('Continuer'));
      await tester.pump();

      expect(container.read(languageProvider), AppLanguage.french);
    });
  });
}
