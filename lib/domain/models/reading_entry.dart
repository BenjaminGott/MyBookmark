import 'package:meta/meta.dart';

import 'shelf.dart';

/// Une lecture d'un livre : son étagère, sa note, son avis et ses dates.
///
/// Un livre peut avoir plusieurs entrées — une par lecture ou relecture — mais
/// une seule porte [isCurrent], et c'est elle qui décide de l'étagère affichée
/// dans « Ma bibliothèque ». Les précédentes sont conservées telles quelles,
/// avec leur note et leur avis d'origine.
@immutable
class ReadingEntry {
  const ReadingEntry({
    required this.id,
    required this.bookId,
    required this.shelf,
    required this.currentPage,
    required this.isCurrent,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.review,
    this.startedAt,
    this.finishedAt,
  });

  final int id;
  final int bookId;
  final Shelf shelf;

  /// Note en étoiles entières, de 1 à 5. Nulle tant que le livre n'est pas noté.
  final int? rating;

  /// Commentaire libre, indépendant de la note : l'un peut exister sans l'autre.
  final String? review;

  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int currentPage;
  final bool isCurrent;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isRated => rating != null;
  bool get hasReview => review != null && review!.trim().isNotEmpty;

  ReadingEntry copyWith({
    int? id,
    int? bookId,
    Shelf? shelf,
    int? Function()? rating,
    String? Function()? review,
    DateTime? Function()? startedAt,
    DateTime? Function()? finishedAt,
    int? currentPage,
    bool? isCurrent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReadingEntry(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      shelf: shelf ?? this.shelf,
      rating: rating == null ? this.rating : rating(),
      review: review == null ? this.review : review(),
      startedAt: startedAt == null ? this.startedAt : startedAt(),
      finishedAt: finishedAt == null ? this.finishedAt : finishedAt(),
      currentPage: currentPage ?? this.currentPage,
      isCurrent: isCurrent ?? this.isCurrent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingEntry &&
          other.id == id &&
          other.bookId == bookId &&
          other.shelf == shelf &&
          other.rating == rating &&
          other.review == review &&
          other.startedAt == startedAt &&
          other.finishedAt == finishedAt &&
          other.currentPage == currentPage &&
          other.isCurrent == isCurrent &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        bookId,
        shelf,
        rating,
        review,
        startedAt,
        finishedAt,
        currentPage,
        isCurrent,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'ReadingEntry(id: $id, bookId: $bookId, shelf: ${shelf.wireName})';
}
