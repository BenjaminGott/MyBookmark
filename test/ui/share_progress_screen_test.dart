import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:biblivre/core/failure.dart';
import 'package:biblivre/domain/models/book.dart';
import 'package:biblivre/domain/models/library_item.dart';
import 'package:biblivre/domain/models/reading_entry.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/domain/repositories/image_sharing.dart';
import 'package:biblivre/ui/providers/share_providers.dart';
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

  setUp(() {
    sharing = _FakeImageSharing();
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
          if (cover != null)
            coverImageProviderFactory.overrideWithValue(
              (url) => MemoryImage(cover),
            ),
        ],
        child: MaterialApp(home: ShareProgressScreen(item: item)),
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

  void screenTest(String description, Future<void> Function(WidgetTester) body) {
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

  screenTest('partage un PNG de 1080 × 1920', (tester) async {
    await pumpScreen(tester, _item());

    await tapShare(tester);

    expect(sharing.calls, 1);
    expect(sharing.fileName, 'biblivre-progression.png');
    expect(sharing.text, 'Dune — Frank Herbert');

    final bytes = sharing.bytes!;
    // Signature PNG, puis dimensions lues dans l'en-tête.
    expect(bytes.sublist(1, 4), <int>[0x50, 0x4E, 0x47]);
    final size = _pngSize(bytes);
    expect(size.width, 1080);
    expect(size.height, 1920);
  });

  screenTest('se passe d\'auteur dans le texte partagé', (tester) async {
    await pumpScreen(tester, _item(author: null));

    await tapShare(tester);

    expect(sharing.text, 'Dune');
  });

  screenTest('explique un échec de partage sans planter', (tester) async {
    sharing.failWith = const FileAccessException('Le partage a échoué.');
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
    expect(_pngSize(sharing.bytes!), (width: 1080, height: 1920));
  });

  screenTest('retombe sur la variante sans image si la couverture échoue',
      (tester) async {
    await pumpScreen(
      tester,
      _item(coverUrl: 'https://covers.openlibrary.org/b/id/1-L.jpg'),
      cover: Uint8List.fromList(<int>[0, 1, 2, 3]),
    );

    // Des octets qui ne sont pas une image : la carte se rabat sur son
    // substitut au lieu d'échouer.
    expect(find.byIcon(Icons.menu_book_outlined), findsOne);
    expect(find.byType(Image), findsNothing);

    await tapShare(tester);
    expect(_pngSize(sharing.bytes!), (width: 1080, height: 1920));
  });

  screenTest('partage aussi un livre sans nombre de pages', (tester) async {
    await pumpScreen(tester, _item(pageCount: null));

    expect(find.text('En cours'), findsOne);

    await tapShare(tester);

    expect(_pngSize(sharing.bytes!).width, 1080);
  });
}
