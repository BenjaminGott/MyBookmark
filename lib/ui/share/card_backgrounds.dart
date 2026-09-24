import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import '../l10n/l10n.dart';
import 'progress_card_palette.dart';

/// Les sortes de fonds proposés ; leur nom affiché dépend de la langue.
enum BackgroundKind { automatic, dark, light, vivid, night, paper }

/// Un fond proposé dans le sélecteur, avec la sorte qui l'annonce.
@immutable
class BackgroundOption {
  const BackgroundOption({required this.kind, required this.palette});

  final BackgroundKind kind;
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
          kind: BackgroundKind.automatic,
          palette: ProgressCardPalette.fallback(),
        ),
        BackgroundOption(kind: BackgroundKind.night, palette: night),
        BackgroundOption(kind: BackgroundKind.paper, palette: paper),
      ];
    }

    final base = colors.dominant ?? colors.vibrant;
    final options = <BackgroundOption>[
      BackgroundOption(
        kind: BackgroundKind.automatic,
        palette: ProgressCardPalette.fromColors(base, colors.dark),
      ),
      BackgroundOption(
        kind: BackgroundKind.dark,
        palette: ProgressCardPalette.fromColors(
          base,
          colors.dark ?? base,
          force: PaletteFamily.dark,
        ),
      ),
      BackgroundOption(
        kind: BackgroundKind.light,
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
          kind: BackgroundKind.vivid,
          palette: ProgressCardPalette.fromColors(vibrant, colors.dark),
        ),
      );
    }

    return <BackgroundOption>[
      ...options,
      BackgroundOption(kind: BackgroundKind.night, palette: night),
      BackgroundOption(kind: BackgroundKind.paper, palette: paper),
    ];
  }
}

/// Nom affiché de chaque sorte de fond.
extension BackgroundKindLabel on BackgroundKind {
  String label(AppLocalizations l10n) => switch (this) {
        BackgroundKind.automatic => l10n.backgroundAuto,
        BackgroundKind.dark => l10n.backgroundDark,
        BackgroundKind.light => l10n.backgroundLight,
        BackgroundKind.vivid => l10n.backgroundVivid,
        BackgroundKind.night => l10n.backgroundNight,
        BackgroundKind.paper => l10n.backgroundPaper,
      };
}
