import 'dart:typed_data';
import 'dart:ui' show ImageByteFormat;

import 'package:biblivre/domain/models/book.dart';
import 'package:biblivre/domain/models/library_item.dart';
import 'package:biblivre/domain/models/reading_entry.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/ui/share/card_backgrounds.dart';
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
/// Un PNG d'un pixel transparent, de quoi tenir lieu de couverture sans
/// dépendre du réseau : la mise en page n'a pas besoin que l'image soit
/// décodée, seulement qu'elle existe.
final Uint8List _onePixelPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
  0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

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

    test('détache toujours la barre de progression du fond', () {
      // Sans cet écart, la portion lue se confond avec son rail et la carte
      // n'affiche plus aucune progression visible — c'est ce qui se produisait
      // sur l'appareil avant correction.
      const samples = <Color>[
        Color(0xFFFFFFFF),
        Color(0xFF000000),
        Color(0xFF1B2A41),
        Color(0xFFE53935),
        Color(0xFFFDD835),
        Color(0xFF00897B),
      ];

      for (final sample in samples) {
        final palette = ProgressCardPalette.fromColors(sample, sample);
        expect(
          (palette.accent.computeLuminance() - palette.backgroundLuminance)
              .abs(),
          greaterThan(0.12),
          reason: 'barre invisible pour ${sample.toARGB32()}',
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
      expect((await CoverColors.fromCover(null)).isEmpty, isTrue);
    });
  });

  group('ProgressShareCard', () {
    final captureKey = GlobalKey();

    /// Monte la carte dans un parent volontairement plus grand qu'elle, et aux
    /// contraintes serrées : c'est le cas qui l'étirait avant correction.
    Future<void> pumpCard(
      WidgetTester tester,
      LibraryItem item, {
      ShareCardFormat format = ShareCardFormat.story,
      bool withCover = false,
    }) async {
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox.expand(
            child: ProgressShareCard(
              item: item,
              palette: ProgressCardPalette.fallback(),
              format: format,
              cover: withCover ? MemoryImage(_onePixelPng) : null,
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
      expect(find.textContaining('%'), findsNothing);
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
        Size(ShareCardFormat.story.width, ShareCardFormat.story.height),
      );
    });

    testWidgets('n\'affiche pas le nom de l\'application', (tester) async {
      await pumpCard(tester, _item());

      // La carte appartient au lecteur, pas à l'application : aucune signature.
      expect(find.textContaining('Biblivre'), findsNothing);
      expect(find.textContaining('biblivre'), findsNothing);
    });

    testWidgets('dessine réellement la portion lue', (tester) async {
      await pumpCard(tester, _item(currentPage: 329, pageCount: 658));

      // Le défaut précédent ne venait pas de la couleur mais de la mise en
      // page : dans une `Stack` aux contraintes lâches, le remplissage se
      // retrouvait haut de zéro et ne peignait rien. On mesure donc sa taille,
      // pas seulement sa teinte.
      final fill = tester.getSize(find.byKey(const Key('progress-fill')));
      final bar = tester.getSize(find.byKey(const Key('progress-track')));
      expect(fill.height, bar.height);
      expect(fill.height, greaterThan(0));

      // La carte fait 360 de large, moins 28 de marge de chaque côté ; à 50 %,
      // le remplissage doit couvrir la moitié de cette largeur.
      expect(fill.width, closeTo(bar.width / 2, 1));
    });

    testWidgets('ne dessine rien quand la lecture commence à peine',
        (tester) async {
      await pumpCard(
        tester,
        _item(currentPage: 0, pageCount: 658),
        format: ShareCardFormat.compact,
      );

      expect(tester.getSize(find.byKey(const Key('progress-fill'))).width, 0);
      expect(find.text('0 %'), findsOne);
    });

    testWidgets('remplit toute la barre à 100 %', (tester) async {
      await pumpCard(
        tester,
        _item(currentPage: 658, pageCount: 658),
        format: ShareCardFormat.compact,
      );

      final fill = tester.getSize(find.byKey(const Key('progress-fill')));
      final bar = tester.getSize(find.byKey(const Key('progress-track')));
      expect(fill.width, bar.width);
      expect(find.text('100 %'), findsOne);
    });

    testWidgets('écrit le pourcentage dans la barre du bloc', (tester) async {
      await pumpCard(
        tester,
        _item(currentPage: 500, pageCount: 658),
        format: ShareCardFormat.compact,
      );

      // Le chiffre est posé sur la portion lue, donc dans la couleur prévue
      // pour être lue sur elle.
      final label = tester.widget<Text>(find.text('76 %'));
      expect(label.style!.color, ProgressCardPalette.fallback().onAccent);

      // Et il est réellement au-dessus du remplissage, pas sur le rail vide :
      // c'est là qu'il se perdait auparavant.
      final fill = tester.getRect(find.byKey(const Key('progress-fill')));
      final text = tester.getRect(find.byKey(const Key('progress-label')));
      expect(text.left, greaterThanOrEqualTo(fill.left));
      expect(text.right, lessThanOrEqualTo(fill.right));
    });

    testWidgets('sort le pourcentage de la barre quand elle est trop courte',
        (tester) async {
      await pumpCard(
        tester,
        _item(currentPage: 6, pageCount: 658),
        format: ShareCardFormat.compact,
      );

      // À 1 %, le chiffre ne tiendrait pas dans la portion lue : il passe à
      // côté, sur le rail, dans la couleur du texte courant.
      final label = tester.widget<Text>(find.text('1 %'));
      expect(label.style!.color, ProgressCardPalette.fallback().foreground);

      final fill = tester.getRect(find.byKey(const Key('progress-fill')));
      final text = tester.getRect(find.byKey(const Key('progress-label')));
      expect(text.left, greaterThan(fill.right));
    });

    testWidgets('le format bloc est bas et large', (tester) async {
      await pumpCard(tester, _item(), format: ShareCardFormat.compact);

      expect(
        tester.getSize(find.byKey(captureKey)),
        Size(ShareCardFormat.compact.width, ShareCardFormat.compact.height),
      );
      // Le bloc doit rester nettement plus bas que le grand format.
      expect(
        ShareCardFormat.compact.height,
        lessThan(ShareCardFormat.story.height / 2),
      );
    });

    testWidgets('le format bloc garde titre, auteur et progression',
        (tester) async {
      await pumpCard(tester, _item(), format: ShareCardFormat.compact);

      expect(find.text('Dune'), findsOne);
      expect(find.text('Frank Herbert'), findsOne);
      expect(find.text('page 120 sur 658'), findsOne);
      expect(find.text('18 %'), findsOne);
    });

    testWidgets('le format bloc gère un livre sans nombre de pages',
        (tester) async {
      await pumpCard(
        tester,
        _item(pageCount: null),
        format: ShareCardFormat.compact,
      );

      expect(find.text('En cours'), findsOne);
      expect(find.textContaining('%'), findsNothing);
    });

    testWidgets('le format bloc se capture en 1080 × 636', (tester) async {
      await pumpCard(tester, _item(), format: ShareCardFormat.compact);

      final boundary =
          tester.renderObject<RenderRepaintBoundary>(find.byKey(captureKey));

      final size = await tester.runAsync(() async {
        final image =
            await boundary.toImage(pixelRatio: ProgressShareCard.captureRatio);
        final data = await image.toByteData(format: ImageByteFormat.png);
        image.dispose();
        return _pngSize(data!.buffer.asUint8List());
      });

      expect(size, (width: 1080, height: 636));
    });

    testWidgets('arrondit les coins du bloc, pas ceux du grand format',
        (tester) async {
      await pumpCard(tester, _item(), format: ShareCardFormat.compact);
      var decoration = tester
          .widget<DecoratedBox>(find.byKey(const Key('card-background')))
          .decoration as BoxDecoration;
      // Hors des coins, la carte est transparente : elle se pose sur n'importe
      // quel fond sans y découper un angle droit.
      expect(decoration.borderRadius, isNotNull);
      expect(ShareCardFormat.compact.cornerRadius, greaterThan(0));

      await pumpCard(tester, _item());
      decoration = tester
          .widget<DecoratedBox>(find.byKey(const Key('card-background')))
          .decoration as BoxDecoration;
      expect(
        decoration.borderRadius,
        BorderRadius.circular(0),
        reason: 'le grand format occupe tout l\'écran, il reste franc',
      );
    });

    testWidgets('dans le bloc, tout se tient à droite de la couverture',
        (tester) async {
      await pumpCard(
        tester,
        _item(rating: 4),
        format: ShareCardFormat.compact,
        withCover: true,
      );

      final cover = tester.getRect(find.byType(Image));
      for (final part in <Finder>[
        find.text('Dune'),
        find.text('Frank Herbert'),
        find.byKey(const Key('progress-track')),
        find.text('page 120 sur 658'),
        find.byIcon(Icons.star).first,
      ]) {
        expect(
          tester.getRect(part).left,
          greaterThanOrEqualTo(cover.right),
          reason: 'cet élément devrait être à droite de la couverture',
        );
      }

      // Sauf l'accroche, qui traverse toute la largeur.
      expect(
        tester.getRect(find.text('EN COURS DE LECTURE')).left,
        lessThan(cover.right),
      );
    });

    testWidgets('place la barre juste sous le titre dans le bloc',
        (tester) async {
      await pumpCard(
        tester,
        _item(rating: 4),
        format: ShareCardFormat.compact,
        withCover: true,
      );

      final title = tester.getRect(find.text('Dune'));
      final author = tester.getRect(find.text('Frank Herbert'));
      final bar = tester.getRect(find.byKey(const Key('progress-track')));
      final pages = tester.getRect(find.text('page 120 sur 658'));

      // Rien ne s'intercale entre le titre et la barre, et la note tient sur
      // la ligne des pages plutôt que sur une ligne à elle.
      expect(bar.top, greaterThan(author.bottom));
      expect(bar.top - author.bottom, lessThan(24));
      expect(title.bottom, lessThan(author.top + 1));
      expect(pages.top, greaterThan(bar.bottom));

      final stars = tester.getRect(find.byIcon(Icons.star).first);
      expect(stars.center.dy, closeTo(pages.center.dy, 6));
    });

    testWidgets('arrête la couverture sur la ligne des pages', (tester) async {
      await pumpCard(
        tester,
        _item(),
        format: ShareCardFormat.compact,
        withCover: true,
      );

      final cover = tester.getRect(find.byType(Image));
      final pages = tester.getRect(find.text('page 120 sur 658'));

      // Les deux bas coïncident : c'est ce qui fait tenir le bloc.
      expect(cover.bottom, closeTo(pages.bottom, 6));
    });

    testWidgets('garde la couverture à sa proportion, sans la rogner',
        (tester) async {
      await pumpCard(
        tester,
        _item(),
        format: ShareCardFormat.compact,
        withCover: true,
      );

      final cover = tester.getRect(find.byType(Image));
      expect(cover.width / cover.height, closeTo(2 / 3, 0.02));
    });

    test('donne la story au format de référence', () {
      // Le 9:16 attendu par les plateformes, quel que soit l'appareil.
      expect(ShareCardFormat.story.pixels, '1080 × 1920');
      expect(ShareCardFormat.compact.pixels, '1080 × 636');
    });

    test('propose deux formats, du plus petit au plus grand', () {
      expect(ShareCardFormat.values.map((format) => format.label), <String>[
        'Bloc',
        'Moyen',
      ]);
      expect(
        ShareCardFormat.compact.height,
        lessThan(ShareCardFormat.story.height),
      );
    });

    testWidgets('propose deux noms de fichier distincts', (tester) async {
      final names = <String>{
        for (final format in ShareCardFormat.values) format.fileName,
      };
      expect(names, hasLength(ShareCardFormat.values.length));
      expect(names.every((name) => name.endsWith('.png')), isTrue);
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
