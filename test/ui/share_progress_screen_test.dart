import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:biblivre/core/failure.dart';
import 'package:biblivre/domain/models/book.dart';
import 'package:biblivre/domain/models/library_item.dart';
import 'package:biblivre/domain/models/reading_entry.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/domain/repositories/image_saving.dart';
import 'package:biblivre/domain/repositories/image_sharing.dart';
import 'package:biblivre/domain/repositories/story_sharing.dart';
import 'package:biblivre/l10n/app_localizations.dart';
import 'package:biblivre/ui/providers/share_providers.dart';
import 'package:biblivre/ui/share/progress_card_palette.dart';
import 'package:biblivre/ui/share/progress_share_card.dart';
import 'package:biblivre/ui/share/share_progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un partage sans système : il retient l'image qu'on lui confie.
class _FakeImageSharing implements ImageSharing {
  AppException? failWith;
  Uint8List? bytes;
  String? fileName;
  String? text;

  int calls = 0;

  @override
  Future<void> sharePng({
    required Uint8List bytes,
    required String fileName,
    String? text,
  }) async {
    calls++;
    final error = failWith;
    if (error != null) {
      throw error;
    }
    this.bytes = bytes;
    this.fileName = fileName;
    this.text = text;
  }
}

/// Une galerie sans téléphone : elle retient l'image qu'on lui confie.
class _FakeImageSaving implements ImageSaving {
  AppException? failWith;
  Uint8List? bytes;
  String? name;

  int calls = 0;

  @override
  Future<void> savePng({required Uint8List bytes, required String name}) async {
    calls++;
    final error = failWith;
    if (error != null) {
      throw error;
    }
    this.bytes = bytes;
    this.name = name;
  }
}

/// Une story Instagram sans Instagram : elle retient ce qu'on lui confie.
class _FakeStorySharing implements StorySharing {
  _FakeStorySharing({this.available = true});

  final bool available;
  Uint8List? bytes;
  bool? asSticker;
  Color? topColor;
  Color? bottomColor;

  int calls = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> sharePng({
    required Uint8List bytes,
    required String fileName,
    required bool asSticker,
    required Color topColor,
    required Color bottomColor,
  }) async {
    calls++;
    this.bytes = bytes;
    this.asSticker = asSticker;
    this.topColor = topColor;
    this.bottomColor = bottomColor;
  }
}

LibraryItem _item({
  String? author = 'Frank Herbert',
  int? pageCount = 658,
  String? coverUrl,
}) {
  final now = DateTime(2026, 9, 22);
  return LibraryItem(
    book: Book(
      id: 1,
      title: 'Dune',
      author: author,
      pageCount: pageCount,
      coverUrl: coverUrl,
      isManual: false,
      createdAt: now,
      updatedAt: now,
    ),
    currentEntry: ReadingEntry(
      id: 1,
      bookId: 1,
      shelf: Shelf.reading,
      currentPage: 120,
      isCurrent: true,
      createdAt: now,
      updatedAt: now,
    ),
  );
}

/// Fabrique un PNG d'une seule couleur, pour tenir le rôle d'une couverture
/// sans dépendre du réseau ni d'un fichier de test.
Future<Uint8List> _solidPng(Color color, {int side = 8}) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, side.toDouble(), side.toDouble()),
    Paint()..color = color,
  );
  final image = await recorder.endRecording().toImage(side, side);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data!.buffer.asUint8List();
}

({int width, int height}) _pngSize(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  return (width: data.getUint32(16), height: data.getUint32(20));
}

