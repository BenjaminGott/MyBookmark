import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/files/file_picker_cover_store.dart';
import '../../data/repositories/book_repository_drift.dart';
import '../../domain/models/library_item.dart';
import '../../domain/models/reading_entry.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/repositories/cover_store.dart';
import 'database_providers.dart';
import 'search_providers.dart';

final Provider<BookRepository> bookRepositoryProvider =
    Provider<BookRepository>((ref) {
  return DriftBookRepository(
    database: ref.watch(databaseProvider),
    searchRepository: ref.watch(searchRepositoryProvider),
  );
});

/// Les clés Open Library déjà en bibliothèque : la recherche s'en sert pour
/// signaler un livre déjà ajouté au lieu de le proposer une deuxième fois.
final StreamProvider<Set<String>> knownOlKeysProvider =
    StreamProvider<Set<String>>((ref) {
  return ref.watch(bookRepositoryProvider).watchKnownOlKeys();
});

/// Un livre et sa lecture en cours.
final bookProvider = StreamProvider.family<LibraryItem?, int>(
  (ref, bookId) => ref.watch(bookRepositoryProvider).watchBook(bookId),
);

/// L'historique des lectures d'un livre.
final bookEntriesProvider = StreamProvider.family<List<ReadingEntry>, int>(
  (ref, bookId) => ref.watch(bookRepositoryProvider).watchEntries(bookId),
);

/// Les couvertures choisies dans la galerie. Remplacé dans les tests, qui
/// n'ont ni sélecteur de fichiers ni système de fichiers réel.
final Provider<CoverStore> coverStoreProvider =
    Provider<CoverStore>((ref) => const FilePickerCoverStore());
