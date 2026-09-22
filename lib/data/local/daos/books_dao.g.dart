// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'books_dao.dart';

// ignore_for_file: type=lint
mixin _$BooksDaoMixin on DatabaseAccessor<AppDatabase> {
  $BooksTable get books => attachedDatabase.books;
  $ReadingEntriesTable get readingEntries => attachedDatabase.readingEntries;
  $TagsTable get tags => attachedDatabase.tags;
  $BookTagsTable get bookTags => attachedDatabase.bookTags;
  BooksDaoManager get managers => BooksDaoManager(this);
}

class BooksDaoManager {
  final _$BooksDaoMixin _db;
  BooksDaoManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$ReadingEntriesTableTableManager get readingEntries =>
      $$ReadingEntriesTableTableManager(
        _db.attachedDatabase,
        _db.readingEntries,
      );
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$BookTagsTableTableManager get bookTags =>
      $$BookTagsTableTableManager(_db.attachedDatabase, _db.bookTags);
}
