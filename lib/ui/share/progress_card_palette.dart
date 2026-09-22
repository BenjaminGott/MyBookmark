import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Les deux familles de cartes.
enum PaletteFamily {
  /// Fond clair, texte sombre.
  light,

  /// Fond sombre, texte blanc.
  dark,
}

/// Les couleurs d'une carte de partage : un dégradé et un texte lisible dessus.
///
/// Le dégradé est tiré de la couverture du livre, mais jamais tel quel : une
/// couverture très claire ou très sombre donnerait un texte illisible. Les
/// teintes sont donc ramenées dans une plage utilisable avant d'être retenues.
///
/// Quel que soit le chemin — automatique, variante proposée ou couleurs
/// choisies à la main — la couleur du texte et celle de la barre sont toujours
/// recalculées à partir du fond, jamais laissées au hasard du choix.
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

  /// Un dégradé entièrement choisi par l'utilisateur.
  ///
  /// Les deux couleurs sont prises telles quelles — c'est le principe d'un
  /// choix manuel — mais le texte et la barre restent calculés, pour qu'un
  /// dégradé malheureux ne rende pas la carte illisible.
  factory ProgressCardPalette.custom({
    required Color top,
    required Color bottom,
  }) {
    return ProgressCardPalette(
      top: top,
      bottom: bottom,
      foreground: _readableOn(top, bottom),
      accent: _accentFor(top, bottom),
    );
  }

  /// Le haut du dégradé.
  final Color top;

  /// Le bas du dégradé.
  final Color bottom;

  /// La couleur du texte, choisie pour rester lisible sur le dégradé.
  final Color foreground;

  /// La couleur de la portion remplie de la barre de progression.
  final Color accent;

  /// La couleur du texte écrit **sur** [accent] : le pourcentage est logé dans
  /// la barre, il doit se lire sur elle et non sur le fond.
  Color get onAccent => accent.computeLuminance() > 0.45
      ? const Color(0xFF16110D)
      : Colors.white;

  /// Luminosité moyenne du dégradé, celle sur laquelle tout se détache.
  double get backgroundLuminance =>
      (top.computeLuminance() + bottom.computeLuminance()) / 2;

  /// À quelle famille appartient ce dégradé.
  PaletteFamily get family =>
      backgroundLuminance > 0.42 ? PaletteFamily.light : PaletteFamily.dark;

  /// Construit une palette à partir de deux couleurs brutes.
  ///
  /// Deux familles de cartes, selon la couverture : une couverture claire donne
  /// une carte claire à texte sombre, une couverture sombre donne une carte
  /// sombre à texte blanc. Assombrir systématiquement aurait été plus simple,
  /// mais toutes les couvertures pastel auraient rendu la même carte terne.
  ///
  /// [force] impose une famille au lieu de la déduire : c'est ce qui permet de
  /// proposer une variante claire et une variante sombre de la même couverture.
  static ProgressCardPalette fromColors(
    Color? first,
    Color? second, {
    PaletteFamily? force,
  }) {
    if (first == null) {
      return ProgressCardPalette.fallback();
    }

    final companion = second ?? first;
    final luminance = first.computeLuminance();
    final family =
        force ?? (luminance > 0.62 ? PaletteFamily.light : PaletteFamily.dark);

    if (family == PaletteFamily.light) {
      // Une couleur sombre à qui l'on demande une carte claire doit d'abord
      // être remontée, sinon la « variante claire » resterait sombre.
      final base = luminance < 0.5 ? _tint(first, 0.72) : first;
      final mate = companion.computeLuminance() < 0.5
          ? _tint(companion, 0.6)
          : companion;

      // Le blanc pur est légèrement rabattu : sans cela le dégradé n'aurait
      // aucun relief et la carte ressemblerait à une feuille vide.
      final top = _shade(base, base.computeLuminance() > 0.9 ? 0.14 : 0.04);
      final bottom = _tint(mate, 0.3);
      return ProgressCardPalette(
        top: top,
        bottom: bottom,
        foreground: _readableOn(top, bottom),
        accent: _accentFor(top, bottom),
      );
    }

    // Le haut reste vivant, le bas est nettement assombri : ça donne de la
    // profondeur et ça garantit un contraste stable en bas de carte, là où se
    // trouvent les chiffres.
    final base = luminance > 0.62 ? _shade(first, 0.55) : first;
    final top = base.computeLuminance() < 0.03
        ? _tint(base, 0.18)
        : _shade(base, 0.12);
    final bottom = _shade(companion, luminance > 0.62 ? 0.75 : 0.55);
    return ProgressCardPalette(
      top: top,
      bottom: bottom,
      foreground: _readableOn(top, bottom),
      accent: _accentFor(top, bottom),
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

  /// La couleur de la portion lue : franchement détachée du fond, dans un sens
  /// ou dans l'autre, sans quoi la progression ne se verrait pas.
  static Color _accentFor(Color top, Color bottom) {
    final average = (top.computeLuminance() + bottom.computeLuminance()) / 2;
    return average > 0.42 ? _shade(bottom, 0.7) : _tint(top, 0.78);
  }

  /// Assombrit [color] de [amount] (0 à 1).
  static Color _shade(Color color, double amount) =>
      Color.lerp(color, Colors.black, amount)!;

  /// Éclaircit [color] de [amount] (0 à 1).
  static Color _tint(Color color, double amount) =>
      Color.lerp(color, Colors.white, amount)!;
}
