import 'package:biblivre/ui/share/card_backgrounds.dart';
import 'package:biblivre/ui/share/progress_card_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un jeu de couvertures très différentes, pour éprouver les propositions.
const Map<String, Color> _covers = <String, Color>{
  'bleu nuit': Color(0xFF12253F),
  'rouge vif': Color(0xFFD32F2F),
  'jaune pâle': Color(0xFFFFF2B2),
  'blanc': Color(0xFFFFFFFF),
  'noir': Color(0xFF000000),
  'vert forêt': Color(0xFF1B5E20),
};

/// Les sortes de fonds proposées, dans l'ordre.
List<BackgroundKind> _kinds(List<BackgroundOption> options) =>
    options.map((option) => option.kind).toList();

/// Le dégradé du fond d'une sorte donnée.
ProgressCardPalette _palette(
  List<BackgroundOption> options,
  BackgroundKind kind,
) =>
    options.firstWhere((option) => option.kind == kind).palette;

void main() {
  group('CardBackgrounds.forCover', () {
    test('propose l\'automatique en premier', () {
      final options = CardBackgrounds.forCover(
        const CoverColors(dominant: Color(0xFF12253F)),
      );

      expect(options.first.kind, BackgroundKind.automatic);
    });

    test('propose une variante claire et une sombre', () {
      final options = CardBackgrounds.forCover(
        const CoverColors(
          dominant: Color(0xFF12253F),
          dark: Color(0xFF0A1422),
          light: Color(0xFFBFD3EA),
        ),
      );

      expect(
        _kinds(options),
        containsAll(<BackgroundKind>[BackgroundKind.light, BackgroundKind.dark]),
      );

      final clair = _palette(options, BackgroundKind.light);
      final sombre = _palette(options, BackgroundKind.dark);

      expect(clair.family, PaletteFamily.light);
      expect(sombre.family, PaletteFamily.dark);
      expect(clair.foreground, isNot(sombre.foreground));
    });

    test('tient ses promesses claire et sombre sur toutes les couvertures', () {
      // Une couverture noire doit quand même savoir donner une carte claire,
      // et une couverture blanche une carte sombre : sinon la variante
      // proposée ne serait qu'un doublon de l'automatique.
      for (final entry in _covers.entries) {
        final options = CardBackgrounds.forCover(
          CoverColors(dominant: entry.value),
        );
        final clair = _palette(options, BackgroundKind.light);
        final sombre = _palette(options, BackgroundKind.dark);

        expect(clair.family, PaletteFamily.light, reason: entry.key);
        expect(sombre.family, PaletteFamily.dark, reason: entry.key);
      }
    });

    test('ajoute un fond vif quand la couverture a une seconde couleur', () {
      final options = CardBackgrounds.forCover(
        const CoverColors(
          dominant: Color(0xFF12253F),
          vibrant: Color(0xFFE64A19),
        ),
      );

      expect(_kinds(options), contains(BackgroundKind.vivid));
    });

    test('n\'ajoute pas de fond vif s\'il doublonne l\'automatique', () {
      final options = CardBackgrounds.forCover(
        const CoverColors(
          dominant: Color(0xFF12253F),
          vibrant: Color(0xFF12253F),
        ),
      );

      expect(_kinds(options), isNot(contains(BackgroundKind.vivid)));
    });

    test('propose toujours deux fonds neutres', () {
      final options = CardBackgrounds.forCover(
        const CoverColors(dominant: Color(0xFF12253F)),
      );

      expect(
        _kinds(options),
        containsAll(<BackgroundKind>[BackgroundKind.night, BackgroundKind.paper]),
      );
    });

    test('propose quand même des fonds sans couverture', () {
      final options = CardBackgrounds.forCover(CoverColors.none);

      expect(options, isNotEmpty);
      expect(options.first.kind, BackgroundKind.automatic);
      expect(options.first.palette.top, ProgressCardPalette.fallback().top);
    });

    test('garde un texte lisible sur chaque proposition', () {
      for (final entry in _covers.entries) {
        final options = CardBackgrounds.forCover(
          CoverColors(dominant: entry.value, vibrant: const Color(0xFFE64A19)),
        );

        for (final option in options) {
          final contrast =
              (option.palette.backgroundLuminance -
                      option.palette.foreground.computeLuminance())
                  .abs();
          expect(
            contrast,
            greaterThan(0.3),
            reason: '${option.kind.name} sur ${entry.key}',
          );
        }
      }
    });

    test('garde une barre visible sur chaque proposition', () {
      for (final entry in _covers.entries) {
        final options = CardBackgrounds.forCover(
          CoverColors(dominant: entry.value),
        );

        for (final option in options) {
          final contrast =
              (option.palette.accent.computeLuminance() -
                      option.palette.backgroundLuminance)
                  .abs();
          expect(
            contrast,
            greaterThan(0.12),
            reason: '${option.kind.name} sur ${entry.key}',
          );
        }
      }
    });
  });

  group('ProgressCardPalette.custom', () {
    test('prend les deux couleurs telles quelles', () {
      final palette = ProgressCardPalette.custom(
        top: const Color(0xFF7B1FA2),
        bottom: const Color(0xFF311B92),
      );

      expect(palette.top, const Color(0xFF7B1FA2));
      expect(palette.bottom, const Color(0xFF311B92));
    });

    test('calcule quand même un texte lisible', () {
      // Un dégradé très clair choisi à la main doit donner un texte sombre,
      // sans quoi la carte serait illisible par la faute de l'utilisateur.
      final clair = ProgressCardPalette.custom(
        top: const Color(0xFFFFF9C4),
        bottom: const Color(0xFFFFE082),
      );
      expect(clair.foreground.computeLuminance(), lessThan(0.2));

      final sombre = ProgressCardPalette.custom(
        top: const Color(0xFF1A237E),
        bottom: const Color(0xFF000000),
      );
      expect(sombre.foreground, Colors.white);
    });

    test('calcule une barre détachée du fond choisi', () {
      final palette = ProgressCardPalette.custom(
        top: const Color(0xFF7B1FA2),
        bottom: const Color(0xFF311B92),
      );

      expect(
        (palette.accent.computeLuminance() - palette.backgroundLuminance).abs(),
        greaterThan(0.12),
      );
    });
  });
}
