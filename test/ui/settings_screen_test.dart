import 'package:biblivre/core/failure.dart';
import 'package:biblivre/data/local/app_database.dart';
import 'package:biblivre/data/prefs/preferences_service.dart';
import 'package:biblivre/domain/models/app_language.dart';
import 'package:biblivre/domain/models/app_theme_mode.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/domain/repositories/file_exchange.dart';
import 'package:biblivre/l10n/app_localizations.dart';
import 'package:biblivre/ui/providers/database_providers.dart';
import 'package:biblivre/ui/providers/settings_providers.dart';
import 'package:biblivre/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../data/test_database.dart';

/// Un échange de fichiers sans système de fichiers : il note ce qu'on lui
/// demande d'écrire, et rend le contenu qu'on lui a préparé.
class _FakeFileExchange implements FileExchange {
  /// Contenu rendu par le sélecteur, ou `null` pour simuler une annulation.
  String? toReturn;

  /// Simule un utilisateur qui referme la boîte d'enregistrement.
  bool cancelSave = false;
  AppException? failWith;

  String? savedFileName;
  String? savedContents;

  @override
  Future<bool> saveText({
    required String fileName,
    required String contents,
  }) async {
    final error = failWith;
    if (error != null) {
      throw error;
    }
    if (cancelSave) {
      return false;
    }
    savedFileName = fileName;
    savedContents = contents;
    return true;
  }

  @override
  Future<String?> pickText() async {
    final error = failWith;
    if (error != null) {
      throw error;
    }
    return toReturn;
  }
}

void main() {
  late AppDatabase db;
  late _FakeFileExchange files;

  setUpAll(() {
    initializeDateFormatting('fr_FR');
  });

  setUp(() {
    db = createTestDatabase();
    files = _FakeFileExchange();
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> settle(WidgetTester tester) async {
    for (var frame = 0; frame < 6; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpSettings(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          fileExchangeProvider.overrideWithValue(files),
          // Le thème n'est pas l'objet de ces tests : on court-circuite les
          // préférences, qui exigeraient un canal de plateforme.
          themeModeProvider.overrideWith(_FixedThemeMode.new),
          // Préférences sans stockage : la langue reste celle du système.
          preferencesServiceProvider.overrideWithValue(
            PreferencesService(null),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await settle(tester);
  }

  void settingsTest(
    String description,
    Future<void> Function(WidgetTester) body,
  ) {
    testWidgets(description, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));
    });
  }

  settingsTest('change la langue de l\'interface', (tester) async {
    await pumpSettings(tester);

    // Sans choix enregistré, la langue du téléphone est cochée.
    expect(find.text('Langue du téléphone'), findsOne);

    await tester.tap(find.text('English'));
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsScreen)),
    );
    expect(container.read(languageProvider), AppLanguage.english);
  });

  settingsTest('exporte la bibliothèque dans un fichier daté', (tester) async {
    await db.booksDao.addBook(title: 'Dune', shelf: Shelf.read);
    await pumpSettings(tester);

    await tester.tap(find.text('Exporter ma bibliothèque'));
    await settle(tester);

    expect(files.savedFileName, matches(r'^mybookmark-\d{4}-\d{2}-\d{2}\.json$'));
    expect(files.savedContents, contains('Dune'));
    expect(find.textContaining('Bibliothèque exportée'), findsOne);
  });

  settingsTest('ne dit rien si l\'utilisateur annule l\'enregistrement',
      (tester) async {
    files.cancelSave = true;
    await pumpSettings(tester);

    await tester.tap(find.text('Exporter ma bibliothèque'));
    await settle(tester);

    expect(find.byType(SnackBar), findsNothing);
  });

  settingsTest('importe sans rien demander quand la base est vide',
      (tester) async {
    files.toReturn = '{"version": 1, "books": [{"title": "Dune", '
        '"readings": [{"shelf": "read", "isCurrent": true}]}]}';
    await pumpSettings(tester);

    await tester.tap(find.text('Importer une sauvegarde'));
    await settle(tester);

    // Pas de dialogue : il n'y a rien à écraser.
    expect(find.text('Importer cette sauvegarde ?'), findsNothing);
    expect(await db.booksDao.watchLibrary().first, hasLength(1));
    expect(find.textContaining('1 livre importé'), findsOne);
  });

  settingsTest('demande fusion ou remplacement sur une base non vide',
      (tester) async {
    await db.booksDao.addBook(title: 'Zazie', shelf: Shelf.toRead);
    files.toReturn = '{"version": 1, "books": [{"title": "Dune", '
        '"readings": [{"shelf": "read", "isCurrent": true}]}]}';
    await pumpSettings(tester);

    await tester.tap(find.text('Importer une sauvegarde'));
    await settle(tester);

    expect(find.text('Importer cette sauvegarde ?'), findsOne);
    expect(find.textContaining('1 livre, 1 lecture'), findsOne);

    await tester.tap(find.widgetWithText(FilledButton, 'Fusionner'));
    await settle(tester);

    final titles = (await db.booksDao.watchLibrary().first)
        .map((item) => item.book.title)
        .toList();
    expect(titles, containsAll(<String>['Dune', 'Zazie']));
  });

  settingsTest('remplace toute la bibliothèque sur demande', (tester) async {
    await db.booksDao.addBook(title: 'Zazie', shelf: Shelf.toRead);
    files.toReturn = '{"version": 1, "books": [{"title": "Dune", '
        '"readings": [{"shelf": "read", "isCurrent": true}]}]}';
    await pumpSettings(tester);

    await tester.tap(find.text('Importer une sauvegarde'));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Remplacer tout'));
    await settle(tester);

    final titles = (await db.booksDao.watchLibrary().first)
        .map((item) => item.book.title)
        .toList();
    expect(titles, <String>['Dune']);
    expect(find.textContaining('Bibliothèque remplacée'), findsOne);
  });

  settingsTest('n\'écrit rien si l\'utilisateur annule le dialogue',
      (tester) async {
    await db.booksDao.addBook(title: 'Zazie', shelf: Shelf.toRead);
    files.toReturn = '{"version": 1, "books": [{"title": "Dune", '
        '"readings": [{"shelf": "read", "isCurrent": true}]}]}';
    await pumpSettings(tester);

    await tester.tap(find.text('Importer une sauvegarde'));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
    await settle(tester);

    final titles = (await db.booksDao.watchLibrary().first)
        .map((item) => item.book.title)
        .toList();
    expect(titles, <String>['Zazie']);
  });

  settingsTest('explique un fichier illisible', (tester) async {
    files.toReturn = 'ceci n\'est pas du json';
    await pumpSettings(tester);

    await tester.tap(find.text('Importer une sauvegarde'));
    await settle(tester);

    expect(
      find.text('Ce fichier n\'est pas une sauvegarde valide.'),
      findsOne,
    );
    expect(await db.booksDao.watchLibrary().first, isEmpty);
  });

  settingsTest('explique un fichier venu d\'une version plus récente',
      (tester) async {
    files.toReturn = '{"version": 99, "books": []}';
    await pumpSettings(tester);

    await tester.tap(find.text('Importer une sauvegarde'));
    await settle(tester);

    expect(find.textContaining('version plus récente'), findsOne);
  });
}

/// Un thème figé, pour ne pas dépendre de `shared_preferences` dans les tests.
class _FixedThemeMode extends ThemeModeController {
  @override
  AppThemeMode build() => AppThemeMode.system;
}
