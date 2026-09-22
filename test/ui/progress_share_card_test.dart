import 'dart:typed_data';
import 'dart:ui' show ImageByteFormat;

import 'package:biblivre/domain/models/book.dart';
import 'package:biblivre/domain/models/library_item.dart';
import 'package:biblivre/domain/models/reading_entry.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/ui/share/progress_card_palette.dart';
import 'package:biblivre/ui/share/progress_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

LibraryItem _item({
  String title = 'Dune',
  String? author = 'Frank Herbert',
  int? pageCount = 658,
  int currentPage = 120,
  Shelf shelf = Shelf.reading,
  int? rating,
  String? coverUrl,
}) {
  final now = DateTime(2026, 9, 22);
  return LibraryItem(
    book: Book(
      id: 1,
      title: title,
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
      shelf: shelf,
      currentPage: currentPage,
      isCurrent: true,
      rating: rating,
      createdAt: now,
      updatedAt: now,
    ),
  );
}

/// Largeur et hauteur lues dans l'en-tête IHDR d'un PNG.
///
/// Les 8 premiers octets sont la signature, puis la longueur et le type du
/// premier bloc ; la taille commence donc à l'octet 16.
({int width, int height}) _pngSize(Uint8List bytes) {
  final data = ByteData.sublistView(bytes);
  return (width: data.getUint32(16), height: data.getUint32(20));
}

