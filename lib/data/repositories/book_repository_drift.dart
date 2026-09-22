import 'package:drift/drift.dart';
import 'package:sqlite3/common.dart' show SqliteException;

import '../../core/failure.dart';
import '../../domain/models/book.dart';
import '../../domain/models/book_search_result.dart';
import '../../domain/models/library_item.dart';
import '../../domain/models/library_query.dart';
import '../../domain/models/reading_entry.dart';
import '../../domain/models/shelf.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/repositories/search_repository.dart';
import '../local/app_database.dart';

/// Implémentation locale : tout passe par drift.
///
/// Le seul appel réseau de cette classe est le résumé récupéré au moment de
/// l'ajout, et il est facultatif : si Open Library ne répond pas, le livre est
/// ajouté sans résumé plutôt que de faire échouer le geste de l'utilisateur.
class DriftBookRepository implements BookRepository {
  DriftBookRepository({required this.database, required this.searchRepository});

  final AppDatabase database;
  final SearchRepository searchRepository;

  @override
  Stream<List<LibraryItem>> watchLibrary(LibraryQuery query) =>
      database.booksDao.watchLibrary(query);

  @override
  Stream<LibraryItem?> watchBook(int bookId) =>
      database.booksDao.watchLibraryItem(bookId);

  @override
  Stream<List<ReadingEntry>> watchEntries(int bookId) =>
      database.readingEntriesDao.watchEntriesForBook(bookId);

  @override
  Stream<Set<String>> watchKnownOlKeys() =>
      database.booksDao.watchKnownOlKeys();

  @override
  Future<Book?> findById(int bookId) => database.booksDao.findById(bookId);

  @override
  Future<int> addFromSearch(BookSearchResult result, Shelf shelf) async {
    final description = await _tryLoadDescription(result.olKey);
    return _guard(() => database.booksDao.addBook(
      olKey: result.olKey,
      title: result.title,
      author: result.author,
      pageCount: result.pageCount,
      coverId: result.coverId,
      coverUrl: result.coverUrl(CoverSize.large),
      firstPublishYear: result.firstPublishYear,
      description: description,
      shelf: shelf,
    ));
  }

  /// Le résumé est un bonus : une panne réseau ne doit pas bloquer l'ajout.
  Future<String?> _tryLoadDescription(String olKey) async {
    try {
      return await searchRepository.loadDescription(olKey);
    } on AppException {
      return null;
    }
  }

  @override
  Future<int> addManual({
    required String title,
    required Shelf shelf,
    String? author,
    int? pageCount,
    int? firstPublishYear,
    String? description,
    String? coverUrl,
  }) {
    return _guard(() => database.booksDao.addBook(
      title: title.trim(),
      author: _nullIfBlank(author),
      pageCount: pageCount,
      coverUrl: _nullIfBlank(coverUrl),
      firstPublishYear: firstPublishYear,
      description: _nullIfBlank(description),
      shelf: shelf,
      isManual: true,
    ));
  }

  @override
  Future<void> moveToShelf({required int entryId, required Shelf shelf}) =>
      database.readingEntriesDao.moveToShelf(entryId: entryId, shelf: shelf);

  @override
  Future<void> updateProgress({required int entryId, required int page}) =>
      database.readingEntriesDao
          .updateCurrentPage(entryId: entryId, page: page);

  @override
  Future<void> rate({required int entryId, required int? rating}) => _guard(
        () => database.readingEntriesDao
            .updateEntry(entryId, rating: Value<int?>(rating)),
      );

  @override
  Future<void> writeReview({required int entryId, required String? review}) =>
      database.readingEntriesDao
          .updateEntry(entryId, review: Value<String?>(_nullIfBlank(review)));

  @override
  Future<void> setDates({
    required int entryId,
    required DateTime? startedAt,
    required DateTime? finishedAt,
  }) =>
      _guard(
        () => database.readingEntriesDao.updateEntry(
          entryId,
          startedAt: Value<DateTime?>(startedAt),
          finishedAt: Value<DateTime?>(finishedAt),
        ),
      );

  @override
  Future<void> editBook({
    required int bookId,
    required String title,
    required String? author,
    required int? pageCount,
    required int? firstPublishYear,
    required String? description,
  }) {
    return _guard(() => database.booksDao.updateBook(
      bookId,
      changes: BooksCompanion(
        title: Value<String>(title.trim()),
        author: Value<String?>(_nullIfBlank(author)),
        pageCount: Value<int?>(pageCount),
        firstPublishYear: Value<int?>(firstPublishYear),
        description: Value<String?>(_nullIfBlank(description)),
      ),
    ));
  }

  @override
  Future<int> startReread(int bookId) =>
      database.readingEntriesDao.startReread(bookId: bookId);

  @override
  Future<void> deleteBook(int bookId) => database.booksDao.deleteBook(bookId);

  /// Traduit les erreurs SQLite en échecs que l'interface sait raconter.
  ///
  /// Sans cela, un doublon ou une contrainte CHECK remonterait jusqu'à l'écran
  /// sous forme de message technique en anglais.
  static Future<T> _guard<T>(Future<T> Function() write) async {
    try {
      return await write();
    } on SqliteException catch (error) {
      if (error.message.contains('UNIQUE constraint failed')) {
        throw const DuplicateBookException();
      }
      throw const StorageException();
    }
  }

  /// Un champ de formulaire vide vaut « pas de valeur », pas « chaîne vide ».
  static String? _nullIfBlank(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