void main() {
  late _FakeImageSharing sharing;
  late _FakeStorySharing story;
  late _FakeImageSaving saving;

  setUp(() {
    sharing = _FakeImageSharing();
    saving = _FakeImageSaving();
    story = _FakeStorySharing();
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    LibraryItem item, {
    Uint8List? cover,
  }) async {
    tester.view.physicalSize = const Size(1000, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          imageSharingProvider.overrideWithValue(sharing),
          storySharingProvider.overrideWithValue(story),
          imageSavingProvider.overrideWithValue(saving),
          if (cover != null)
            coverImageProviderFactory.overrideWithValue(
              (url) => MemoryImage(cover),
            ),
        ],
        child: MaterialApp(
          locale: const Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ShareProgressScreen(item: item),
        ),
      ),
    );
    await tester.pump();

    // La préparation décode la couverture et calcule sa palette : deux
    // opérations qui ont besoin du vrai ordonnanceur.
    for (var round = 0; round < 4; round++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  /// Appuie sur « Partager », puis laisse la capture se faire.
  ///
  /// `toImage` et `toByteData` passent par le moteur de rendu, donc par le vrai
  /// ordonnanceur : il faut rendre la main hors du temps simulé, ce que fait
  /// `runAsync`, sans appeler `pump` à l'intérieur — c'est interdit.
  Future<void> tapShare(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Partager'));
    await tester.pump();

    for (var round = 0; round < 4; round++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  void screenTest(
    String description,
    Future<void> Function(WidgetTester) body,
  ) {
    testWidgets(description, (tester) async {
      await body(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 10));
    });
  }

  screenTest('affiche l\'aperçu de la carte', (tester) async {
    await pumpScreen(tester, _item());

    expect(find.byType(ProgressShareCard), findsOne);
    expect(find.text('Dune'), findsOne);
    expect(find.text('page 120 sur 658'), findsOne);
    expect(find.widgetWithText(FilledButton, 'Partager'), findsOne);
  });

  /// Sélectionne un format dans le sélecteur.
  Future<void> chooseFormat(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await tester.pump();
  }

  screenTest('partage le bloc par défaut, sans rien choisir', (tester) async {
    await pumpScreen(tester, _item());

    await tapShare(tester);

    expect(sharing.calls, 1);
    expect(sharing.fileName, 'mybookmark-progress-card.png');
    expect(sharing.text, 'Dune — Frank Herbert');

    final bytes = sharing.bytes!;
    // Signature PNG, puis dimensions lues dans l'en-tête.
    expect(bytes.sublist(1, 4), <int>[0x50, 0x4E, 0x47]);
    expect(_pngSize(bytes), (width: 1080, height: 636));
  });

  screenTest('partage la story au format de référence', (tester) async {
    await pumpScreen(tester, _item());

    await chooseFormat(tester, 'Moyen');
    await tapShare(tester);

    expect(sharing.fileName, 'mybookmark-progress-story.png');
    // Le 9:16 attendu par les plateformes, quel que soit l'appareil.
    expect(_pngSize(sharing.bytes!), (width: 1080, height: 1920));
  });

  screenTest('revient au bloc après avoir changé d\'avis', (tester) async {
    await pumpScreen(tester, _item());

    await chooseFormat(tester, 'Moyen');
    await chooseFormat(tester, 'Bloc');
    await tapShare(tester);

    expect(sharing.fileName, 'mybookmark-progress-card.png');
    expect(_pngSize(sharing.bytes!), (width: 1080, height: 636));
  });

  ProgressCardPalette cardPalette(WidgetTester tester) =>
      tester.widget<ProgressShareCard>(find.byType(ProgressShareCard)).palette;

  screenTest('applique un fond proposé', (tester) async {
    await pumpScreen(tester, _item());

    final initial = cardPalette(tester);
    await tester.tap(find.text('Papier'));
    await tester.pump();

    final changed = cardPalette(tester);
    expect(changed.top, isNot(initial.top));
    expect(changed.family, PaletteFamily.light);
    // Le texte suit le fond, il n'est jamais laissé tel quel.
    expect(changed.foreground, isNot(initial.foreground));
  });

  screenTest('partage bien le fond choisi', (tester) async {
    await pumpScreen(tester, _item());

    await tester.tap(find.text('Papier'));
    await tester.pump();
    await tapShare(tester);

    expect(sharing.calls, 1);
    expect(_pngSize(sharing.bytes!), (width: 1080, height: 636));
  });

  screenTest('ouvre l\'éditeur de couleurs et sait renoncer', (tester) async {
    await pumpScreen(tester, _item());
    final initial = cardPalette(tester);

    await tester.tap(find.text('Ma couleur'));
    await tester.pumpAndSettle();
    expect(find.text('Mon dégradé'), findsOne);

    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();

    expect(find.text('Mon dégradé'), findsNothing);
    expect(cardPalette(tester).top, initial.top);
  });

  screenTest('applique un dégradé composé à la main', (tester) async {
    await pumpScreen(tester, _item());
    final initial = cardPalette(tester);

    await tester.tap(find.text('Ma couleur'));
    await tester.pumpAndSettle();

    // On déplace la teinte, puis on valide.
    await tester.drag(find.byType(Slider).first, const Offset(120, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Appliquer'));
    await tester.pumpAndSettle();

    final custom = cardPalette(tester);
    expect(custom.top, isNot(initial.top));
    // Même composé à la main, le fond garde un texte lisible.
    expect(
      (custom.backgroundLuminance - custom.foreground.computeLuminance()).abs(),
      greaterThan(0.3),
    );
  });

  screenTest('se passe d\'auteur dans le texte partagé', (tester) async {
    await pumpScreen(tester, _item(author: null));

    await tapShare(tester);

    expect(sharing.text, 'Dune');
  });

  screenTest('explique un échec de partage sans planter', (tester) async {
    sharing.failWith = const FileAccessException(AppErrorReason.shareFailed);
    await pumpScreen(tester, _item());

    await tapShare(tester);

    expect(sharing.calls, 1);
    expect(find.text('Le partage a échoué.'), findsOne);
    // L'écran reste utilisable : le bouton est de nouveau actif.
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  screenTest('dessine la couverture et en tire le dégradé', (tester) async {
    final cover = (await tester.runAsync(
      () => _solidPng(const Color(0xFF12407F)),
    ))!;

    await pumpScreen(
      tester,
      _item(coverUrl: 'https://covers.openlibrary.org/b/id/1-L.jpg'),
      cover: cover,
    );

    // La couverture est bien dessinée dans la carte.
    expect(find.byType(Image), findsOne);
    expect(find.byIcon(Icons.menu_book_outlined), findsNothing);

    // Le dégradé vient du bleu de la couverture, pas de la palette de secours.
    final card = tester.widget<ProgressShareCard>(
      find.byType(ProgressShareCard),
    );
    expect(card.palette.top.b, greaterThan(card.palette.top.r));
    expect(card.palette.foreground, Colors.white);

    await tapShare(tester);
    expect(_pngSize(sharing.bytes!), (width: 1080, height: 636));
  });

  screenTest('retombe sur la variante sans image si la couverture échoue', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      _item(coverUrl: 'https://covers.openlibrary.org/b/id/1-L.jpg'),
      cover: Uint8List.fromList(<int>[0, 1, 2, 3]),
    );

    // Des octets qui ne sont pas une image : le bloc se compose sans elle,
    // le texte prenant toute la largeur.
    expect(find.byType(Image), findsNothing);

    await tapShare(tester);
    expect(_pngSize(sharing.bytes!), (width: 1080, height: 636));

    // Les formats hauts, eux, montrent le substitut typographique.
    await chooseFormat(tester, 'Moyen');
    expect(find.byIcon(Icons.menu_book_outlined), findsOne);
    expect(find.byType(Image), findsNothing);
  });

  screenTest('partage aussi un livre sans nombre de pages', (tester) async {
    await pumpScreen(tester, _item(pageCount: null));

    expect(find.text('En cours'), findsOne);

    await tapShare(tester);

    expect(_pngSize(sharing.bytes!).width, 1080);
  });

  /// Appuie sur « Story Instagram », puis laisse la capture se faire.
  Future<void> tapStory(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(OutlinedButton, 'Story'));
    await tester.pump();
    for (var round = 0; round < 4; round++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  screenTest('envoie le bloc en sticker sur le dégradé de la carte', (
    tester,
  ) async {
    await pumpScreen(tester, _item());
    final palette = cardPalette(tester);

    await tapStory(tester);

    expect(story.calls, 1);
    expect(sharing.calls, 0);
    expect(story.asSticker, isTrue);
    expect(story.topColor, palette.top);
    expect(story.bottomColor, palette.bottom);
    expect(_pngSize(story.bytes!), (width: 1080, height: 636));
  });

  screenTest('envoie la story en fond, pas en sticker', (tester) async {
    await pumpScreen(tester, _item());

    await chooseFormat(tester, 'Moyen');
    await tapStory(tester);

    expect(story.asSticker, isFalse);
    expect(_pngSize(story.bytes!), (width: 1080, height: 1920));
  });

  screenTest('ne propose pas la story sans Instagram', (tester) async {
    story = _FakeStorySharing(available: false);
    await pumpScreen(tester, _item());

    expect(find.byTooltip('Partager en story Instagram'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Partager'), findsOne);
  });

  /// Appuie sur « Enregistrer », puis laisse la capture se faire.
  Future<void> tapSave(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Enregistrer dans la galerie'));
    await tester.pump();
    for (var round = 0; round < 4; round++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 60)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  screenTest('enregistre le bloc dans la galerie', (tester) async {
    await pumpScreen(tester, _item());

    await tapSave(tester);

    expect(saving.calls, 1);
    expect(sharing.calls, 0);
    expect(saving.name, startsWith('mybookmark-progress-card-'));
    // Le même PNG que celui partagé : coins transparents compris.
    expect(_pngSize(saving.bytes!), (width: 1080, height: 636));
    expect(find.text('Image enregistrée dans la galerie.'), findsOne);
  });

  screenTest('enregistre la story au format choisi', (tester) async {
    await pumpScreen(tester, _item());

    await chooseFormat(tester, 'Moyen');
    await tapSave(tester);

    expect(saving.name, startsWith('mybookmark-progress-story-'));
    expect(_pngSize(saving.bytes!), (width: 1080, height: 1920));
  });

  screenTest('explique un refus d\'accès à la galerie', (tester) async {
    saving.failWith = const FileAccessException(AppErrorReason.photoAccess);
    await pumpScreen(tester, _item());

    await tapSave(tester);

    expect(
      find.text('Autorisez l\'accès aux photos pour enregistrer l\'image.'),
      findsOne,
    );
    expect(find.text('Image enregistrée dans la galerie.'), findsNothing);
  });
}
