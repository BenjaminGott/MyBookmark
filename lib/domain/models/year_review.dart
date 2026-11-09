import 'package:meta/meta.dart';

import 'book.dart';
import 'reading_entry.dart';

/// Une lecture terminée : le livre et l'entrée qui porte sa date de fin.
///
/// Une relecture terminée compte comme une lecture de plus.
@immutable
class FinishedReading {
  const FinishedReading({required this.book, required this.entry});

  final Book book;
  final ReadingEntry entry;
}

/// Un livre tel que le bilan s'en souvient.
///
/// Recopié au moment de la création du bilan : modifier ou supprimer le livre
/// ensuite ne change pas le bilan, qui reste figé.
@immutable
class YearReviewBook {
  const YearReviewBook({
    required this.title,
    required this.finishedAt,
    this.author,
    this.coverUrl,
    this.pageCount,
    this.rating,
  });

  factory YearReviewBook.fromJson(Map<String, Object?> json) => YearReviewBook(
    title: json['title']! as String,
    author: json['author'] as String?,
    coverUrl: json['coverUrl'] as String?,
    pageCount: json['pageCount'] as int?,
    rating: json['rating'] as int?,
    finishedAt: DateTime.parse(json['finishedAt']! as String),
  );

  final String title;
  final String? author;
  final String? coverUrl;
  final int? pageCount;
  final int? rating;
  final DateTime finishedAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'title': title,
    'author': author,
    'coverUrl': coverUrl,
    'pageCount': pageCount,
    'rating': rating,
    'finishedAt': finishedAt.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearReviewBook &&
          other.title == title &&
          other.author == author &&
          other.coverUrl == coverUrl &&
          other.pageCount == pageCount &&
          other.rating == rating &&
          other.finishedAt == finishedAt;

  @override
  int get hashCode =>
      Object.hash(title, author, coverUrl, pageCount, rating, finishedAt);
}

/// Le bilan d'une année de lecture, figé le jour de sa création.
///
/// Tout est calculé une fois pour toutes par `YearReviewBuilder` puis
/// enregistré : seul « Mettre à jour » le recalcule.
@immutable
class YearReview {
  const YearReview({
    required this.year,
    required this.createdAt,
    required this.books,
    required this.pagesRead,
    required this.booksPerMonth,
    this.averageDays,
    this.averageRating,
    this.topAuthor,
    this.topAuthorCount = 0,
  });

  factory YearReview.fromJson(Map<String, Object?> json) => YearReview(
    year: json['year']! as int,
    createdAt: DateTime.parse(json['createdAt']! as String),
    books: <YearReviewBook>[
      for (final book in json['books']! as List<Object?>)
        YearReviewBook.fromJson((book! as Map).cast<String, Object?>()),
    ],
    pagesRead: json['pagesRead']! as int,
    booksPerMonth: (json['booksPerMonth']! as List<Object?>).cast<int>(),
    averageDays: json['averageDays'] as int?,
    averageRating: (json['averageRating'] as num?)?.toDouble(),
    topAuthor: json['topAuthor'] as String?,
    topAuthorCount: json['topAuthorCount'] as int? ?? 0,
  );

  /// Version du format enregistré, pour pouvoir le faire évoluer.
  static const int formatVersion = 1;

  final int year;
  final DateTime createdAt;

  /// Les livres terminés dans l'année, du plus ancien au plus récent.
  final List<YearReviewBook> books;

  /// Somme des pages des livres dont on connaît le nombre de pages.
  final int pagesRead;

  /// Nombre de livres terminés chaque mois, de janvier (index 0) à décembre.
  final List<int> booksPerMonth;

  /// Durée moyenne entre le début et la fin d'un livre, en jours, quand au
  /// moins un livre a ses deux dates.
  final int? averageDays;

  /// Note moyenne des livres notés, sur 5.
  final double? averageRating;

  /// L'auteur le plus lu, s'il l'a été au moins deux fois.
  final String? topAuthor;
  final int topAuthorCount;

  int get bookCount => books.length;

  /// Le mois le plus chargé (1 à 12), le premier en cas d'égalité.
  int get busiestMonth {
    var best = 0;
    for (var month = 1; month < 12; month++) {
      if (booksPerMonth[month] > booksPerMonth[best]) {
        best = month;
      }
    }
    return best + 1;
  }

  /// Le livre le mieux noté ; à égalité, le dernier terminé.
  YearReviewBook? get favorite {
    YearReviewBook? best;
    for (final book in books) {
      final rating = book.rating;
      if (rating != null && (best == null || rating >= best.rating!)) {
        best = book;
      }
    }
    return best;
  }

  /// Le plus long livre de l'année, quand un nombre de pages est connu.
  YearReviewBook? get longest {
    YearReviewBook? best;
    for (final book in books) {
      final pages = book.pageCount;
      if (pages != null && (best == null || pages > best.pageCount!)) {
        best = book;
      }
    }
    return best;
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'format': formatVersion,
    'year': year,
    'createdAt': createdAt.toIso8601String(),
    'books': <Map<String, Object?>>[for (final book in books) book.toJson()],
    'pagesRead': pagesRead,
    'booksPerMonth': booksPerMonth,
    'averageDays': averageDays,
    'averageRating': averageRating,
    'topAuthor': topAuthor,
    'topAuthorCount': topAuthorCount,
  };
}
