import 'package:meta/meta.dart';

/// Taille de couverture proposée par Open Library.
enum CoverSize {
  small('S'),
  medium('M'),
  large('L');

  const CoverSize(this.suffix);

  final String suffix;
}

/// Un résultat de recherche, avant tout ajout en base.
///
/// Il vient d'Open Library, d'Apple Books, ou des deux fusionnés. Rien n'est
/// garanti côté API : titre mis à part, chaque champ peut manquer.
@immutable
class BookSearchResult {
  const BookSearchResult({
    required this.olKey,
    required this.title,
    this.author,
    this.pageCount,
    this.coverId,
    this.firstPublishYear,
    this.artworkUrl,
    this.largeArtworkUrl,
    this.description,
  });

  /// Préfixe des clés d'un livre qu'Open Library ne connaît pas.
  static const String appleKeyPrefix = 'apple:';

  /// Clé de l'œuvre, par exemple `/works/OL45804W`.
  ///
  /// Un livre trouvé seulement dans Apple Books prend une clé `apple:<id>` :
  /// elle sert, comme celle d'Open Library, à ne pas l'ajouter deux fois.
  final String olKey;

  final String title;
  final String? author;
  final int? pageCount;
  final int? coverId;
  final int? firstPublishYear;

  /// Couverture Apple Books en taille liste. Préférée à celle d'Open Library,
  /// dont le serveur met plusieurs secondes à répondre.
  final String? artworkUrl;

  /// La même couverture Apple Books, en grand.
  final String? largeArtworkUrl;

  /// Résumé déjà connu à la recherche (Apple Books le donne d'emblée).
  final String? description;

  /// L'œuvre existe dans Open Library, qui peut donc fournir son résumé.
  bool get isOpenLibraryWork => !olKey.startsWith(appleKeyPrefix);

  bool get hasCover => artworkUrl != null || coverId != null;

  /// URL de la couverture dans la taille demandée, ou `null` s'il n'y en a pas.
  String? coverUrl([CoverSize size = CoverSize.medium]) {
    final artwork = artworkUrl;
    if (artwork != null) {
      return size == CoverSize.large ? (largeArtworkUrl ?? artwork) : artwork;
    }
    final id = coverId;
    if (id == null) {
      return null;
    }
    return 'https://covers.openlibrary.org/b/id/$id-${size.suffix}.jpg';
  }

  BookSearchResult copyWith({
    String? olKey,
    String? title,
    String? author,
    int? pageCount,
    int? coverId,
    int? firstPublishYear,
    String? artworkUrl,
    String? largeArtworkUrl,
    String? description,
  }) {
    return BookSearchResult(
      olKey: olKey ?? this.olKey,
      title: title ?? this.title,
      author: author ?? this.author,
      pageCount: pageCount ?? this.pageCount,
      coverId: coverId ?? this.coverId,
      firstPublishYear: firstPublishYear ?? this.firstPublishYear,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      largeArtworkUrl: largeArtworkUrl ?? this.largeArtworkUrl,
      description: description ?? this.description,
    );
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
          other.firstPublishYear == firstPublishYear &&
          other.artworkUrl == artworkUrl &&
          other.largeArtworkUrl == largeArtworkUrl &&
          other.description == description;

  @override
  int get hashCode => Object.hash(
        olKey,
        title,
        author,
        pageCount,
        coverId,
        firstPublishYear,
        artworkUrl,
        largeArtworkUrl,
        description,
      );

  @override
  String toString() => 'BookSearchResult(olKey: $olKey, title: $title)';
}
