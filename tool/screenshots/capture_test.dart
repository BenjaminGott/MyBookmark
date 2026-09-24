// Captures d'écran de l'app pour le site (et plus tard le Play Store).
//
// Ce n'est pas un test : c'est un script qui passe par `flutter test` pour
// dessiner les vrais écrans, avec les vraies polices, sans téléphone.
//
//     python3 tool/screenshots/covers.py
//     flutter test tool/screenshots/capture_test.dart
//     python3 tool/screenshots/compose.py <dossier de sortie>
//
// Les PNG bruts sont écrits dans build/screenshots/raw/, en 1080 × 2340.
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

/// La bibliothèque de démonstration.
Future<Map<String, int>> _seed(AppDatabase db) async {
  final ids = <String, int>{};
  final dao = db.booksDao;
  final entries = db.readingEntriesDao;
  final now = DateTime(2026, 9, 24);

  Future<int> add(
    String key,
    String title,
    String author,
    int pages,
    Shelf shelf,
    int year, {
    int daysAgo = 0,
    String? olKey,
    String? description,
  }) async {
    final id = await dao.addBook(
      title: title,
      author: author,
      pageCount: pages,
      shelf: shelf,
      firstPublishYear: year,
      olKey: olKey,
      coverUrl: _cover(key),
      description: description,
      now: now.subtract(Duration(days: daysAgo)),
    );
    ids[key] = id;
    return id;
  }

  // Ajoutés du plus ancien au plus récent : la bibliothèque les montre dans
  // l'ordre inverse.
  await add(
    'gatsby',
    'The Great Gatsby',
    'F. Scott Fitzgerald',
    180,
    Shelf.read,
    1925,
    daysAgo: 40,
  );
  await add(
    'frankenstein',
    'Frankenstein',
    'Mary Shelley',
    280,
    Shelf.read,
    1818,
    daysAgo: 30,
  );
  await add(
    'pride',
    'Pride and Prejudice',
    'Jane Austen',
    432,
    Shelf.read,
    1813,
    daysAgo: 25,
    olKey: '/works/OL66554W',
  );
  await add(
    'little-women',
    'Little Women',
    'Louisa May Alcott',
    759,
    Shelf.toRead,
    1868,
    daysAgo: 20,
  );
  await add(
    'jane-eyre',
    'Jane Eyre',
    'Charlotte Brontë',
    532,
    Shelf.toRead,
    1847,
    daysAgo: 15,
  );
  await add(
    'dracula',
    'Dracula',
    'Bram Stoker',
    418,
    Shelf.toRead,
    1897,
    daysAgo: 10,
  );
  await add(
    'odyssey',
    'The Odyssey',
    'Homer',
    541,
    Shelf.reading,
    -700,
    daysAgo: 6,
  );
  await add(
    'moby-dick',
    'Moby-Dick',
    'Herman Melville',
    635,
    Shelf.reading,
    1851,
    daysAgo: 2,
    description:
        'Ishmael signs on to the whaler Pequod, only to discover that its '
        'captain, Ahab, has one purpose: to hunt down the white whale that '
        'took his leg. A sea story, an encyclopedia of whaling and a '
        'meditation on obsession, all at once.',
  );

  Future<void> progress(String key, int page, {int? rating}) async {
    final entry = await entries.findCurrentEntry(ids[key]!);
    await entries.updateCurrentPage(entryId: entry!.id, page: page);
    await entries.updateEntry(
      entry.id,
      startedAt: Value<DateTime?>(now.subtract(const Duration(days: 12))),
      rating: Value<int?>(rating),
    );
  }

  await progress('moby-dick', 412);
  await progress('odyssey', 136);
  for (final (key, rating) in <(String, int)>[
    ('pride', 5),
    ('frankenstein', 4),
    ('gatsby', 4),
  ]) {
    final entry = await entries.findCurrentEntry(ids[key]!);
    await entries.updateEntry(entry!.id, rating: Value<int?>(rating));
  }
  return ids;
}

/// La recherche « austen », sans réseau.
class _DemoSearch implements SearchRepository {
  @override
  Stream<List<BookSearchResult>> search(
    String rawQuery, {
    CancellationToken? token,
  }) => Stream<List<BookSearchResult>>.value(<BookSearchResult>[
    BookSearchResult(
      olKey: '/works/OL66554W',
      title: 'Pride and Prejudice',
      author: 'Jane Austen',
      firstPublishYear: 1813,
      pageCount: 432,
      artworkUrl: _cover('pride'),
    ),
    BookSearchResult(
      olKey: '/works/OL66562W',
      title: 'Emma',
      author: 'Jane Austen',
      firstPublishYear: 1815,
      pageCount: 474,
      artworkUrl: _cover('emma'),
    ),
    BookSearchResult(
      olKey: '/works/OL66534W',
      title: 'Sense and Sensibility',
      author: 'Jane Austen',
      firstPublishYear: 1811,
      pageCount: 409,
      artworkUrl: _cover('sense'),
    ),
    BookSearchResult(
      olKey: '/works/OL66508W',
      title: 'Persuasion',
      author: 'Jane Austen',
      firstPublishYear: 1817,
      pageCount: 249,
      artworkUrl: _cover('persuasion'),
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
  late AppDatabase db;
  late Map<String, int> ids;
  final frame = GlobalKey();

  setUpAll(_loadFonts);

  setUp(() async {
    db = createTestDatabase();
    ids = await _seed(db);
  });

  tearDown(() => db.close());

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

  Future<void> pumpApp(WidgetTester tester, Widget home) async {
    // `flutter test` remplace les ombres par un trait noir : on veut les
    // vraies. Remis en place à la capture, le binding le vérifiant.
    debugDisableShadows = false;
    tester.view.physicalSize = _logical * _ratio;
    tester.view.devicePixelRatio = _ratio;
    // La barre d'état et la barre de gestes d'un vrai téléphone.
    tester.view.padding = const FakeViewPadding(top: 24 * _ratio);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          searchRepositoryProvider.overrideWithValue(_DemoSearch()),
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
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: home,
          ),
        ),
      ),
    );
    // Comme sur un écran tactile : pas de contour de focus clavier. Réglé
    // après le montage, le binding de test le remettant à zéro.
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
      final file = File('${_build.path}/raw/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data!.buffer.asUint8List());
    });
    debugDisableShadows = true;
    // Démonte avant la fin : le flux drift laisserait un minuteur en attente.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 10));
  }

  testWidgets('1-library', (tester) async {
    await pumpApp(tester, const HomeShell());
    await capture(tester, '1-library');
  });

  testWidgets('2-book', (tester) async {
    await pumpApp(tester, BookDetailScreen(bookId: ids['moby-dick']!));
    await capture(tester, '2-book');
  });

  testWidgets('3-search', (tester) async {
    await pumpApp(tester, const SearchScreen());
    await tester.enterText(find.byType(TextField), 'austen');
    await tester.pump(const Duration(milliseconds: 400));
    await capture(tester, '3-search');
  });

  testWidgets('4-share', (tester) async {
    await pumpApp(tester, BookDetailScreen(bookId: ids['moby-dick']!));
    await tester.tap(find.byTooltip('Actions'));
    await settle(tester);
    await tester.tap(find.text('Share my progress'));
    await settle(tester);
    await settle(tester);
    await capture(tester, '4-share');
  });
}
