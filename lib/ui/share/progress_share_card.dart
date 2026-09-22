import 'package:flutter/material.dart';

import '../../domain/models/library_item.dart';
import '../../domain/models/shelf.dart';
import '../../domain/services/reading_progress.dart';
import '../shelf_labels.dart';
import 'progress_card_palette.dart';

/// Les deux formats de carte proposés au partage.
///
/// Les dimensions sont données en points ; capturées au ratio de
/// [ProgressShareCard.captureRatio], elles donnent les pixels annoncés.
enum ShareCardFormat {
  /// Pleine hauteur, pour une story ou un post : 1080 × 1920.
  ///
  /// Sans coins arrondis : elle occupe tout l'écran, il n'y a rien derrière.
  large(360, 640, 'Grand', '1080 × 1920', 0),

  /// Bloc bas, pensé pour être posé à côté d'autre chose : 1080 × 900.
  ///
  /// Coins arrondis et donc transparents : il se pose sur un fond quelconque
  /// sans trancher dessus par un angle droit.
  compact(360, 300, 'Bloc', '1080 × 900', 26);

  const ShareCardFormat(
    this.width,
    this.height,
    this.label,
    this.pixels,
    this.cornerRadius,
  );

  final double width;
  final double height;

  /// Rayon des coins, en points. Zéro pour un bord franc.
  final double cornerRadius;

  /// Le nom montré dans le sélecteur.
  final String label;

  /// La taille de l'image produite, annoncée à l'utilisateur.
  final String pixels;

  String get fileName => switch (this) {
        ShareCardFormat.large => 'biblivre-progression.png',
        ShareCardFormat.compact => 'biblivre-progression-bloc.png',
      };
}

/// La carte de progression partagée, dessinée à taille fixe.
///
/// Rien dans cette carte ne dépend du thème de l'application ni de la taille de
/// l'écran : l'image partagée est identique d'un téléphone à l'autre.
///
/// La composition est alignée à gauche et le pourcentage logé dans la barre
/// elle-même : une mise en page éditoriale, qui ne cherche à ressembler à
/// aucune application existante.
class ProgressShareCard extends StatelessWidget {
  const ProgressShareCard({
    required this.item,
    required this.palette,
    super.key,
    this.format = ShareCardFormat.large,
    this.cover,
    this.captureKey,
  });

  /// Ratio de capture : 360 × 3 = 1080, 640 × 3 = 1920.
  static const double captureRatio = 3;

  final LibraryItem item;
  final ProgressCardPalette palette;
  final ShareCardFormat format;

  /// La couverture, déjà chargée. Nulle si le livre n'en a pas.
  final ImageProvider? cover;

  /// La clé de la frontière de capture, posée au plus près de la carte.
  ///
  /// La frontière est à l'intérieur de la carte, et non autour : c'est ce qui
  /// garantit qu'elle mesure exactement le format demandé, quelles que soient
  /// les contraintes du parent.
  final GlobalKey? captureKey;

  @override
  Widget build(BuildContext context) {
    // Le `Center` desserre les contraintes reçues : sans lui, un parent au
    // dimensionnement serré étirerait la carte et la capture ne ferait plus la
    // taille annoncée.
    return Center(
      child: RepaintBoundary(
        key: captureKey,
        child: SizedBox(
          width: format.width,
          height: format.height,
          child: DecoratedBox(
            key: const Key('card-background'),
            decoration: BoxDecoration(
              // Hors des coins, l'image partagée est transparente : le PNG
              // conserve son canal alpha à la capture.
              borderRadius: BorderRadius.circular(format.cornerRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[palette.top, palette.bottom],
              ),
            ),
            child: switch (format) {
              ShareCardFormat.large =>
                _LargeLayout(item: item, palette: palette, cover: cover),
              ShareCardFormat.compact =>
                _CompactLayout(item: item, palette: palette, cover: cover),
            },
          ),
        ),
      ),
    );
  }
}

/// Mise en page pleine hauteur : la couverture au centre de la composition.
class _LargeLayout extends StatelessWidget {
  const _LargeLayout({
    required this.item,
    required this.palette,
    required this.cover,
  });

  final LibraryItem item;
  final ProgressCardPalette palette;
  final ImageProvider? cover;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _Kicker(item: item, palette: palette),
          const Spacer(),
          if (cover != null)
            _Cover(cover: cover!, width: 152, height: 228)
          else
            _NoCoverMark(palette: palette),
          const SizedBox(height: 28),
          _Title(item: item, palette: palette, size: cover == null ? 38 : 27),
          const Spacer(),
          if (item.currentEntry.rating != null) ...<Widget>[
            _Stars(rating: item.currentEntry.rating!, palette: palette),
            const SizedBox(height: 20),
          ],
          _ProgressBlock(item: item, palette: palette, style: _BarStyle.slim),
        ],
      ),
    );
  }
}

