import 'package:biblivre/data/local/app_database.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/ui/book_detail/book_detail_screen.dart';
import 'package:biblivre/ui/providers/database_providers.dart';
import 'package:biblivre/ui/widgets/star_rating.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../data/test_database.dart';

void main() {
  late AppDatabase db;

  setUpAll(() {
    // Les dates affichées sont en français : les noms de mois doivent être
    // chargés comme ils le sont au démarrage de l'application.
    initializeDateFormatting('fr_FR');
  });

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> settle(WidgetTester tester) async {
    for (var frame = 0; frame < 6; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpDetail(WidgetTester tester, int bookId) async {
    // La fiche est longue : sans une fenêtre haute, les cartes du bas ne sont
    // jamais construites par la liste et les recherches échouent à tort.
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: BookDetailScreen(bookId: bookId)),
      ),
    );
    await settle(tester);
  }

  /// Un test d'écran démonté avant la fin, pour laisser partir le minuteur de
  /// fermeture des flux drift.
  void detailTest(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));
    });
  }

  Future<int> addDune({
    int? pageCount = 658,
    Shelf shelf = Shelf.reading,
    String? description,
  }) {
    return db.booksDao.addBook(
      title: 'Dune',
      author: 'Frank Herbert',
      pageCount: pageCount,
      firstPublishYear: 1965,
      description: description,
      shelf: shelf,
      now: DateTime(2026, 1, 15),
    );
  }

  detailTest('affiche les métadonnées du livre', (tester) async {
    final bookId = await addDune(description: 'Une histoire de sable.');

    await pumpDetail(tester, bookId);

    expect(find.text('Dune'), findsOne);
    expect(find.text('Frank Herbert'), findsOne);
    expect(find.text('1965 · 658 pages'), findsOne);
    expect(find.text('Une histoire de sable.'), findsOne);
  });

  detailTest('dit clairement qu\'il n\'y a pas de résumé', (tester) async {
    final bookId = await addDune();

    await pumpDetail(tester, bookId);

    expect(
      find.text('Open Library ne fournit pas de résumé pour ce livre.'),
      findsOne,
    );
  });

  detailTest('annonce un nombre de pages inconnu', (tester) async {
    final bookId = await addDune(pageCount: null);

    await pumpDetail(tester, bookId);

    expect(find.text('1965 · Nombre de pages inconnu'), findsOne);
    // Pas de barre de progression trompeuse quand le total est inconnu.
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  detailTest('enregistre la page en cours et calcule le pourcentage',
      (tester) async {
    final bookId = await addDune(pageCount: 200);
    await pumpDetail(tester, bookId);

    await tester.enterText(
      find.widgetWithText(TextField, 'Page en cours'),
      '50',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
    await settle(tester);

    expect(find.text('Page 50 sur 200 · 25 %'), findsOne);
  });

  detailTest('ramène une page au-delà du total et le signale', (tester) async {
    final bookId = await addDune(pageCount: 200);
    await pumpDetail(tester, bookId);

    await tester.enterText(
      find.widgetWithText(TextField, 'Page en cours'),
      '9000',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
    await settle(tester);

    expect(find.text('Page 200 sur 200 · 100 %'), findsOne);
    expect(
      find.text(
        'Ce livre fait 200 pages : la progression a été enregistrée à la '
        'page 200.',
      ),
      findsOne,
    );
  });

  detailTest('note le livre puis retire la note', (tester) async {
    final bookId = await addDune(shelf: Shelf.read);
    await pumpDetail(tester, bookId);

    final stars = find.descendant(
      of: find.byType(StarRating),
      matching: find.byType(IconButton),
    );

    await tester.tap(stars.at(3)); // la quatrième étoile
    await settle(tester);
    var entry = await db.readingEntriesDao.findCurrentEntry(bookId);
    expect(entry!.rating, 4);

    // Retoucher la même étoile efface la note.
    await tester.tap(stars.at(3));
    await settle(tester);
    entry = await db.readingEntriesDao.findCurrentEntry(bookId);
    expect(entry!.rating, isNull);
  });

  detailTest('enregistre un avis sans note', (tester) async {
    final bookId = await addDune(shelf: Shelf.read);
    await pumpDetail(tester, bookId);

    await tester.enterText(
      find.widgetWithText(TextField, 'Mon avis'),
      'Un monument.',
    );
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer l\'avis'));
    await settle(tester);

    final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
    expect(entry!.review, 'Un monument.');
    expect(entry.rating, isNull);
    expect(find.text('Avis enregistré'), findsOne);
  });

  detailTest('change d\'étagère et date la lecture', (tester) async {
    final bookId = await addDune(shelf: Shelf.toRead);
    await pumpDetail(tester, bookId);

    await tester.tap(find.text('En cours'));
    await settle(tester);

    final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
    expect(entry!.shelf, Shelf.reading);
    expect(entry.startedAt, isNotNull);
  });

  detailTest('affiche la date de début en français', (tester) async {
    final bookId = await addDune(shelf: Shelf.reading);
    final entry = await db.readingEntriesDao.findCurrentEntry(bookId);
    await db.readingEntriesDao.updateEntry(
      entry!.id,
      startedAt: Value<DateTime?>(DateTime(2026, 5, 10)),
    );
    await pumpDetail(tester, bookId);

    expect(find.text('10 mai 2026'), findsOne);
  });

  detailTest('garde la note de la lecture précédente après une relecture',
      (tester) async {
    final bookId = await addDune(shelf: Shelf.read);
    final first = await db.readingEntriesDao.findCurrentEntry(bookId);
    await db.readingEntriesDao.updateEntry(
      first!.id,
      review: const Value<String?>('Lu à vingt ans.'),
      finishedAt: Value<DateTime?>(DateTime(2026, 2, 1)),
    );
    await db.readingEntriesDao.startReread(bookId: bookId);

    await pumpDetail(tester, bookId);

    expect(find.text('Lectures précédentes (1)'), findsOne);
    expect(find.text('Lu à vingt ans.'), findsOne);
  });

  detailTest('explique qu\'un livre supprimé n\'existe plus', (tester) async {
    final bookId = await addDune();
    await db.booksDao.deleteBook(bookId);

    await pumpDetail(tester, bookId);

    expect(find.text('Livre supprimé'), findsOne);
  });
}
