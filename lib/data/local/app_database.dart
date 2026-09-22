import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/models/shelf.dart';
import 'converters/shelf_converter.dart';
import 'daos/backup_dao.dart';
import 'daos/books_dao.dart';
import 'daos/reading_entries_dao.dart';
import 'daos/tags_dao.dart';
import 'tables/books.dart';
import 'tables/reading_entries.dart';
import 'tables/tags.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: <Type>[Books, ReadingEntries, Tags, BookTags],
  daos: <Type>[BooksDao, ReadingEntriesDao, TagsDao, BackupDao],
)
class AppDatabase extends _$AppDatabase {
  /// Base réelle du téléphone, rangée dans le dossier applicatif privé.
  AppDatabase() : super(driftDatabase(name: 'biblivre'));

  /// Base injectée, utilisée par les tests avec `NativeDatabase.memory()`.
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes();
        },
        beforeOpen: (OpeningDetails details) async {
          // Sans ce pragma, SQLite ignore les clés étrangères et les
          // suppressions en cascade ne se déclenchent pas.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _createIndexes() async {
    // Retrouver l'entrée courante d'un livre : le chemin le plus emprunté.
    await customStatement(
      'CREATE INDEX idx_entries_book_current '
      'ON reading_entries (book_id, is_current)',
    );
    // Filtrage de la bibliothèque par étagère.
    await customStatement(
      'CREATE INDEX idx_entries_shelf ON reading_entries (shelf)',
    );
    // Statistiques mensuelles à venir : livres et pages terminés par mois.
    await customStatement(
      'CREATE INDEX idx_entries_finished ON reading_entries (finished_at)',
    );
  }
}
