import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/failure.dart';
import '../../domain/models/book_search_result.dart';
import '../../domain/models/library_query.dart';
import '../../domain/models/shelf.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/services/review_policy.dart';
import 'book_providers.dart';
import 'settings_providers.dart';

/// Résultat d'une action d'écriture, tel que l'écran a besoin de le connaître.
sealed class ActionResult {
  const ActionResult();
}

class ActionSuccess extends ActionResult {
  const ActionSuccess([this.bookId]);

  /// Renseigné par les actions qui créent un livre.
  final int? bookId;
}

class ActionFailure extends ActionResult {
  const ActionFailure(this.error);

  final AppException error;
}

/// Toutes les écritures déclenchées par un geste de l'utilisateur.
///
/// L'état dit si une écriture est en cours, ce qui permet de désactiver un
/// bouton le temps de l'enregistrement. Le résultat est renvoyé à l'appelant
/// pour qu'il affiche la confirmation ou l'erreur au bon endroit.
class BookActionsController extends Notifier<bool> {
  @override
  bool build() => false;

  BookRepository get _repository => ref.read(bookRepositoryProvider);

  Future<ActionResult> addFromSearch(BookSearchResult result, Shelf shelf) {
    return _run(() => _repository.addFromSearch(result, shelf));
  }

  Future<ActionResult> addManual({
    required String title,
    required Shelf shelf,
    String? author,
    int? pageCount,
    int? firstPublishYear,
    String? description,
    String? coverUrl,
  }) {
    return _run(
      () => _repository.addManual(
        title: title,
        shelf: shelf,
        author: author,
        pageCount: pageCount,
        firstPublishYear: firstPublishYear,
        description: description,
        coverUrl: coverUrl,
      ),
    );
  }

  Future<ActionResult> moveToShelf({
    required int entryId,
    required Shelf shelf,
  }) {
    return _run(() async {
      await _repository.moveToShelf(entryId: entryId, shelf: shelf);
      if (shelf == Shelf.read) {
        // Un livre terminé : le bon moment pour demander un avis.
        unawaited(_maybeAskReview());
      }
      return null;
    });
  }

  Future<void> _maybeAskReview() async {
    try {
      final preferences = ref.read(preferencesServiceProvider);
      final finished = await _repository
          .watchLibrary(const LibraryQuery(shelf: Shelf.read))
          .first;
      final now = DateTime.now();
      if (!ReviewPolicy.shouldAsk(
        finishedBooks: finished.length,
        lastAsked: preferences.reviewAskedAt,
        now: now,
      )) {
        return;
      }
      await preferences.setReviewAskedAt(now);
      await ref.read(reviewPromptProvider).request();
    } on Object {
      // Une demande d'avis manquée n'a aucune importance.
    }
  }

  Future<ActionResult> updateProgress({
    required int entryId,
    required int page,
  }) {
    return _run(() async {
      await _repository.updateProgress(entryId: entryId, page: page);
      return null;
    });
  }

  Future<ActionResult> rate({required int entryId, required int? rating}) {
    return _run(() async {
      await _repository.rate(entryId: entryId, rating: rating);
      return null;
    });
  }

  Future<ActionResult> writeReview({
    required int entryId,
    required String? review,
  }) {
    return _run(() async {
      await _repository.writeReview(entryId: entryId, review: review);
      return null;
    });
  }

  Future<ActionResult> setDates({
    required int entryId,
    required DateTime? startedAt,
    required DateTime? finishedAt,
  }) {
    return _run(() async {
      await _repository.setDates(
        entryId: entryId,
        startedAt: startedAt,
        finishedAt: finishedAt,
      );
      return null;
    });
  }

  Future<ActionResult> editBook({
    required int bookId,
    required String title,
    required String? author,
    required int? pageCount,
    required int? firstPublishYear,
    required String? description,
    required int? coverId,
    required String? coverUrl,
  }) {
    return _run(() async {
      await _repository.editBook(
        bookId: bookId,
        title: title,
        author: author,
        pageCount: pageCount,
        firstPublishYear: firstPublishYear,
        description: description,
        coverId: coverId,
        coverUrl: coverUrl,
      );
      return null;
    });
  }

  Future<ActionResult> startReread(int bookId) {
    return _run(() => _repository.startReread(bookId));
  }

  Future<ActionResult> deleteBook(int bookId) {
    return _run(() async {
      final book = await _repository.findById(bookId);
      await _repository.deleteBook(bookId);
      // Une couverture choisie dans la galerie part avec son livre.
      await ref.read(coverStoreProvider).discard(book?.coverUrl);
      return null;
    });
  }

  Future<ActionResult> _run(Future<int?> Function() write) async {
    state = true;
    try {
      return ActionSuccess(await write());
    } on AppException catch (error) {
      return ActionFailure(error);
    } finally {
      state = false;
    }
  }
}

/// `true` pendant une écriture : les boutons concernés se désactivent.
final NotifierProvider<BookActionsController, bool> bookActionsProvider =
    NotifierProvider<BookActionsController, bool>(BookActionsController.new);
