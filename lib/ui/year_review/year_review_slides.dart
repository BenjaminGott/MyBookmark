import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/year_review.dart';
import '../l10n/l10n.dart';
import '../widgets/book_cover.dart';

/// Les pages d'un bilan, dans l'ordre. Une page sans matière (aucune note,
/// aucun auteur lu deux fois…) est simplement omise.
List<Widget> yearReviewSlides(YearReview review) => <Widget>[
  _IntroSlide(review),
  _CountSlide(review),
  _MonthSlide(review),
  if (review.favorite != null) _FavoriteSlide(review),
  if (review.topAuthor != null) _AuthorSlide(review),
  if (review.longest != null || review.averageDays != null)
    _LongestSlide(review),
  _OutroSlide(review),
];

/// La taille de dessin d'une page : 9:16, exportée × 3 en 1080 × 1920.
const Size yearReviewSlideSize = Size(360, 640);

const Color _deep = Color(0xFF0B3431);
const Color _mint = Color(0xFFCFE3DD);

/// Le fond commun : un dégradé vert, un halo jaune et le ruban du marque-page.
class _Slide extends StatelessWidget {
  const _Slide({required this.children, this.halo = Alignment.topRight});

  final List<Widget> children;
  final Alignment halo;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: yearReviewSlideSize,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[AppTheme.green, _deep],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: halo,
                    radius: 0.9,
                    colors: <Color>[
                      AppTheme.yellow.withValues(alpha: 0.22),
                      AppTheme.yellow.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            // Le ruban jaune, comme le signet d'un livre.
            const Positioned(
              top: 0,
              left: 28,
              child: CustomPaint(size: Size(22, 64), painter: _RibbonPainter()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 92, 28, 36),
              // Fusionné, pas remplacé : la page garde la police de l'app.
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white, height: 1.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - 9)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppTheme.yellow);
  }

  @override
  bool shouldRepaint(_RibbonPainter oldDelegate) => false;
}

class _Kicker extends StatelessWidget {
  const _Kicker(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.yellow,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
    );
  }
}

class _BigNumber extends StatelessWidget {
  const _BigNumber(this.text, {this.size = 112});

  final String text;
  final double size;

  /// Serré pour les chiffres, à peine pour les mots (« Août »).
  double get _spacing => size >= 100 ? -3 : -0.5;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: size,
          fontWeight: FontWeight.w900,
          height: 1,
          letterSpacing: _spacing,
        ),
      ),
    );
  }
}

