import '../models/library_item.dart';
import 'text_normalizer.dart';

/// Recherche dans « Ma bibliothèque », faite sur le téléphone.
///
/// Insensible à la casse, aux accents et à la ponctuation : « miserables »
/// trouve « Les Misérables ». Chaque mot cherché doit apparaître dans le
/// titre, l'auteur ou l'ISBN, dans n'importe quel ordre : « hugo mis » trouve
/// aussi le livre.
class LibrarySearch {
  const LibrarySearch([this._normalizer = const TextNormalizer()]);

  final TextNormalizer _normalizer;

  List<LibraryItem> filter(List<LibraryItem> items, String query) {
    final words = _normalizer
        .normalize(query)
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return items;
    }
    return <LibraryItem>[
      for (final item in items)
        if (_matches(item, words)) item,
    ];
  }

  bool _matches(LibraryItem item, List<String> words) {
    final book = item.book;
    final haystack = _normalizer.normalize(
      <String?>[
        book.title,
        book.author,
        book.isbn,
      ].whereType<String>().join(' '),
    );
    return words.every(haystack.contains);
  }
}
