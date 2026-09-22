import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_database.dart';
import '../../data/local/daos/books_dao.dart';
import '../../data/local/daos/reading_entries_dao.dart';
import '../../data/local/daos/tags_dao.dart';

/// La base locale, unique pour toute la durée de vie de l'application.
///
/// Les tests remplacent ce provider par une base en mémoire.
final Provider<AppDatabase> databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final Provider<BooksDao> booksDaoProvider =
    Provider<BooksDao>((ref) => ref.watch(databaseProvider).booksDao);

final Provider<ReadingEntriesDao> readingEntriesDaoProvider =
    Provider<ReadingEntriesDao>(
  (ref) => ref.watch(databaseProvider).readingEntriesDao,
);

final Provider<TagsDao> tagsDaoProvider =
    Provider<TagsDao>((ref) => ref.watch(databaseProvider).tagsDao);
