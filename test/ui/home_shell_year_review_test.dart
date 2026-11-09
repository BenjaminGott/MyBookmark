import 'package:biblivre/data/local/app_database.dart';
import 'package:biblivre/data/prefs/preferences_service.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/l10n/app_localizations.dart';
import 'package:biblivre/ui/home_shell.dart';
import 'package:biblivre/ui/providers/database_providers.dart';
import 'package:biblivre/ui/providers/settings_providers.dart';
import 'package:biblivre/ui/year_review/year_review_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/test_database.dart';

void main() {
  late AppDatabase db;
  late PreferencesService preferences;

  setUp(() async {
    db = createTestDatabase();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await PreferencesService.load();
    // Un livre terminé en 2026 : il y a un bilan 2026.
    final bookId = await db.booksDao.addBook(
      title: 'Dune',
      shelf: Shelf.reading,
      now: DateTime(2026, 3, 1),
    );
    final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
    await db.readingEntriesDao.moveToShelf(
      entryId: entry!.id,
      shelf: Shelf.read,
      now: DateTime(2026, 4, 1),
    );
  });

  tearDown(() async {
    await db.close();
  });

  /// Un lancement de l'app à la date [now], démonté proprement ensuite.
  Future<void> launch(WidgetTester tester, DateTime now) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          preferencesServiceProvider.overrideWithValue(preferences),
          clockProvider.overrideWithValue(() => now),
        ],
        child: const MaterialApp(
          locale: Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeShell(),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    for (var frame = 0; frame < 10; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  }

  testWidgets(
    'janvier : onglet du bilan, fenêtre aux deux premiers lancements',
    (tester) async {
      final january = DateTime(2027, 1, 4);

      await launch(tester, january);
      expect(find.text('Bilan 2026'), findsWidgets);
      expect(find.text('Votre année 2026 en lecture'), findsOne);
      // « Voir mon bilan » mène à l'onglet.
      await tester.tap(find.text('Voir mon bilan'));
      for (var frame = 0; frame < 10; frame++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('MON ANNÉE EN LECTURE'), findsOne);
      await close(tester);

      await launch(tester, january);
      expect(find.text('Votre année 2026 en lecture'), findsOne);
      await tester.tap(find.text('Plus tard'));
      await tester.pump(const Duration(milliseconds: 300));
      await close(tester);

      // Troisième lancement : l'onglet reste, la fenêtre ne revient plus.
      await launch(tester, january);
      expect(find.text('Votre année 2026 en lecture'), findsNothing);
      expect(find.text('Bilan 2026'), findsWidgets);
      await close(tester);
    },
  );

  testWidgets('février : plus d\'onglet, fenêtre « déménagé » deux fois', (
    tester,
  ) async {
    final february = DateTime(2027, 2, 2);

    for (var launchNumber = 1; launchNumber <= 2; launchNumber++) {
      await launch(tester, february);
      expect(find.text('Votre bilan 2026 a déménagé'), findsOne);
      await tester.tap(find.text('Compris'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Bilan 2026'), findsNothing);
      await close(tester);
    }

    await launch(tester, february);
    expect(find.text('Votre bilan 2026 a déménagé'), findsNothing);
    await close(tester);
  });

  testWidgets('le reste de l\'année : ni onglet ni fenêtre', (tester) async {
    await launch(tester, DateTime(2027, 5, 10));
    expect(find.text('Bilan 2026'), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    await close(tester);
  });
}