/// Mise en page en bloc : couverture à gauche, texte et barre à droite.
///
/// Format carré et compact, pensé pour être posé à côté d'autre chose.
class _CompactLayout extends StatelessWidget {
  const _CompactLayout({
    required this.item,
    required this.palette,
    required this.cover,
  });

  final LibraryItem item;
  final ProgressCardPalette palette;
  final ImageProvider? cover;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Seule l'accroche traverse toute la largeur : tout le reste vit à
          // droite de la couverture.
          _Kicker(item: item, palette: palette),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (cover != null) ...<Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: _Cover(cover: cover!, width: 112, height: 168),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _Title(
                        item: item,
                        palette: palette,
                        size: cover == null ? 30 : 20,
                        maxLines: cover == null ? 4 : 3,
                      ),
                      const Spacer(),
                      if (item.currentEntry.rating != null) ...<Widget>[
                        _Stars(
                          rating: item.currentEntry.rating!,
                          palette: palette,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _ProgressBlock(
                        item: item,
                        palette: palette,
                        style: _BarStyle.thick,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// La ligne d'accroche, tout en haut.
class _Kicker extends StatelessWidget {
  const _Kicker({required this.item, required this.palette});

  final LibraryItem item;
  final ProgressCardPalette palette;

  @override
  Widget build(BuildContext context) {
    final label = switch (item.shelf) {
      Shelf.reading => 'EN COURS DE LECTURE',
      Shelf.read => 'LECTURE TERMINÉE',
      Shelf.toRead => 'DANS MA PILE',
    };

    return Row(
      children: <Widget>[
        Container(width: 22, height: 2, color: palette.foreground),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: palette.foreground,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.2,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({
    required this.cover,
    required this.width,
    required this.height,
  });

  final ImageProvider cover;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x5A000000),
            blurRadius: 26,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image(
          image: cover,
          width: width,
          height: height,
          fit: BoxFit.cover,
          // L'image est déjà en cache au moment de la capture ; ce rendu
          // immédiat évite un fondu qui sortirait à moitié transparent.
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

/// Le substitut de couverture : deux filets et un pictogramme.
class _NoCoverMark extends StatelessWidget {
  const _NoCoverMark({required this.palette});

  final ProgressCardPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 120,
          height: 1,
          color: palette.foreground.withValues(alpha: 0.35),
        ),
        const SizedBox(height: 14),
        Icon(
          Icons.menu_book_outlined,
          size: 40,
          color: palette.foreground.withValues(alpha: 0.75),
        ),
        const SizedBox(height: 14),
        Container(
          width: 56,
          height: 1,
          color: palette.foreground.withValues(alpha: 0.35),
        ),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.item,
    required this.palette,
    required this.size,
    this.maxLines = 3,
  });

  final LibraryItem item;
  final ProgressCardPalette palette;
  final double size;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item.book.title,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.foreground,
            fontSize: size,
            fontWeight: FontWeight.w700,
            height: 1.12,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          item.book.author ?? 'Auteur inconnu',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.foreground.withValues(alpha: 0.78),
            fontSize: size < 24 ? 13 : 15,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, required this.palette});

  final int rating;
  final ProgressCardPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (var star = 1; star <= 5; star++)
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Icon(
              star <= rating ? Icons.star : Icons.star_border,
              size: 16,
              color: palette.foreground.withValues(
                alpha: star <= rating ? 0.95 : 0.35,
              ),
            ),
          ),
      ],
    );
  }
}

/// Les deux traitements de la barre de progression.
enum _BarStyle {
  /// Filet fin, pourcentage en grand chiffre à côté. Le grand format a la
  /// hauteur nécessaire pour ce traitement aéré.
  slim,

  /// Barre épaisse, pourcentage logé dedans. Le bloc n'a pas la place d'un
  /// grand chiffre à part.
  thick,
}

