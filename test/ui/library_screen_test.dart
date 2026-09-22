import 'package:biblivre/data/local/app_database.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/ui/library/library_screen.dart';
import 'package:biblivre/ui/providers/database_providers.dart';
import 'package:biblivre/ui/widgets/star_rating.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../data/test_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  /// Avance de quelques images.
  ///
  /// `pumpAndSettle` ne convient pas ici : un indicateur de chargement animé
  /// reprogramme une image à l'infini et ferait tourner le test sans fin.
  Future<void> settle(WidgetTester tester) async {
    for (var frame = 0; frame < 6; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// Monte l'écran sur une base en mémoire : le vrai dépôt, les vraies requêtes.
  Future<void> pumpLibrary(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: LibraryScreen()),
      ),
    );
    await settle(tester);
  }

  /// Un test d'écran, démonté proprement avant la fin.
  ///
  /// Sans ce démontage, la fermeture du flux drift programme un minuteur au
  /// moment du nettoyage, et `flutter test` refuse de terminer sur un minuteur
  /// en attente.
  void libraryTest(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      // Une durée explicite est nécessaire : `pump()` sans argument ne fait que
      // vider les micro-tâches et ne déclenche pas le minuteur de drift.
      await tester.pump(const Duration(milliseconds: 10));
    });
  }

  libraryTest('explique que la bibliothèque est vide', (tester) async {
    await pumpLibrary(tester);

    expect(find.text('Votre bibliothèque est vide'), findsOne);
    expect(
      find.text('Cherchez un livre pour commencer à suivre vos lectures.'),
      findsOne,
    );
  });

  libraryTest('affiche les livres avec leur auteur', (tester) async {
    await db.booksDao.addBook(
      title: 'Dune',
      author: 'Frank Herbert',
      pageCount: 658,
      shelf: Shelf.toRead,
    );
    await db.booksDao.addBook(title: 'Carnet', shelf: Shelf.toRead);

    await pumpLibrary(tester);

    expect(find.text('Dune'), findsOne);
    expect(find.text('Frank Herbert'), findsOne);
    expect(find.text('À lire · 658 pages'), findsOne);
    // Un livre sans auteur ne laisse pas un trou dans la liste.
    expect(find.text('Auteur inconnu'), findsOne);
  });

  libraryTest('montre la progression d\'un livre en cours', (tester) async {
    final bookId = await db.booksDao.addBook(
      title: 'Dune',
      pageCount: 200,
      shelf: Shelf.reading,
    );
    final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
    await db.readingEntriesDao
        .updateCurrentPage(entryId: entry!.id, page: 50);

    await pumpLibrary(tester);

    expect(find.text('25 %'), findsOne);
  });

  libraryTest('signale un livre lu mais pas encore noté', (tester) async {
    await db.booksDao.addBook(title: 'Dune', shelf: Shelf.read);

    await pumpLibrary(tester);

    expect(find.text('Lu · pas encore noté'), findsOne);
  });

  libraryTest('filtre sur une étagère', (tester) async {
    await db.booksDao.addBook(title: 'À lire un jour', shelf: Shelf.toRead);
    await db.booksDao.addBook(title: 'Déjà lu', shelf: Shelf.read);

    await pumpLibrary(tester);
    expect(find.text('À lire un jour'), findsOne);
    expect(find.text('Déjà lu'), findsOne);

    await tester.tap(find.widgetWithText(FilterChip, 'Lu'));
    await settle(tester);

    expect(find.text('Déjà lu'), findsOne);
    expect(find.text('À lire un jour'), findsNothing);
  });

  libraryTest('explique qu\'une étagère filtrée est vide', (tester) async {
    await db.booksDao.addBook(title: 'À lire un jour', shelf: Shelf.toRead);

    await pumpLibrary(tester);
    await tester.tap(find.widgetWithText(FilterChip, 'Lu'));
    await settle(tester);

    expect(find.text('Rien dans « Lu »'), findsOne);
  });

  libraryTest('trie par titre, puis inverse le sens', (tester) async {
    await db.booksDao.addBook(title: 'Zazie', shelf: Shelf.toRead);
    await db.booksDao.addBook(title: 'Anna', shelf: Shelf.toRead);

    await pumpLibrary(tester);

    Future<void> chooseSort(String label) async {
      await tester.tap(find.byTooltip('Trier'));
      await settle(tester);
      await tester.tap(find.text(label).last);
      await settle(tester);
    }

    await chooseSort('Titre');
    var titles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title! as Text).data)
        .toList();
    expect(titles, <String>['Anna', 'Zazie']);

    // Rechoisir le même critère inverse l'ordre.
    await chooseSort('Titre');
    titles = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((tile) => (tile.title! as Text).data)
        .toList();
    expect(titles, <String>['Zazie', 'Anna']);
  });

  libraryTest('affiche la note des livres lus', (tester) async {
    final bookId = await db.booksDao.addBook(title: 'Dune', shelf: Shelf.read);
    final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
    await db.readingEntriesDao
        .updateEntry(entry!.id, rating: const Value<int?>(4));

    await pumpLibrary(tester);

    expect(tester.widget<StarRating>(find.byType(StarRating)).rating, 4);
  });
}
