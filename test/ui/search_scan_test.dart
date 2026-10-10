import 'package:biblivre/core/cancellation.dart';
import 'package:biblivre/domain/models/book_search_result.dart';
import 'package:biblivre/domain/repositories/search_repository.dart';
import 'package:biblivre/l10n/app_localizations.dart';
import 'package:biblivre/ui/providers/database_providers.dart';
import 'package:biblivre/ui/providers/search_providers.dart';
import 'package:biblivre/ui/scan/isbn_scanner_screen.dart';
import 'package:biblivre/ui/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/test_database.dart';

/// Note les recherches faites, et rend un livre pour chacune.
class _RecordingSearch implements SearchRepository {
  final List<String> queries = <String>[];

  @override
  Stream<List<BookSearchResult>> search(
    String rawQuery, {
    CancellationToken? token,
  }) {
    queries.add(rawQuery);
    return Stream<List<BookSearchResult>>.value(const <BookSearchResult>[
      BookSearchResult(olKey: '/works/OL1W', title: 'Le Petit Prince'),
    ]);
  }

  @override
  Future<String?> loadDescription(
    String olKey, {
    CancellationToken? token,
  }) async => null;
}

void main() {
  testWidgets('le scanner remplit la recherche avec l\'ISBN lu', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final search = _RecordingSearch();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          searchRepositoryProvider.overrideWithValue(search),
          // Pas d'appareil photo en test : le « scanner » lit tout de suite.
          isbnScannerProvider.overrideWithValue((_) async => '9782070612758'),
        ],
        child: const MaterialApp(
          locale: Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SearchScreen(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byTooltip('Scanner un code-barres'));
    await tester.pump();
    // La recherche part après le petit délai de frappe.
    await tester.pump(const Duration(seconds: 1));

    expect(find.widgetWithText(TextField, '9782070612758'), findsOne);
    expect(search.queries, contains('9782070612758'));
    expect(find.text('Le Petit Prince'), findsOne);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