void main() {
  group('ProgressCardPalette', () {
    test('écrit en blanc sur un dégradé sombre', () {
      final palette = ProgressCardPalette.fromColors(
        const Color(0xFF1B2A41),
        const Color(0xFF0B1220),
      );

      expect(palette.foreground, Colors.white);
    });

    test('écrit en sombre sur une couverture claire', () {
      final palette = ProgressCardPalette.fromColors(
        const Color(0xFFFFF3C4),
        const Color(0xFFFFE9A8),
      );

      expect(palette.foreground.computeLuminance(), lessThan(0.2));
      // Une couverture pastel garde une carte claire plutôt que d'être
      // assombrie jusqu'à perdre sa teinte.
      expect(palette.top.computeLuminance(), greaterThan(0.6));
    });

    test('n\'utilise jamais un fond blanc pur', () {
      final palette = ProgressCardPalette.fromColors(
        Colors.white,
        Colors.white,
      );

      expect(palette.top, isNot(Colors.white));
      expect(palette.top.computeLuminance(), lessThan(0.9));
    });

    test('n\'utilise jamais un fond noir pur', () {
      final palette = ProgressCardPalette.fromColors(
        Colors.black,
        Colors.black,
      );

      expect(palette.top, isNot(Colors.black));
      expect(palette.top.computeLuminance(), greaterThan(0.0));
    });

    test('garde toujours un écart de contraste entre texte et fond', () {
      // Une poignée de teintes très différentes : le texte doit rester lisible
      // sur chacune, c'est la garantie que la carte reste partageable.
      const samples = <Color>[
        Color(0xFFFFFFFF),
        Color(0xFF000000),
        Color(0xFFE53935),
        Color(0xFF1E88E5),
        Color(0xFFFDD835),
        Color(0xFF6D4C41),
        Color(0xFF00897B),
      ];

      for (final sample in samples) {
        final palette = ProgressCardPalette.fromColors(sample, sample);
        final background =
            (palette.top.computeLuminance() + palette.bottom.computeLuminance()) /
                2;
        final text = palette.foreground.computeLuminance();
        expect(
          (background - text).abs(),
          greaterThan(0.3),
          reason: 'contraste insuffisant pour ${sample.toARGB32()}',
        );
      }
    });

    test('retombe sur la palette de l\'application sans couleur', () {
      final fallback = ProgressCardPalette.fallback();
      final fromNothing = ProgressCardPalette.fromColors(null, null);

      expect(fromNothing.top, fallback.top);
      expect(fromNothing.bottom, fallback.bottom);
    });

    test('ne demande pas d\'analyse quand il n\'y a pas de couverture',
        () async {
      final palette = await ProgressCardPalette.fromCover(null);

      expect(palette.top, ProgressCardPalette.fallback().top);
    });
  });

  group('ProgressShareCard', () {
    final captureKey = GlobalKey();

    /// Monte la carte dans un parent volontairement plus grand qu'elle, et aux
    /// contraintes serrées : c'est le cas qui l'étirait avant correction.
    Future<void> pumpCard(WidgetTester tester, LibraryItem item) async {
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox.expand(
            child: ProgressShareCard(
              item: item,
              palette: ProgressCardPalette.fallback(),
              captureKey: captureKey,
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('montre les pages et le pourcentage', (tester) async {
      await pumpCard(tester, _item(currentPage: 120, pageCount: 658));

      expect(find.text('Dune'), findsOne);
      expect(find.text('Frank Herbert'), findsOne);
      expect(find.text('page 120 sur 658'), findsOne);
      expect(find.text('18'), findsOne);
      expect(find.text('%'), findsOne);
      expect(find.text('EN COURS DE LECTURE'), findsOne);
    });

    testWidgets('remplace le pourcentage par l\'étagère sans nombre de pages',
        (tester) async {
      await pumpCard(tester, _item(pageCount: null, currentPage: 120));

      expect(find.text('En cours'), findsOne);
      expect(find.text('%'), findsNothing);
      expect(find.text('page 120'), findsOne);
    });

    testWidgets('dit « nombre de pages inconnu » si rien n\'est saisi',
        (tester) async {
      await pumpCard(tester, _item(pageCount: null, currentPage: 0));

      expect(find.text('nombre de pages inconnu'), findsOne);
    });

    testWidgets('affiche la note quand elle existe', (tester) async {
      await pumpCard(tester, _item(shelf: Shelf.read, rating: 4));

      expect(find.byIcon(Icons.star), findsExactly(4));
      expect(find.byIcon(Icons.star_border), findsOne);
      expect(find.text('LECTURE TERMINÉE'), findsOne);
    });

    testWidgets('n\'affiche aucune étoile sans note', (tester) async {
      await pumpCard(tester, _item(shelf: Shelf.read));

      expect(find.byIcon(Icons.star), findsNothing);
    });

    testWidgets('gère un livre sans auteur', (tester) async {
      await pumpCard(tester, _item(author: null));

      expect(find.text('Auteur inconnu'), findsOne);
    });

    testWidgets('utilise sa variante sans couverture', (tester) async {
      await pumpCard(tester, _item());

      // Pas d'image, mais le repère typographique de remplacement.
      expect(find.byType(Image), findsNothing);
      expect(find.byIcon(Icons.menu_book_outlined), findsOne);
      expect(find.text('Dune'), findsOne);
    });

    testWidgets('mesure toujours 360 × 640', (tester) async {
      await pumpCard(tester, _item());

      expect(
        tester.getSize(find.byKey(captureKey)),
        const Size(
          ProgressShareCard.cardWidth,
          ProgressShareCard.cardHeight,
        ),
      );
    });

    testWidgets('se capture en 1080 × 1920', (tester) async {
      await pumpCard(tester, _item());

      final boundary =
          tester.renderObject<RenderRepaintBoundary>(find.byKey(captureKey));

      // La capture fait appel au moteur de rendu : elle a besoin du vrai
      // ordonnanceur, que `runAsync` rétablit le temps de l'opération.
      final size = await tester.runAsync(() async {
        final image =
            await boundary.toImage(pixelRatio: ProgressShareCard.captureRatio);
        final data = await image.toByteData(format: ImageByteFormat.png);
        image.dispose();
        return _pngSize(data!.buffer.asUint8List());
      });

      expect(size!.width, 1080);
      expect(size.height, 1920);
    });
  });
}