/// La barre de progression et la ligne de pages qui l'accompagne.
class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({
    required this.item,
    required this.palette,
    required this.style,
  });

  final LibraryItem item;
  final ProgressCardPalette palette;
  final _BarStyle style;

  @override
  Widget build(BuildContext context) {
    final pageCount = item.book.pageCount;
    final percent = ReadingProgress.percent(
      currentPage: item.currentEntry.currentPage,
      pageCount: pageCount,
    );
    final page = item.currentEntry.currentPage;

    // Sans nombre de pages, aucun pourcentage n'a de sens : la carte annonce
    // simplement où en est le livre, sans barre trompeuse.
    if (percent == null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Text(
              page > 0 ? 'page $page' : 'nombre de pages inconnu',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.foreground.withValues(alpha: 0.8),
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Text(
            item.shelf.label,
            style: TextStyle(
              color: palette.foreground,
              fontSize: 20,
              fontWeight: FontWeight.w300,
              height: 1,
            ),
          ),
        ],
      );
    }

    final pages = Text(
      'page $page sur $pageCount',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: palette.foreground.withValues(alpha: 0.8),
        fontSize: 13,
        letterSpacing: 0.3,
      ),
    );

    return switch (style) {
      _BarStyle.thick => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ThickBar(percent: percent, palette: palette, height: 24),
            const SizedBox(height: 10),
            pages,
          ],
        ),
      _BarStyle.slim => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _SlimBar(percent: percent, palette: palette),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(child: pages),
                Text(
                  '$percent',
                  key: const Key('progress-label'),
                  style: TextStyle(
                    color: palette.foreground,
                    fontSize: 40,
                    fontWeight: FontWeight.w300,
                    height: 0.92,
                    letterSpacing: -1.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 3, bottom: 4),
                  child: Text(
                    '%',
                    style: TextStyle(
                      color: palette.foreground.withValues(alpha: 0.8),
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    };
  }
}

/// Un filet fin : le rail sur toute la largeur, la portion lue par-dessus.
class _SlimBar extends StatelessWidget {
  const _SlimBar({required this.percent, required this.palette});

  static const double _height = 6;

  final int percent;
  final ProgressCardPalette palette;

  @override
  Widget build(BuildContext context) {
    final fraction = (percent / 100).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: _height,
          child: Stack(
            children: <Widget>[
              DecoratedBox(
                key: const Key('progress-track'),
                decoration: BoxDecoration(
                  color: palette.foreground.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(_height / 2),
                ),
                child: const SizedBox.expand(),
              ),
              // Haut et bas fixés : un `DecoratedBox` sans enfant serait sinon
              // haut de zéro et la portion lue ne peindrait rien.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: constraints.maxWidth * fraction,
                child: DecoratedBox(
                  key: const Key('progress-fill'),
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: BorderRadius.circular(_height / 2),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Une barre épaisse dont le pourcentage est écrit à l'intérieur.
///
/// Le chiffre se loge dans la portion lue tant qu'elle est assez large ; en
/// deçà il passe juste à côté, sur le rail. Sans cette bascule, un livre à 3 %
/// afficherait un pourcentage illisible, écrasé dans quelques pixels.
class _ThickBar extends StatelessWidget {
  const _ThickBar({
    required this.percent,
    required this.palette,
    required this.height,
  });

  /// Largeur minimale de la portion lue pour y loger le chiffre.
  static const double _insideThreshold = 62;

  final int percent;
  final ProgressCardPalette palette;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fraction = (percent / 100).clamp(0.0, 1.0);
    final radius = BorderRadius.circular(height / 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final filled = constraints.maxWidth * fraction;
        final inside = filled >= _insideThreshold;

        return SizedBox(
          height: height,
          child: Stack(
            children: <Widget>[
              // Le rail reste discret : c'est la portion lue qui porte le
              // regard.
              DecoratedBox(
                key: const Key('progress-track'),
                decoration: BoxDecoration(
                  color: palette.foreground.withValues(alpha: 0.16),
                  borderRadius: radius,
                ),
                child: const SizedBox.expand(),
              ),
              // `Positioned` avec haut et bas fixés : sans cela, dans une
              // `Stack` aux contraintes lâches, un `DecoratedBox` sans enfant
              // se retrouve haut de zéro et la portion lue ne peint rien —
              // c'est exactement ce qui rendait la barre invisible.
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: filled,
                child: DecoratedBox(
                  key: const Key('progress-fill'),
                  decoration: BoxDecoration(
                    color: palette.accent,
                    borderRadius: radius,
                  ),
                ),
              ),
              // Le chiffre est borné à la portion lue quand il y tient : aligné
              // sur la barre entière, il se retrouverait sur le rail vide, dans
              // la couleur prévue pour le remplissage — donc illisible.
              Positioned(
                left: inside ? 0 : filled + 10,
                top: 0,
                bottom: 0,
                width: inside ? filled : null,
                right: inside ? null : 0,
                child: Padding(
                  padding: EdgeInsets.only(right: inside ? height * 0.45 : 0),
                  child: Align(
                    alignment:
                        inside ? Alignment.centerRight : Alignment.centerLeft,
                    child: Text(
                      '$percent %',
                      key: const Key('progress-label'),
                      style: TextStyle(
                        color: inside ? palette.onAccent : palette.foreground,
                        fontSize: height * 0.52,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
