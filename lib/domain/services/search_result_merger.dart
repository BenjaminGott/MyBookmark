import '../models/book_search_result.dart';
import 'text_normalizer.dart';

/// Fusionne les résultats d'Open Library et d'Apple Books.
///
/// Les résultats déjà affichés gardent leur place : ceux de la seconde source
/// complètent un livre reconnu, ou s'ajoutent à la fin. La liste ne se
/// réordonne donc jamais sous le doigt de l'utilisateur.
class SearchResultMerger {
  const SearchResultMerger({this.normalizer = const TextNormalizer()});

  final TextNormalizer normalizer;

  /// Titres de moins de 4 caractères : trop courts pour qu'un préfixe commun
  /// dise quoi que ce soit.
  static const int _minPrefixLength = 4;

  List<BookSearchResult> merge(
    List<BookSearchResult> first,
    List<BookSearchResult> second,
  ) {
    final merged = List<BookSearchResult>.of(first);
    final completed = <int>{};

    for (final incoming in second) {
      final index = _indexOfMatch(merged, completed, incoming);
      if (index == null) {
        merged.add(incoming);
        continue;
      }
      merged[index] = _combine(merged[index], incoming);
      completed.add(index);
    }
    return List<BookSearchResult>.unmodifiable(merged);
  }

  int? _indexOfMatch(
    List<BookSearchResult> results,
    Set<int> completed,
    BookSearchResult incoming,
  ) {
    for (var i = 0; i < results.length; i++) {
      final candidate = results[i];
      // Un livre ne se complète qu'une fois, et jamais par sa propre source.
      if (completed.contains(i) ||
          candidate.isOpenLibraryWork == incoming.isOpenLibraryWork) {
        continue;
      }
      if (isSameBook(candidate, incoming)) {
        return i;
      }
    }
    return null;
  }

  /// Même titre (ou l'un prolonge l'autre : « Dune » et « Dune - Tome 1 »),
  /// et au moins un nom d'auteur en commun quand les deux sont connus.
  bool isSameBook(BookSearchResult a, BookSearchResult b) {
    final titleA = normalizer.normalize(a.title);
    final titleB = normalizer.normalize(b.title);
    final authorA = a.author;
    final authorB = b.author;

    if (authorA == null || authorB == null) {
      return titleA == titleB;
    }
    return _titlesMatch(titleA, titleB) && _authorsMatch(authorA, authorB);
  }

  bool _titlesMatch(String a, String b) {
    if (a == b) {
      return true;
    }
    final (shorter, longer) = a.length < b.length ? (a, b) : (b, a);
    return shorter.length >= _minPrefixLength &&
        longer.startsWith('$shorter ');
  }

  bool _authorsMatch(String a, String b) {
    final namesA = _names(a);
    return _names(b).any(namesA.contains);
  }

  /// Les mots d'un nom d'auteur, sans les initiales.
  Set<String> _names(String author) => normalizer
      .normalize(author)
      .split(' ')
      .where((word) => word.length >= 3)
      .toSet();

  /// Open Library apporte la clé d'œuvre, les pages et l'année de première
  /// parution ; Apple Books, une couverture rapide et un résumé en français.
  /// Le titre et l'auteur déjà affichés ne bougent pas.
  BookSearchResult _combine(BookSearchResult shown, BookSearchResult incoming) {
    final (openLibrary, apple) =
        shown.isOpenLibraryWork ? (shown, incoming) : (incoming, shown);

    return BookSearchResult(
      olKey: openLibrary.olKey,
      title: shown.title,
      author: shown.author ?? incoming.author,
      pageCount: openLibrary.pageCount,
      coverId: openLibrary.coverId,
      firstPublishYear: openLibrary.firstPublishYear ?? apple.firstPublishYear,
      artworkUrl: apple.artworkUrl,
      largeArtworkUrl: apple.largeArtworkUrl,
      description: apple.description,
    );
  }
}
