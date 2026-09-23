import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cancellation.dart';
import '../../core/failure.dart';
import '../../domain/models/book_search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/services/text_normalizer.dart';
import '../providers/search_providers.dart';
import 'search_state.dart';

/// Délai d'inactivité avant de lancer la requête.
///
/// Assez court pour que la liste suive la frappe, assez long pour ne pas
/// envoyer une requête par lettre.
const Duration kSearchDebounce = Duration(milliseconds: 250);

/// Pilote le champ de recherche : anti-rebond, annulation, états d'erreur.
class BookSearchController extends Notifier<SearchState> {
  Timer? _debounce;
  CancellationToken? _pending;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _cancelPending();
    });
    return const SearchState();
  }

  SearchRepository get _repository => ref.read(searchRepositoryProvider);
  TextNormalizer get _normalizer => ref.read(textNormalizerProvider);

  /// Appelé à chaque frappe.
  void onQueryChanged(String rawQuery) {
    _debounce?.cancel();
    _cancelPending();

    final normalized = _normalizer.normalize(rawQuery);

    if (normalized.length < kMinQueryLength) {
      state = SearchState(query: rawQuery);
      return;
    }

    state = state.copyWith(
      query: rawQuery,
      status: SearchStatus.loading,
      error: () => null,
    );

    _debounce = Timer(kSearchDebounce, () => unawaited(_run(rawQuery)));
  }

  /// Vide le champ et abandonne la requête en cours.
  void clear() {
    _debounce?.cancel();
    _cancelPending();
    state = const SearchState();
  }

  /// Relance la dernière recherche, après une erreur réseau par exemple.
  Future<void> retry() {
    _debounce?.cancel();
    _cancelPending();
    if (_normalizer.normalize(state.query).length < kMinQueryLength) {
      return Future<void>.value();
    }
    state = state.copyWith(status: SearchStatus.loading, error: () => null);
    return _run(state.query);
  }

  Future<void> _run(String rawQuery) async {
    final token = CancellationToken();
    _pending = token;

    try {
      // Les premiers résultats s'affichent dès qu'une source répond ; la barre
      // de progression reste jusqu'à la liste définitive.
      await for (final results in _repository.search(rawQuery, token: token)) {
        if (token.isCancelled) {
          return;
        }
        state = state.copyWith(results: results, error: () => null);
      }
      if (token.isCancelled) {
        return;
      }
      state = state.copyWith(status: SearchStatus.success, error: () => null);
    } on RequestCancelledException {
      // Une frappe plus récente a pris la main : cet écran n'a rien à dire.
    } on AppException catch (error) {
      if (token.isCancelled) {
        return;
      }
      state = state.copyWith(
        status: SearchStatus.failure,
        results: const <BookSearchResult>[],
        error: () => error,
      );
    } finally {
      if (identical(_pending, token)) {
        _pending = null;
      }
    }
  }

  void _cancelPending() {
    _pending?.cancel();
    _pending = null;
  }
}

final NotifierProvider<BookSearchController, SearchState> searchControllerProvider =
    NotifierProvider<BookSearchController, SearchState>(BookSearchController.new);
