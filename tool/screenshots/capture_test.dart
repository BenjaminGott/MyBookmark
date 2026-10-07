// Captures d'écran de l'app pour le site, le Play Store et la vidéo.
//
// Ce n'est pas un test : c'est un script qui passe par `flutter test` pour
// dessiner les vrais écrans, avec les vraies polices, sans téléphone.
//
//     python3 tool/screenshots/fetch_covers.py
//     flutter test tool/screenshots/capture_test.dart
//     python3 tool/screenshots/compose.py <dossier de sortie> --lang en|fr
//
// Deux séries, anglaise et française, chacune avec ses livres. Les PNG bruts
// sont écrits dans build/screenshots/raw/<langue>-*.png, en 1080 × 2340.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:biblivre/core/cancellation.dart';
import 'package:biblivre/core/theme/app_theme.dart';
import 'package:biblivre/data/local/app_database.dart';
import 'package:biblivre/data/prefs/preferences_service.dart';
import 'package:biblivre/domain/models/book_search_result.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/domain/repositories/search_repository.dart';
import 'package:biblivre/domain/repositories/story_sharing.dart';
import 'package:biblivre/l10n/app_localizations.dart';
import 'package:biblivre/ui/book_detail/book_detail_screen.dart';
import 'package:biblivre/ui/home_shell.dart';
import 'package:biblivre/ui/providers/database_providers.dart';
import 'package:biblivre/ui/providers/search_providers.dart';
import 'package:biblivre/ui/providers/settings_providers.dart';
import 'package:biblivre/ui/providers/share_providers.dart';
import 'package:biblivre/ui/search/search_screen.dart';
import 'package:biblivre/ui/settings/settings_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test/data/test_database.dart';

/// Taille d'un téléphone récent : 360 × 780 points, soit 1080 × 2340 pixels.
const Size _logical = Size(360, 780);
const double _ratio = 3;

final Directory _build = Directory('build/screenshots');
String _cover(String name) =>
    Uri.file(File('${_build.path}/covers/$name.png').absolute.path).toString();

/// Roboto et les icônes Material, tirées du SDK Flutter : sans elles, les
/// tests dessinent chaque lettre comme un carré.
Future<void> _loadFonts() async {
  var dir = File(Platform.resolvedExecutable).parent;
  Directory? fonts;
  while (dir.path != dir.parent.path) {
    final candidate = Directory('${dir.path}/cache/artifacts/material_fonts');
    final nested = Directory('${dir.path}/bin/cache/artifacts/material_fonts');
    if (candidate.existsSync()) {
      fonts = candidate;
      break;
    }
    if (nested.existsSync()) {
      fonts = nested;
      break;
    }
    dir = dir.parent;
  }
  if (fonts == null) {
    throw StateError('Polices Material introuvables dans le SDK Flutter.');
  }

  Future<ByteData> read(String name) async =>
      ByteData.sublistView(await File('${fonts!.path}/$name').readAsBytes());

  final roboto = FontLoader('Roboto');
  for (final weight in <String>['Light', 'Regular', 'Medium', 'Bold']) {
    roboto.addFont(read('Roboto-$weight.ttf'));
  }
  await roboto.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(read('MaterialIcons-Regular.otf'))).load();
}

/// Un livre de la bibliothèque de démonstration.
class _Book {
  const _Book(
    this.key,
    this.title,
    this.author,
    this.pages,
    this.year,
    this.shelf, {
    this.page,
    this.rating,
    this.olKey,
  });

  final String key;
  final String title;
  final String author;
  final int pages;
  final int year;
  final Shelf shelf;
  final int? page;
  final int? rating;
  final String? olKey;
}

/// Une série de captures : sa langue, sa bibliothèque, sa recherche.
class _Series {
  const _Series({
    required this.lang,
    required this.library,
    required this.query,
    required this.results,
    required this.shareLabel,
  });

  final String lang;

  /// Du plus ancien au plus récent : la bibliothèque montre l'inverse. Le
  /// dernier est le livre mis en avant (fiche et carte de partage).
  final List<_Book> library;
  final String query;
  final List<_Book> results;
  final String shareLabel;

  String get featured => library.last.key;
}

