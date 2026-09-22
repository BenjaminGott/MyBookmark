import 'dart:collection';

import '../../core/cancellation.dart';
import '../../domain/models/book_search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/services/text_normalizer.dart';
import '../remote/open_library_client.dart';

/// Implémentation Open Library, avec normalisation et cache en mémoire.
///
/// Le cache évite de rappeler l'API quand l'utilisateur efface une lettre puis
/// la retape, ou revient en arrière dans sa saisie. Il ne survit pas à la
/// fermeture de l'application : rien de tout cela n'est écrit sur le disque.
class OpenLibrarySearchRepository implements SearchRepository {
  OpenLibrarySearchRepository({
    required this.client,
    this.normalizer = const TextNormalizer(),
    this.cacheSize = 50,
  });

  final OpenLibraryClient client;
  final TextNormalizer normalizer;

  /// Nombre de requêtes gardées en mémoire.
  final int cacheSize;

  /// Cache LRU : la requête la plus ancienne saute quand la taille est atteinte.
  final LinkedHashMap<String, List<BookSearchResult>> _cache =
      LinkedHashMap<String, List<BookSearchResult>>();

  final Map<String, String?> _descriptionCache = <String, String?>{};

  @override
  Future<List<BookSearchResult>> search(
    String rawQuery, {
    CancellationToken? token,
  }) async {
    final query = normalizer.normalize(rawQuery);
    if (query.length < kMinQueryLength) {
      return const <BookSearchResult>[];
    }

    final cached = _cache.remove(query);
    if (cached != null) {
      // Remise en tête : c'est la requête la plus récemment utilisée.
      _cache[query] = cached;
      return cached;
    }

    // Figée avant d'être rendue : personne ne peut modifier une liste qui
    // vit aussi dans le cache.
    final results = List<BookSearchResult>.unmodifiable(
      await client.search(query, token: token),
    );

    // Une requête annulée entre-temps ne pollue pas le cache.
    if (token == null || !token.isCancelled) {
      _remember(query, results);
    }
    return results;
  }

  @override
  Future<String?> loadDescription(
    String olKey, {
    CancellationToken? token,
  }) async {
    if (_descriptionCache.containsKey(olKey)) {
      return _descriptionCache[olKey];
    }

    final description = await client.fetchDescription(olKey, token: token);
    _descriptionCache[olKey] = description;
    return description;
  }

  void _remember(String query, List<BookSearchResult> results) {
    _cache[query] = results;
    while (_cache.length > cacheSize) {
      _cache.remove(_cache.keys.first);
    }
  }
}
