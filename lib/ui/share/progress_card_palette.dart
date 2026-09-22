import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../core/theme/app_theme.dart';

/// Les couleurs d'une carte de partage : un dégradé et un texte lisible dessus.
///
/// Le dégradé est tiré de la couverture du livre, mais jamais tel quel : une
/// couverture très claire ou très sombre donnerait un texte illisible. Les
/// teintes sont donc ramenées dans une plage utilisable avant d'être retenues.
@immutable
class ProgressCardPalette {
  const ProgressCardPalette({
    required this.top,
    required this.bottom,
    required this.foreground,
    required this.accent,
  });

  /// La palette utilisée quand il n'y a pas de couverture, ou quand son analyse
  /// échoue : les teintes de l'application.
  factory ProgressCardPalette.fallback() {
    const seed = AppTheme.seed;
    return ProgressCardPalette(
      top: _shade(seed, 0.22),
      bottom: _shade(seed, 0.62),
      foreground: Colors.white,
      accent: _shade(seed, 0.12),
    );
  }

  /// Le haut du dégradé.
  final Color top;

  /// Le bas du dégradé, toujours plus sombre que [top].
  final Color bottom;

  /// La couleur du texte, choisie pour rester lisible sur le dégradé.
  final Color foreground;

  /// La couleur de la portion remplie de la barre de progression.
  final Color accent;

  /// Analyse une couverture pour en tirer un dégradé.
  ///
  /// Toute erreur — image introuvable, décodage impossible, couverture d'une
  /// seule couleur — retombe sur [ProgressCardPalette.fallback].
  static Future<ProgressCardPalette> fromCover(ImageProvider? cover) async {
    if (cover == null) {
      return ProgressCardPalette.fallback();
    }

    try {
      final palette = await PaletteGenerator.fromImageProvider(
        cover,
        maximumColorCount: 12,
      );
      return fromColors(
        palette.dominantColor?.color,
        palette.darkMutedColor?.color ??
            palette.darkVibrantColor?.color ??
            palette.mutedColor?.color,
      );
    } on Object {
      return ProgressCardPalette.fallback();
    }
  }

  /// Construit une palette à partir de deux couleurs brutes.
  ///
  /// Séparé de [fromCover] pour être testable sans décoder d'image.
  ///
  /// Deux familles de cartes, selon la couverture : une couverture claire donne
  /// une carte claire à texte sombre, une couverture sombre donne une carte
  /// sombre à texte blanc. Assombrir systématiquement aurait été plus simple,
  /// mais toutes les couvertures pastel auraient rendu la même carte terne.
  static ProgressCardPalette fromColors(Color? first, Color? second) {
    if (first == null) {
      return ProgressCardPalette.fallback();
    }

    final companion = second ?? first;
    final luminance = first.computeLuminance();

    if (luminance > 0.62) {
      // Le blanc pur est légèrement rabattu : sans cela le dégradé n'aurait
      // aucun relief et la carte ressemblerait à une feuille vide.
      final top = _shade(first, luminance > 0.9 ? 0.14 : 0.04);
      final bottom = _tint(companion, 0.3);
      return ProgressCardPalette(
        top: top,
        bottom: bottom,
        foreground: _readableOn(top, bottom),
        accent: _shade(companion, 0.55),
      );
    }

    // Le haut reste vivant, le bas est nettement assombri : ça donne de la
    // profondeur et ça garantit un contraste stable en bas de carte, là où se
    // trouvent les chiffres.
    final top = luminance < 0.03 ? _tint(first, 0.18) : _shade(first, 0.12);
    final bottom = _shade(companion, 0.55);
    return ProgressCardPalette(
      top: top,
      bottom: bottom,
      foreground: _readableOn(top, bottom),
      accent: _tint(top, 0.45),
    );
  }

  /// Blanc ou presque noir, selon ce qui se lit sur le dégradé.
  ///
  /// La comparaison porte sur la moyenne des deux teintes : le texte traverse
  /// toute la hauteur de la carte.
  static Color _readableOn(Color top, Color bottom) {
    final average = (top.computeLuminance() + bottom.computeLuminance()) / 2;
    return average > 0.42 ? const Color(0xFF16110D) : Colors.white;
  }

  /// Assombrit [color] de [amount] (0 à 1).
  static Color _shade(Color color, double amount) =>
      Color.lerp(color, Colors.black, amount)!;

  /// Éclaircit [color] de [amount] (0 à 1).
  static Color _tint(Color color, double amount) =>
      Color.lerp(color, Colors.white, amount)!;
}
