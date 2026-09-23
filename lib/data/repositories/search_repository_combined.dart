import 'dart:async';
import 'dart:collection';

import '../../core/cancellation.dart';
import '../../core/failure.dart';
import '../../domain/models/book_search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/services/search_result_merger.dart';
import '../../domain/services/text_normalizer.dart';
import '../remote/apple_books_client.dart';
import '../remote/open_library_client.dart';

/// Interroge Open Library et Apple Books en parallèle, et fusionne.
///
/// Apple Books répond en une seconde environ, Open Library en deux à six : la
/// première source arrivée est affichée tout de suite, la seconde la complète.
/// Si l'une des deux tombe en panne, l'autre suffit.
///
/// Le cache évite de rappeler les API quand l'utilisateur efface une lettre
/// puis la retape. Il ne survit pas à la fermeture de l'application : rien de
/// tout cela n'est écrit sur le disque.
class CombinedSearchRepository implements SearchRepository {
  CombinedSearchRepository({
    required this.openLibrary,
    required this.appleBooks,
    this.normalizer = const TextNormalizer(),
    this.cacheSize = 50,
  }) : merger = SearchResultMerger(normalizer: normalizer);

  final OpenLibraryClient openLibrary;
  final AppleBooksClient appleBooks;
  final TextNormalizer normalizer;
  final SearchResultMerger merger;

  /// Nombre de requêtes gardées en mémoire.
  final int cacheSize;

  /// Cache LRU : la requête la plus ancienne saute quand la taille est atteinte.
  final LinkedHashMap<String, List<BookSearchResult>> _cache =
      LinkedHashMap<String, List<BookSearchResult>>();

  final Map<String, String?> _descriptionCache = <String, String?>{};

  @override
  Stream<List<BookSearchResult>> search(
    String rawQuery, {
    CancellationToken? token,
  }) async* {
    final query = normalizer.normalize(rawQuery);
    if (query.length < kMinQueryLength) {
      yield const <BookSearchResult>[];
      return;
    }

    final cached = _cache.remove(query);
    if (cached != null) {
      // Remise en tête : c'est la requête la plus récemment utilisée.
      _cache[query] = cached;
      yield cached;
      return;
    }

    final fromOpenLibrary =
        _attempt(() => openLibrary.search(query, token: token));
    final fromApple = _attempt(() => appleBooks.search(query, token: token));

    final firstIsOpenLibrary = await Future.any(<Future<bool>>[
      fromOpenLibrary.then((_) => true),
      fromApple.then((_) => false),
    ]);
    final first = await (firstIsOpenLibrary ? fromOpenLibrary : fromApple);
    _throwIfCancelled(token);

    // Une liste vide attend l'autre source : l'afficher ferait croire, le
    // temps d'une seconde, qu'il n'y a aucun résultat.
    final firstResults = first.results;
    if (firstResults != null && firstResults.isNotEmpty) {
      yield List<BookSearchResult>.unmodifiable(firstResults);
    }

    final second = await (firstIsOpenLibrary ? fromApple : fromOpenLibrary);
    _throwIfCancelled(token);

    final secondResults = second.results;
    if (firstResults == null && secondResults == null) {
      // Les deux sont en panne : l'erreur d'Open Library, la source
      // principale, est celle qu'on raconte.
      throw (firstIsOpenLibrary ? first : second).error!;
    }

    final results = merger.merge(
      firstResults ?? const <BookSearchResult>[],
      secondResults ?? const <BookSearchResult>[],
    );

    // Une source en panne ne fige pas une liste incomplète dans le cache.
    if (first.error == null && second.error == null) {
      _remember(query, results);
    }
    yield results;
  }

  @override
  Future<String?> loadDescription(
    String olKey, {
    CancellationToken? token,
  }) async {
    if (olKey.startsWith(BookSearchResult.appleKeyPrefix)) {
      return null;
    }
    if (_descriptionCache.containsKey(olKey)) {
      return _descriptionCache[olKey];
    }

    final description =
        await openLibrary.fetchDescription(olKey, token: token);
    _descriptionCache[olKey] = description;
    return description;
  }

  /// Lance une source sans jamais lever : l'échec est rendu comme une valeur,
  /// pour que la panne de l'une n'interrompe pas l'attente de l'autre.
  Future<_Outcome> _attempt(
    Future<List<BookSearchResult>> Function() request,
  ) async {
    try {
      return _Outcome.success(await request());
    } on AppException catch (error) {
      return _Outcome.failure(error);
    }
  }

  void _throwIfCancelled(CancellationToken? token) {
    if (token != null && token.isCancelled) {
      throw const RequestCancelledException();
    }
  }

  void _remember(String query, List<BookSearchResult> results) {
    _cache[query] = results;
    while (_cache.length > cacheSize) {
      _cache.remove(_cache.keys.first);
    }
  }
}

class _Outcome {
  const _Outcome.success(List<BookSearchResult> this.results) : error = null;
  const _Outcome.failure(AppException this.error) : results = null;

  final List<BookSearchResult>? results;
  final AppException? error;
}
