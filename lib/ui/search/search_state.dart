import 'package:meta/meta.dart';

import '../../core/failure.dart';
import '../../domain/models/book_search_result.dart';

/// Où en est la recherche à l'écran.
enum SearchStatus {
  /// Rien à afficher : champ vide ou saisie encore trop courte.
  idle,

  /// Une requête est en vol.
  loading,

  /// Une requête a abouti ; [SearchState.results] peut être vide.
  success,

  /// La dernière requête a échoué ; [SearchState.error] dit pourquoi.
  failure,
}

@immutable
class SearchState {
  const SearchState({
    this.query = '',
    this.status = SearchStatus.idle,
    this.results = const <BookSearchResult>[],
    this.error,
  });

  /// Le texte brut tapé par l'utilisateur, accents et ponctuation compris.
  final String query;

  final SearchStatus status;
  final List<BookSearchResult> results;
  final AppException? error;

  bool get isLoading => status == SearchStatus.loading;

  /// La recherche a abouti mais Open Library ne connaît rien de tel.
  bool get hasNoResult =>
      status == SearchStatus.success && results.isEmpty && query.trim().isNotEmpty;

  SearchState copyWith({
    String? query,
    SearchStatus? status,
    List<BookSearchResult>? results,
    AppException? Function()? error,
  }) {
    return SearchState(
      query: query ?? this.query,
      status: status ?? this.status,
      results: results ?? this.results,
      error: error == null ? this.error : error(),
    );
  }
}