const List<_Series> _series = <_Series>[
  _Series(
    lang: 'en',
    library: <_Book>[
      _Book(
        'jane-eyre',
        'Jane Eyre',
        'Charlotte Brontë',
        532,
        1847,
        Shelf.toRead,
      ),
      _Book('dracula', 'Dracula', 'Bram Stoker', 418, 1897, Shelf.toRead),
      _Book(
        'frankenstein',
        'Frankenstein',
        'Mary Shelley',
        280,
        1818,
        Shelf.read,
        rating: 4,
      ),
      _Book(
        'pride',
        'Pride and Prejudice',
        'Jane Austen',
        432,
        1813,
        Shelf.read,
        rating: 5,
        olKey: '/works/OL66554W',
      ),
      _Book(
        'prince-en',
        'The Little Prince',
        'Antoine de Saint-Exupéry',
        96,
        1943,
        Shelf.reading,
        page: 72,
      ),
      _Book(
        'knight-en',
        'The Knight and the Moth',
        'Rachel Gillig',
        400,
        2025,
        Shelf.reading,
        page: 248,
      ),
    ],
    query: 'austen',
    results: <_Book>[
      _Book(
        'pride',
        'Pride and Prejudice',
        'Jane Austen',
        432,
        1813,
        Shelf.read,
        olKey: '/works/OL66554W',
      ),
      _Book('emma', 'Emma', 'Jane Austen', 474, 1815, Shelf.toRead),
      _Book(
        'sense',
        'Sense and Sensibility',
        'Jane Austen',
        409,
        1811,
        Shelf.toRead,
      ),
      _Book('persuasion', 'Persuasion', 'Jane Austen', 249, 1817, Shelf.toRead),
    ],
    shareLabel: 'Share my progress',
  ),
  _Series(
    lang: 'fr',
    library: <_Book>[
      _Book(
        'bovary',
        'Madame Bovary',
        'Gustave Flaubert',
        480,
        1857,
        Shelf.toRead,
      ),
      _Book(
        'mousquetaires',
        'Les Trois Mousquetaires',
        'Alexandre Dumas',
        880,
        1844,
        Shelf.toRead,
      ),
      _Book(
        'monte-cristo',
        'Le Comte de Monte-Cristo',
        'Alexandre Dumas',
        1504,
        1844,
        Shelf.read,
        rating: 4,
      ),
      _Book(
        'miserables',
        'Les Misérables',
        'Victor Hugo',
        1488,
        1862,
        Shelf.read,
        rating: 5,
        olKey: '/works/OL1115639W',
      ),
      _Book(
        'prince-fr',
        'Le Petit Prince',
        'Antoine de Saint-Exupéry',
        96,
        1943,
        Shelf.reading,
        page: 72,
      ),
      _Book(
        'knight-fr',
        'Le chevalier et la phalène',
        'Rachel Gillig',
        400,
        2025,
        Shelf.reading,
        page: 248,
      ),
    ],
    query: 'hugo',
    results: <_Book>[
      _Book(
        'miserables',
        'Les Misérables',
        'Victor Hugo',
        1488,
        1862,
        Shelf.read,
        olKey: '/works/OL1115639W',
      ),
      _Book(
        'notre-dame',
        'Notre-Dame de Paris',
        'Victor Hugo',
        640,
        1831,
        Shelf.toRead,
      ),
      _Book(
        'contemplations',
        'Les Contemplations',
        'Victor Hugo',
        512,
        1856,
        Shelf.toRead,
      ),
      _Book(
        'quatrevingt',
        'Quatrevingt-treize',
        'Victor Hugo',
        480,
        1874,
        Shelf.toRead,
      ),
    ],
    shareLabel: 'Partager ma progression',
  ),
];

/// Remplit la base avec la bibliothèque d'une série.
Future<Map<String, int>> _seed(AppDatabase db, _Series series) async {
  final ids = <String, int>{};
  final now = DateTime(2026, 9, 24);
  final books = series.library;

  for (var index = 0; index < books.length; index++) {
    final book = books[index];
    final id = await db.booksDao.addBook(
      title: book.title,
      author: book.author,
      pageCount: book.pages,
      shelf: book.shelf,
      firstPublishYear: book.year,
      olKey: book.olKey,
      coverUrl: _cover(book.key),
      now: now.subtract(Duration(days: (books.length - index) * 5)),
    );
    ids[book.key] = id;

    final entry = await db.readingEntriesDao.findCurrentEntry(id);
    final page = book.page;
    if (page != null) {
      await db.readingEntriesDao.updateCurrentPage(
        entryId: entry!.id,
        page: page,
      );
      await db.readingEntriesDao.updateEntry(
        entry.id,
        startedAt: Value<DateTime?>(now.subtract(const Duration(days: 12))),
      );
    }
    if (book.rating != null) {
      await db.readingEntriesDao.updateEntry(
        entry!.id,
        rating: Value<int?>(book.rating),
      );
    }
  }
  return ids;
}

