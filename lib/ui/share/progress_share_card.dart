import 'package:flutter/material.dart';

import '../../domain/models/library_item.dart';
import '../../domain/models/shelf.dart';
import '../../domain/services/reading_progress.dart';
import '../shelf_labels.dart';
import 'progress_card_palette.dart';

/// La carte de progression partagée, dessinée à taille fixe.
///
/// Elle mesure toujours [cardWidth] × [cardHeight] : capturée à un ratio de 3,
/// elle sort en 1080 × 1920, le format attendu par les réseaux sociaux. Rien
/// dans cette carte ne dépend du thème de l'application ni de la taille de
/// l'écran, pour que l'image partagée soit identique d'un téléphone à l'autre.
///
/// La composition est alignée à gauche, la couverture posée sur un rail
/// vertical et le pourcentage traité en grand chiffre maigre : une mise en page
/// éditoriale, qui ne cherche à ressembler à aucune application existante.
class ProgressShareCard extends StatelessWidget {
  const ProgressShareCard({
    required this.item,
    required this.palette,
    super.key,
    this.cover,
    this.captureKey,
  });

  static const double cardWidth = 360;
  static const double cardHeight = 640;

  /// Ratio de capture : 360 × 3 = 1080, 640 × 3 = 1920.
  static const double captureRatio = 3;

  final LibraryItem item;
  final ProgressCardPalette palette;

  /// La couverture, déjà chargée. Nulle si le livre n'en a pas.
  final ImageProvider? cover;

  /// La clé de la frontière de capture, posée au plus près de la carte.
  ///
  /// La frontière est à l'intérieur de la carte, et non autour : c'est ce qui
  /// garantit qu'elle mesure exactement 360 × 640 et que l'image sorte en
  /// 1080 × 1920, quelles que soient les contraintes du parent.
  final GlobalKey? captureKey;

  @override
  Widget build(BuildContext context) {
    final book = item.book;
    final percent = ReadingProgress.percent(
      currentPage: item.currentEntry.currentPage,
      pageCount: book.pageCount,
    );

    // Le `Center` desserre les contraintes reçues : sans lui, un parent au
    // dimensionnement serré étirerait la carte et la capture ne ferait plus
    // 1080 × 1920.
    return Center(
      child: RepaintBoundary(
        key: captureKey,
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[palette.top, palette.bottom],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Kicker(item: item, palette: palette),
                  const Spacer(),
                  if (cover != null)
                    _Cover(cover: cover!)
                  else
                    _NoCoverMark(palette: palette),
                  const SizedBox(height: 28),
                  _Title(item: item, palette: palette, large: cover == null),
                  const Spacer(),
                  if (item.currentEntry.rating != null) ...<Widget>[
                    _Stars(rating: item.currentEntry.rating!, palette: palette),
                    const SizedBox(height: 20),
                  ],
                  if (percent != null)
                    _Progress(
                      percent: percent,
                      currentPage: item.currentEntry.currentPage,
                      pageCount: book.pageCount!,
                      palette: palette,
                    )
                  else
                    // Sans nombre de pages, aucun pourcentage n'a de sens : la
                    // carte annonce simplement où en est le livre.
                    _ShelfOnly(item: item, palette: palette),
                  const SizedBox(height: 22),
                  _Signature(palette: palette),
                ],
              ),
            ),
          ),
        ),
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
        Text(
          label,
          style: TextStyle(
            color: palette.foreground,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.2,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.cover});

  final ImageProvider cover;

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
          width: 152,
          height: 228,
          fit: BoxFit.cover,
          // L'image est déjà en cache au moment de la capture ; ce rendu
          // immédiat évite un fondu qui sortirait à moitié transparent.
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

/// Le substitut de couverture : deux filets et une initiale.
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
    required this.large,
  });

  final LibraryItem item;
  final ProgressCardPalette palette;

  /// Sans couverture, le titre prend la place laissée libre.
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item.book.title,
          maxLines: large ? 4 : 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.foreground,
            fontSize: large ? 38 : 27,
            fontWeight: FontWeight.w700,
            height: 1.12,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.book.author ?? 'Auteur inconnu',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: palette.foreground.withValues(alpha: 0.78),
            fontSize: 15,
            fontWeight: FontWeight.w400,
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
              size: 18,
              color: palette.foreground.withValues(
                alpha: star <= rating ? 0.95 : 0.35,
              ),
            ),
          ),
      ],
    );
  }
}

/// La barre, les pages et le grand pourcentage.
class _Progress extends StatelessWidget {
  const _Progress({
    required this.percent,
    required this.currentPage,
    required this.pageCount,
    required this.palette,
  });

  final int percent;
  final int currentPage;
  final int pageCount;
  final ProgressCardPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 5,
            child: Stack(
              children: <Widget>[
                ColoredBox(
                  color: palette.foreground.withValues(alpha: 0.22),
                  child: const SizedBox.expand(),
                ),
                FractionallySizedBox(
                  widthFactor: (percent / 100).clamp(0.0, 1.0),
                  child: ColoredBox(color: palette.accent),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(
                'page $currentPage sur $pageCount',
                style: TextStyle(
                  color: palette.foreground.withValues(alpha: 0.8),
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Text(
              '$percent',
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
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Ce qu'on affiche quand le nombre de pages est inconnu.
class _ShelfOnly extends StatelessWidget {
  const _ShelfOnly({required this.item, required this.palette});

  final LibraryItem item;
  final ProgressCardPalette palette;

  @override
  Widget build(BuildContext context) {
    final page = item.currentEntry.currentPage;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Text(
            page > 0 ? 'page $page' : 'nombre de pages inconnu',
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
            fontSize: 22,
            fontWeight: FontWeight.w300,
            height: 1,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _Signature extends StatelessWidget {
  const _Signature({required this.palette});

  final ProgressCardPalette palette;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Biblivre',
      style: TextStyle(
        color: palette.foreground.withValues(alpha: 0.45),
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.6,
      ),
    );
  }
}
