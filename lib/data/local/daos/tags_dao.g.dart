// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_dao.dart';

// ignore_for_file: type=lint
mixin _$TagsDaoMixin on DatabaseAccessor<AppDatabase> {
  $BooksTable get books => attachedDatabase.books;
  $TagsTable get tags => attachedDatabase.tags;
  $BookTagsTable get bookTags => attachedDatabase.bookTags;
  TagsDaoManager get managers => TagsDaoManager(this);
}

class TagsDaoManager {
  final _$TagsDaoMixin _db;
  TagsDaoManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db.attachedDatabase, _db.books);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$BookTagsTableTableManager get bookTags =>
      $$BookTagsTableTableManager(_db.attachedDatabase, _db.bookTags);
}
