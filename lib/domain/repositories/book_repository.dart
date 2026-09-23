import '../models/book.dart';
import '../models/book_search_result.dart';
import '../models/library_item.dart';
import '../models/library_query.dart';
import '../models/reading_entry.dart';
import '../models/shelf.dart';

/// Tout ce que l'application sait faire de sa bibliothèque locale.
///
/// Une fois un livre ajouté, plus rien ici n'a besoin du réseau : les écrans
/// lisent et écrivent uniquement la base du téléphone.
abstract class BookRepository {
  /// La bibliothèque, filtrée et triée. Le flux suit les écritures.
  Stream<List<LibraryItem>> watchLibrary(LibraryQuery query);

  /// Un livre et sa lecture en cours, ou `null` s'il a été supprimé.
  Stream<LibraryItem?> watchBook(int bookId);

  /// L'historique des lectures d'un livre, la courante en tête.
  Stream<List<ReadingEntry>> watchEntries(int bookId);

  /// Les clés Open Library déjà en bibliothèque, pour griser les résultats
  /// de recherche déjà ajoutés.
  Stream<Set<String>> watchKnownOlKeys();

  Future<Book?> findById(int bookId);

  /// Ajoute un livre trouvé dans Open Library, avec son résumé si l'API le
  /// donne. Toutes les métadonnées sont recopiées en base au passage.
  Future<int> addFromSearch(BookSearchResult result, Shelf shelf);

  /// Ajoute un livre absent de l'API, saisi à la main.
  Future<int> addManual({
    required String title,
    required Shelf shelf,
    String? author,
    int? pageCount,
    int? firstPublishYear,
    String? description,
    String? coverUrl,
  });

  Future<void> moveToShelf({required int entryId, required Shelf shelf});

  Future<void> updateProgress({required int entryId, required int page});

  Future<void> rate({required int entryId, required int? rating});

  Future<void> writeReview({required int entryId, required String? review});

  Future<void> setDates({
    required int entryId,
    required DateTime? startedAt,
    required DateTime? finishedAt,
  });

  /// Corrige les métadonnées d'un livre : titre, auteur, nombre de pages…
  ///
  /// Le formulaire renvoie tous les champs, y compris ceux laissés vides : une
  /// valeur nulle efface donc la donnée au lieu de la conserver.
  Future<void> editBook({
    required int bookId,
    required String title,
    required String? author,
    required int? pageCount,
    required int? firstPublishYear,
    required String? description,
    required int? coverId,
    required String? coverUrl,
  });

  /// Ouvre une relecture : l'entrée courante est archivée, une neuve démarre.
  Future<int> startReread(int bookId);

  Future<void> deleteBook(int bookId);
}