/// Le pied de chaque page : le nom de l'app, discret.
class _Signature extends StatelessWidget {
  const _Signature();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Image.asset('assets/logo.png', width: 22, height: 22),
        const SizedBox(width: 8),
        Text(
          context.l10n.appTitle,
          style: const TextStyle(
            color: _mint,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// La mosaïque de couvertures la plus grande possible dans [space] : on
/// essaie chaque nombre de colonnes et on garde le meilleur. Peu de livres,
/// grandes couvertures.
///
/// Une grille pleine est préférée à une grille à trous : quatre livres font
/// un carré de deux sur deux plutôt qu'une rangée de trois et un orphelin.
@visibleForTesting
({int columns, double width}) coverGridLayout({
  required int count,
  required Size space,
  double gap = 10,
  double maxWidth = 200,
  double ratio = 1.5,
}) {
  var best = (columns: 1, width: 0.0);
  var bestScore = -1.0;
  for (var columns = 1; columns <= math.max(count, 1); columns++) {
    final rows = (count / columns).ceil();
    final byWidth = (space.width - gap * (columns - 1)) / columns;
    final byHeight = (space.height - gap * (rows - 1)) / rows / ratio;
    final width = math.min(math.min(byWidth, byHeight), maxWidth);
    final filled = count / (columns * rows);
    final score = width * math.sqrt(filled);
    if (score > bestScore) {
      best = (columns: columns, width: width);
      bestScore = score;
    }
  }
  return best;
}

/// Les couvertures en mosaïque, à la taille que permet leur nombre.
class _CoverGrid extends StatelessWidget {
  const _CoverGrid({
    required this.books,
    this.maxWidth = 200,
    this.gap = 10,
    this.shadow = false,
  });

  final List<YearReviewBook> books;
  final double maxWidth;
  final double gap;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = coverGridLayout(
          count: books.length,
          space: constraints.biggest,
          gap: gap,
          maxWidth: maxWidth,
        );
        final width = layout.width.floorToDouble();
        return Align(
          alignment: Alignment.centerLeft,
          // Juste la largeur des colonnes choisies : la mosaïque passe à la
          // ligne là où le calcul l'a prévu.
          child: SizedBox(
            width: layout.columns * width + gap * (layout.columns - 1),
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: <Widget>[
                for (final book in books)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width / 15),
                      boxShadow: shadow
                          ? const <BoxShadow>[
                              BoxShadow(color: Colors.black38, blurRadius: 10),
                            ]
                          : null,
                    ),
                    child: BookCover(
                      url: book.coverUrl,
                      width: width,
                      height: width * 1.5,
                      borderRadius: width / 15,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String _number(BuildContext context, int value) => NumberFormat.decimalPattern(
  Localizations.localeOf(context).toLanguageTag(),
).format(value);

class _IntroSlide extends StatelessWidget {
  const _IntroSlide(this.review);

  final YearReview review;

  @override
  Widget build(BuildContext context) {
    // Les couvertures de l'année, les six dernières lues au plus : moins il
    // y en a, plus elles sont grandes.
    final covers = review.books.reversed.take(6).toList();
    return _Slide(
      halo: Alignment.bottomLeft,
      children: <Widget>[
        _Kicker(context.l10n.yrIntroKicker),
        const SizedBox(height: 8),
        _BigNumber('${review.year}', size: 120),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: _CoverGrid(books: covers, shadow: true),
          ),
        ),
        const _Signature(),
      ],
    );
  }
}

class _CountSlide extends StatelessWidget {
  const _CountSlide(this.review);

  final YearReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Slide(
      children: <Widget>[
        _Kicker(l10n.yrIntroKicker),
        const Spacer(),
        _BigNumber(_number(context, review.bookCount), size: 180),
        Text(
          l10n.yrBooksCount(review.bookCount),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
        ),
        if (review.pagesRead > 0) ...<Widget>[
          const SizedBox(height: 28),
          Container(width: 48, height: 4, color: AppTheme.yellow),
          const SizedBox(height: 20),
          Text(
            l10n.yrPages(review.pagesRead),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: _mint,
            ),
          ),
        ],
        const Spacer(flex: 2),
        const _Signature(),
      ],
    );
  }
}

class _MonthSlide extends StatelessWidget {
  const _MonthSlide(this.review);

  final YearReview review;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final busiest = review.busiestMonth;
    final monthName = DateFormat.MMMM(
      locale,
    ).format(DateTime(review.year, busiest));
    final most = review.booksPerMonth.reduce((a, b) => a > b ? a : b);

    return _Slide(
      halo: Alignment.bottomRight,
      children: <Widget>[
        _Kicker(context.l10n.yrMonthKicker),
        const SizedBox(height: 16),
        _BigNumber(
          monthName[0].toUpperCase() + monthName.substring(1),
          size: 64,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.yrMonthBooks(
            review.booksPerMonth[busiest - 1],
            monthName,
          ),
          style: const TextStyle(fontSize: 18, color: _mint),
        ),
        const Spacer(),
        SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              for (var month = 1; month <= 12; month++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          // Un mois vide garde un trait, pour lire l'année.
                          height:
                              4 + 150 * review.booksPerMonth[month - 1] / most,
                          decoration: BoxDecoration(
                            color: month == busiest
                                ? AppTheme.yellow
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateFormat(
                            'MMMMM',
                            locale,
                          ).format(DateTime(review.year, month)),
                          style: const TextStyle(fontSize: 12, color: _mint),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Spacer(),
        const _Signature(),
      ],
    );
  }
}

class _FavoriteSlide extends StatelessWidget {
  const _FavoriteSlide(this.review);

  final YearReview review;

  @override
  Widget build(BuildContext context) {
    final book = review.favorite!;
    return _Slide(
      children: <Widget>[
        _Kicker(context.l10n.yrFavoriteKicker),
        const Spacer(),
        Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: const <BoxShadow>[
                BoxShadow(color: Colors.black45, blurRadius: 24),
              ],
            ),
            child: BookCover(
              url: book.coverUrl,
              width: 176,
              height: 264,
              borderRadius: 10,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        if (book.author != null)
          Text(
            book.author!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, color: _mint),
          ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            for (var star = 1; star <= 5; star++)
              Icon(
                star <= book.rating! ? Icons.star : Icons.star_border,
                color: AppTheme.yellow,
                size: 26,
              ),
          ],
        ),
        const Spacer(),
        const _Signature(),
      ],
    );
  }
}

class _AuthorSlide extends StatelessWidget {
  const _AuthorSlide(this.review);

