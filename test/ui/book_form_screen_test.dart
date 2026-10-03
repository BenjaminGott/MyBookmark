import 'package:biblivre/data/local/app_database.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/l10n/app_localizations.dart';
import 'package:biblivre/ui/book_form/book_form_screen.dart';
import 'package:biblivre/ui/providers/book_providers.dart';
import 'package:biblivre/ui/providers/database_providers.dart';
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

  Future<void> settle(WidgetTester tester) async {
    for (var frame = 0; frame < 6; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpForm(WidgetTester tester, Widget form) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: form,
        ),
      ),
    );
    await settle(tester);
  }

  void formTest(String description, Future<void> Function(WidgetTester) body) {
    testWidgets(description, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));
    });
  }

  Future<void> fill(WidgetTester tester, String label, String value) async {
    await tester.enterText(find.widgetWithText(TextFormField, label), value);
  }

  formTest('ajoute un livre saisi à la main', (tester) async {
    await pumpForm(tester, const BookFormScreen.create());

    await fill(tester, 'Titre *', 'Carnet de bord');
    await fill(tester, 'Auteur', 'Moi');
    await fill(tester, 'Nombre de pages', '120');
    await fill(tester, 'Année de parution', '2026');
    await tester.tap(find.text('En cours'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Ajouter'));
    await settle(tester);

    final items = await db.booksDao.watchLibrary().first;
    final item = items.single;
    expect(item.book.title, 'Carnet de bord');
    expect(item.book.author, 'Moi');
    expect(item.book.pageCount, 120);
    expect(item.book.firstPublishYear, 2026);
    expect(item.book.isManual, isTrue);
    expect(item.book.olKey, isNull);
    expect(item.shelf, Shelf.reading);
  });

  formTest('le bouton reste au-dessus de la barre de navigation', (
    tester,
  ) async {
    // Un téléphone étroit, dessiné jusqu'au bord, avec une barre de
    // navigation de 48 points en bas.
    await pumpForm(tester, const BookFormScreen.create());
    tester.view.physicalSize = const Size(400, 700);
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    await settle(tester);

    // Tout en bas du formulaire.
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await settle(tester);

    final button = find.widgetWithText(FilledButton, 'Ajouter');

    expect(tester.getBottomLeft(button).dy, lessThanOrEqualTo(700 - 48));
  });

  formTest('refuse un titre vide', (tester) async {
    await pumpForm(tester, const BookFormScreen.create());

    await tester.tap(find.widgetWithText(FilledButton, 'Ajouter'));
    await settle(tester);

    expect(find.text('Le titre est obligatoire.'), findsOne);
    expect(await db.booksDao.watchLibrary().first, isEmpty);
  });

  formTest('refuse un nombre de pages nul', (tester) async {
    await pumpForm(tester, const BookFormScreen.create());

    await fill(tester, 'Titre *', 'Carnet');
    await fill(tester, 'Nombre de pages', '0');
    await tester.tap(find.widgetWithText(FilledButton, 'Ajouter'));
    await settle(tester);

    expect(
      find.text('Indiquez un nombre de pages supérieur à zéro.'),
      findsOne,
    );
    expect(await db.booksDao.watchLibrary().first, isEmpty);
  });

  formTest('refuse une année absurde', (tester) async {
    await pumpForm(tester, const BookFormScreen.create());

    await fill(tester, 'Titre *', 'Carnet');
    await fill(tester, 'Année de parution', '9999');
    await tester.tap(find.widgetWithText(FilledButton, 'Ajouter'));
    await settle(tester);

    final nextYear = DateTime.now().year + 1;
    expect(find.text('Indiquez une année entre 1 et $nextYear.'), findsOne);
  });

  formTest('accepte un livre sans auteur ni pages', (tester) async {
    await pumpForm(tester, const BookFormScreen.create());

    await fill(tester, 'Titre *', 'Manuscrit anonyme');
    await tester.tap(find.widgetWithText(FilledButton, 'Ajouter'));
    await settle(tester);

    final book = (await db.booksDao.watchLibrary().first).single.book;
    expect(book.title, 'Manuscrit anonyme');
    expect(book.author, isNull);
    expect(book.pageCount, isNull);
  });

  formTest('corrige un nombre de pages faux venu de l\'API', (tester) async {
    final bookId = await db.booksDao.addBook(
      title: 'Dune',
      olKey: '/works/OL893415W',
      author: 'Frank Herbert',
      pageCount: 12,
      shelf: Shelf.reading,
    );
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final book = await container.read(bookRepositoryProvider).findById(bookId);

    await pumpForm(tester, BookFormScreen.edit(book: book!));

    // Le formulaire est prérempli avec les valeurs existantes.
    expect(find.text('Dune'), findsOne);
    expect(find.text('12'), findsOne);

    await fill(tester, 'Nombre de pages', '658');
    await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
    await settle(tester);

    final corrected = await db.booksDao.findById(bookId);
    expect(corrected!.pageCount, 658);
    // La clé Open Library est conservée : le livre reste le même ouvrage.
    expect(corrected.olKey, '/works/OL893415W');
    expect(corrected.isManual, isFalse);
  });

  formTest('efface un auteur en vidant le champ', (tester) async {
    final bookId = await db.booksDao.addBook(
      title: 'Dune',
      author: 'Erreur de saisie',
      shelf: Shelf.toRead,
    );
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final book = await container.read(bookRepositoryProvider).findById(bookId);

    await pumpForm(tester, BookFormScreen.edit(book: book!));
    await fill(tester, 'Auteur', '');
    await tester.tap(find.widgetWithText(FilledButton, 'Enregistrer'));
    await settle(tester);

    expect((await db.booksDao.findById(bookId))!.author, isNull);
  });

  formTest('ne propose pas d\'étagère en correction', (tester) async {
    final bookId = await db.booksDao.addBook(
      title: 'Dune',
      shelf: Shelf.reading,
    );
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final book = await container.read(bookRepositoryProvider).findById(bookId);

    await pumpForm(tester, BookFormScreen.edit(book: book!));

    // L'étagère se change depuis la fiche, pas depuis ce formulaire.
    expect(find.text('Étagère'), findsNothing);
  });
}
