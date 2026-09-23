import 'package:http/http.dart' as http;

import '../../core/cancellation.dart';
import '../../domain/models/book_search_result.dart';
import 'json_http.dart';

/// Accès à la recherche publique d'Apple Books (API iTunes Search) : pas de
/// clé, pas de compte.
///
/// Complète Open Library : le catalogue français y est mieux couvert, la
/// réponse arrive en une seconde environ et les couvertures, servies par le
/// CDN d'Apple, en quelques centaines de millisecondes.
class AppleBooksClient {
  AppleBooksClient({http.Client? httpClient, Duration? timeout})
      : _http = JsonHttp(httpClient: httpClient, timeout: timeout);

  static const String _host = 'itunes.apple.com';

  final JsonHttp _http;

  /// Cherche des livres numériques dans la boutique française.
  Future<List<BookSearchResult>> search(
    String normalizedQuery, {
    int limit = 20,
    CancellationToken? token,
  }) async {
    if (normalizedQuery.isEmpty) {
      return const <BookSearchResult>[];
    }

    final uri = Uri.https(_host, '/search', <String, String>{
      'term': normalizedQuery,
      'media': 'ebook',
      'country': 'FR',
      'lang': 'fr_fr',
      'limit': '$limit',
    });

    final body = await _http.get(uri, token: token);
    return AppleBooksParser.parseSearchResponse(body);
  }

  void close() => _http.close();
}

/// Lecture des réponses d'Apple Books, aussi défensive que celle d'Open
/// Library : un document illisible est écarté, un champ douteux est ignoré.
class AppleBooksParser {
  const AppleBooksParser._();

  static List<BookSearchResult> parseSearchResponse(Object? json) {
    if (json is! Map<String, Object?>) {
      return const <BookSearchResult>[];
    }
    final results = json['results'];
    if (results is! List<Object?>) {
      return const <BookSearchResult>[];
    }

    return <BookSearchResult>[
      for (final doc in results) ?parseDoc(doc),
    ];
  }

  static BookSearchResult? parseDoc(Object? json) {
    if (json is! Map<String, Object?>) {
      return null;
    }

    final id = json['trackId'];
    final title = _asNonEmptyString(json['trackName']);
    if (id is! int || title == null) {
      return null;
    }

    final artwork = _asNonEmptyString(json['artworkUrl100']);
    return BookSearchResult(
      olKey: '${BookSearchResult.appleKeyPrefix}$id',
      title: title,
      author: _asNonEmptyString(json['artistName']),
      firstPublishYear: _year(json['releaseDate']),
      artworkUrl: artwork == null ? null : resizeArtwork(artwork, 200, 300),
      largeArtworkUrl: artwork == null ? null : resizeArtwork(artwork, 600, 900),
      description: cleanDescription(json['description']),
    );
  }

  /// Apple sert la même image dans n'importe quelle taille : il suffit de
  /// changer le `100x100bb` final. Le ratio de la couverture est conservé.
  static String resizeArtwork(String url, int width, int height) {
    return url.replaceFirst(
      RegExp(r'/\d+x\d+bb\.(jpg|png)$'),
      '/${width}x${height}bb.jpg',
    );
  }

  /// Le résumé arrive en HTML : on garde le texte et les retours à la ligne.
  static String? cleanDescription(Object? value) {
    if (value is! String) {
      return null;
    }
    final text = value
        .replaceAll(RegExp(r'<br\s*/?>|</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&rsquo;', '’')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
    return text.isEmpty ? null : text;
  }

  static int? _year(Object? value) {
    if (value is! String || value.length < 4) {
      return null;
    }
    final year = int.tryParse(value.substring(0, 4));
    return year == null || year <= 0 ? null : year;
  }

  static String? _asNonEmptyString(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