  final YearReview review;

  @override
  Widget build(BuildContext context) {
    final author = review.topAuthor!;
    final covers = <YearReviewBook>[
      for (final book in review.books)
        if (book.author?.trim().toLowerCase() == author.toLowerCase()) book,
    ].take(3).toList();
    return _Slide(
      halo: Alignment.centerLeft,
      children: <Widget>[
        _Kicker(context.l10n.yrAuthorKicker),
        const Spacer(),
        _BigNumber(author, size: 52),
        const SizedBox(height: 10),
        Text(
          context.l10n.yrAuthorBooks(review.topAuthorCount),
          style: const TextStyle(fontSize: 22, color: _mint),
        ),
        const SizedBox(height: 32),
        Row(
          children: <Widget>[
            for (final book in covers)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: BookCover(url: book.coverUrl, width: 88, height: 132),
              ),
          ],
        ),
        const Spacer(),
        const _Signature(),
      ],
    );
  }
}

class _LongestSlide extends StatelessWidget {
  const _LongestSlide(this.review);

  final YearReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final longest = review.longest;
    final days = review.averageDays;
    return _Slide(
      halo: Alignment.bottomLeft,
      children: <Widget>[
        _Kicker(l10n.yrLongestKicker),
        const Spacer(),
        if (longest != null) ...<Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              BookCover(url: longest.coverUrl, width: 104, height: 156),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      longest.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.yrLongestPages(longest.pageCount!),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.yellow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
        if (days != null)
          Text(
            l10n.yrAverageDays(days),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
        const Spacer(),
        const _Signature(),
      ],
    );
  }
}

class _OutroSlide extends StatelessWidget {
  const _OutroSlide(this.review);

  final YearReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = <(String, String)>[
      (l10n.yrOutroBooks, _number(context, review.bookCount)),
      if (review.pagesRead > 0)
        (l10n.yrOutroPages, _number(context, review.pagesRead)),
      if (review.favorite != null)
        (l10n.yrOutroFavorite, review.favorite!.title),
      if (review.topAuthor != null) (l10n.yrOutroAuthor, review.topAuthor!),
    ];
    return _Slide(
      halo: Alignment.center,
      children: <Widget>[
        _Kicker(l10n.yrOutroKicker('${review.year}')),
        const SizedBox(height: 24),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _CoverGrid(
                    books: review.books.reversed.take(8).toList(),
                    maxWidth: 110,
                    gap: 6,
                  ),
                ),
                const SizedBox(height: 4),
                for (final (label, value) in rows)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          label.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            color: _mint,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        const _Signature(),
      ],
    );
  }
}
