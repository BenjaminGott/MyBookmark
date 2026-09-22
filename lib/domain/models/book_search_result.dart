import 'package:meta/meta.dart';

/// Taille de couverture proposée par Open Library.
enum CoverSize {
  small('S'),
  medium('M'),
  large('L');

  const CoverSize(this.suffix);

  final String suffix;
}

/// Un résultat de recherche Open Library, avant tout ajout en base.
///
/// Rien n'est garanti côté API : titre mis à part, chaque champ peut manquer.
@immutable
class BookSearchResult {
  const BookSearchResult({
    required this.olKey,
    required this.title,
    this.author,
    this.pageCount,
    this.coverId,
    this.firstPublishYear,
  });

  /// Clé de l'œuvre, par exemple `/works/OL45804W`.
  final String olKey;

  final String title;
  final String? author;
  final int? pageCount;
  final int? coverId;
  final int? firstPublishYear;

  bool get hasCover => coverId != null;

  /// URL de la couverture dans la taille demandée, ou `null` s'il n'y en a pas.
  String? coverUrl([CoverSize size = CoverSize.medium]) {
    final id = coverId;
    if (id == null) {
      return null;
    }
    return 'https://covers.openlibrary.org/b/id/$id-${size.suffix}.jpg';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookSearchResult &&
          other.olKey == olKey &&
          other.title == title &&
          other.author == author &&
          other.pageCount == pageCount &&
          other.coverId == coverId &&
          other.firstPublishYear == firstPublishYear;

  @override
  int get hashCode =>
      Object.hash(olKey, title, author, pageCount, coverId, firstPublishYear);

  @override
  String toString() => 'BookSearchResult(olKey: $olKey, title: $title)';
}
