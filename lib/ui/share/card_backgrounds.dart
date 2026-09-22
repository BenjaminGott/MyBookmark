import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import 'progress_card_palette.dart';

/// Un fond proposé dans le sélecteur, avec le nom qui l'annonce.
@immutable
class BackgroundOption {
  const BackgroundOption({required this.label, required this.palette});

  final String label;
  final ProgressCardPalette palette;
}

/// Les couleurs retenues d'une couverture, avant toute mise en forme.
///
/// Isolé de [ProgressCardPalette] pour deux raisons : garder `palette_generator`
/// derrière une seule porte, et pouvoir construire les propositions sans
/// décoder d'image dans les tests.
@immutable
class CoverColors {
  const CoverColors({this.dominant, this.vibrant, this.dark, this.light});

  /// Aucune couleur : couverture absente ou illisible.
  static const CoverColors none = CoverColors();

  final Color? dominant;
  final Color? vibrant;
  final Color? dark;
  final Color? light;

  bool get isEmpty => dominant == null && vibrant == null;

  /// Analyse une couverture. Toute erreur renvoie [CoverColors.none].
  static Future<CoverColors> fromCover(ImageProvider? cover) async {
    if (cover == null) {
      return CoverColors.none;
    }

    try {
      final palette = await PaletteGenerator.fromImageProvider(
        cover,
        maximumColorCount: 12,
      );
      return CoverColors(
        dominant: palette.dominantColor?.color,
        vibrant: palette.vibrantColor?.color ?? palette.mutedColor?.color,
        dark: palette.darkMutedColor?.color ?? palette.darkVibrantColor?.color,
        light:
            palette.lightMutedColor?.color ?? palette.lightVibrantColor?.color,
      );
    } on Object {
      return CoverColors.none;
    }
  }
}

/// La liste des fonds proposés pour une couverture donnée.
///
/// Le premier est toujours l'automatique : c'est celui qui s'applique sans
/// rien demander. Viennent ensuite les variantes tirées de la même couverture,
/// puis deux fonds neutres qui vont avec n'importe quel livre.
class CardBackgrounds {
  const CardBackgrounds._();

  /// Fond neutre sombre, indépendant de la couverture.
  static final ProgressCardPalette night = ProgressCardPalette.custom(
    top: const Color(0xFF1F2124),
    bottom: const Color(0xFF0C0D0F),
  );

  /// Fond neutre clair, dans les tons papier.
  static final ProgressCardPalette paper = ProgressCardPalette.custom(
    top: const Color(0xFFF3ECE1),
    bottom: const Color(0xFFDCD2C3),
  );

  static List<BackgroundOption> forCover(CoverColors colors) {
    if (colors.isEmpty) {
      return <BackgroundOption>[
        BackgroundOption(
          label: 'Automatique',
          palette: ProgressCardPalette.fallback(),
        ),
        BackgroundOption(label: 'Nuit', palette: night),
        BackgroundOption(label: 'Papier', palette: paper),
      ];
    }

    final base = colors.dominant ?? colors.vibrant;
    final options = <BackgroundOption>[
      BackgroundOption(
        label: 'Automatique',
        palette: ProgressCardPalette.fromColors(base, colors.dark),
      ),
      BackgroundOption(
        label: 'Sombre',
        palette: ProgressCardPalette.fromColors(
          base,
          colors.dark ?? base,
          force: PaletteFamily.dark,
        ),
      ),
      BackgroundOption(
        label: 'Clair',
        palette: ProgressCardPalette.fromColors(
          colors.light ?? base,
          base,
          force: PaletteFamily.light,
        ),
      ),
    ];

    // Une couverture bicolore mérite sa variante vive ; inutile de la proposer
    // si elle redonne le même dégradé que l'automatique.
    final vibrant = colors.vibrant;
    if (vibrant != null && vibrant != base) {
      options.add(
        BackgroundOption(
          label: 'Vif',
          palette: ProgressCardPalette.fromColors(vibrant, colors.dark),
        ),
      );
    }

    return <BackgroundOption>[
      ...options,
      BackgroundOption(label: 'Nuit', palette: night),
      BackgroundOption(label: 'Papier', palette: paper),
    ];
  }
}