/// La recherche de la série, sans réseau.
class _DemoSearch implements SearchRepository {
  const _DemoSearch(this.results);

  final List<_Book> results;

  @override
  Stream<List<BookSearchResult>> search(
    String rawQuery, {
    CancellationToken? token,
  }) => Stream<List<BookSearchResult>>.value(<BookSearchResult>[
    for (final book in results)
      BookSearchResult(
        olKey: book.olKey ?? 'apple:${book.key}',
        title: book.title,
        author: book.author,
        firstPublishYear: book.year,
        pageCount: book.pages,
        artworkUrl: _cover(book.key),
      ),
  ]);

  @override
  Future<String?> loadDescription(
    String olKey, {
    CancellationToken? token,
  }) async => null;
}

/// Instagram « installé », pour que le bouton Story apparaisse.
class _DemoStory implements StorySharing {
  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> sharePng({
    required Uint8List bytes,
    required String fileName,
    required bool asSticker,
    required Color topColor,
    required Color bottomColor,
  }) async {}
}

void main() {
  final frame = GlobalKey();

  setUpAll(_loadFonts);

  /// Laisse le temps de lire la base et de décoder les couvertures, qui
  /// passent par de vraies entrées-sorties.
  Future<void> settle(WidgetTester tester) async {
    for (var round = 0; round < 8; round++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 80)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  for (final series in _series) {
    group(series.lang, () {
      late AppDatabase db;
      late Map<String, int> ids;

      setUp(() async {
        db = createTestDatabase();
        ids = await _seed(db, series);
      });

      tearDown(() => db.close());

      Future<void> pumpApp(WidgetTester tester, Widget home) async {
        // `flutter test` remplace les ombres par un trait noir : on veut les
        // vraies. Remis en place à la capture, le binding le vérifiant.
        debugDisableShadows = false;
        tester.view.physicalSize = _logical * _ratio;
        tester.view.devicePixelRatio = _ratio;
        // La barre d'état d'un vrai téléphone, dessinée par compose.py.
        tester.view.padding = const FakeViewPadding(top: 24 * _ratio);
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseProvider.overrideWithValue(db),
              searchRepositoryProvider.overrideWithValue(
                _DemoSearch(series.results),
              ),
              storySharingProvider.overrideWithValue(_DemoStory()),
              preferencesServiceProvider.overrideWithValue(
                PreferencesService(null),
              ),
            ],
            child: RepaintBoundary(
              key: frame,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                locale: Locale(series.lang),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: home,
              ),
            ),
          ),
        );
        // Comme sur un écran tactile : pas de contour de focus clavier.
        // Réglé après le montage, le binding de test le remettant à zéro.
        FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.alwaysTouch;
        await settle(tester);
      }

      Future<void> capture(WidgetTester tester, String name) async {
        await settle(tester);
        final boundary =
            frame.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: _ratio);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          final file = File('${_build.path}/raw/${series.lang}-$name.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
        });
        debugDisableShadows = true;
        // Démonte avant la fin : le flux drift laisserait un minuteur.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 10));
      }

      testWidgets('1-library', (tester) async {
        await pumpApp(tester, const HomeShell());
        await capture(tester, '1-library');
      });

      testWidgets('2-book', (tester) async {
        await pumpApp(tester, BookDetailScreen(bookId: ids[series.featured]!));
        await capture(tester, '2-book');
      });

      testWidgets('3-search', (tester) async {
        await pumpApp(tester, const SearchScreen());
        await tester.enterText(find.byType(TextField), series.query);
        await tester.pump(const Duration(milliseconds: 400));
        await capture(tester, '3-search');
      });

      testWidgets('4-share', (tester) async {
        await pumpApp(tester, BookDetailScreen(bookId: ids[series.featured]!));
        await tester.tap(find.byTooltip('Actions'));
        await settle(tester);
        await tester.tap(find.text(series.shareLabel));
        await settle(tester);
        await settle(tester);
        await capture(tester, '4-share');
      });

      // Pour la vidéo : les réglages, défilés jusqu'à l'import Goodreads.
      testWidgets('5-settings', (tester) async {
        await pumpApp(tester, const SettingsScreen());
        await tester.drag(find.byType(ListView), const Offset(0, -260));
        await capture(tester, '5-settings');
      });
    });
  }
}
