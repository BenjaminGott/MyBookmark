import 'package:drift/drift.dart';

import 'books.dart';

/// Une étagère personnalisée.
@DataClassName('TagRow')
class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 60).unique()();

  /// Couleur ARGB facultative.
  IntColumn get color => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();
}

/// Association many-to-many entre les livres et les étagères personnalisées.
@DataClassName('BookTagRow')
class BookTags extends Table {
  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();

  IntColumn get tagId =>
      integer().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{bookId, tagId};
}
