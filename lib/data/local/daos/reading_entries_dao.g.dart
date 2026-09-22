// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_entries_dao.dart';

// ignore_for_file: type=lint
mixin _$ReadingEntriesDaoMixin on DatabaseAccessor<AppDatabase> {
  $BooksTable get books => attachedDatabase.books;
  $ReadingEntriesTable get readingEntries => attachedDatabase.readingEntries;
  ReadingEntriesDaoManager get managers => ReadingEntriesDaoManager(this);
}

class ReadingEntriesDaoManager {
  final _$ReadingEntriesDaoMixin _db;
  ReadingEntriesDaoManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$ReadingEntriesTableTableManager get readingEntries =>
      $$ReadingEntriesTableTableManager(
        _db.attachedDatabase,
        _db.readingEntries,
      );
}
