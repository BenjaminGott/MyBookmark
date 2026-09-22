import 'package:drift/drift.dart';

import '../../../domain/models/tag.dart';
import '../app_database.dart';
import '../mappers.dart';
import '../tables/books.dart';
import '../tables/tags.dart';

part 'tags_dao.g.dart';

@DriftAccessor(tables: <Type>[Books, Tags, BookTags])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.attachedDatabase);

  Stream<List<Tag>> watchAllTags() {
    final select = this.select(tags)
      ..orderBy(<OrderingTerm Function($TagsTable)>[
        ($TagsTable t) => OrderingTerm(expression: t.name.collate(Collate.noCase)),
      ]);
    return select
        .watch()
        .map((List<TagRow> rows) => rows.map((TagRow row) => row.toDomain()).toList());
  }

  /// Crée l'étagère si elle n'existe pas encore, et renvoie son identifiant.
  ///
  /// La comparaison est insensible à la casse : « Polars » et « polars » sont
  /// la même étagère.
  Future<int> ensureTag(String name, {int? color, DateTime? now}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Le nom d\'étagère est vide');
    }

    final existing = await (select(tags)
          ..where(($TagsTable t) => t.name.lower().equals(trimmed.toLowerCase())))
        .getSingleOrNull();
    if (existing != null) {
      return existing.id;
    }

    return into(tags).insert(
      TagsCompanion.insert(
        name: trimmed,
        color: Value<int?>(color),
        createdAt: now ?? DateTime.now(),
      ),
    );
  }

  Future<void> attachTag({required int bookId, required int tagId}) async {
    await into(bookTags).insert(
      BookTagsCompanion.insert(bookId: bookId, tagId: tagId),
      mode: InsertMode.insertOrIgnore,
    );
  }

  Future<void> detachTag({required int bookId, required int tagId}) async {
    await (delete(bookTags)
          ..where(($BookTagsTable t) =>
              t.bookId.equals(bookId) & t.tagId.equals(tagId)))
        .go();
  }

  Future<void> deleteTag(int tagId) async {
    await (delete(tags)..where(($TagsTable t) => t.id.equals(tagId))).go();
  }

  Stream<List<Tag>> watchTagsForBook(int bookId) {
    final select = this.select(tags).join([
      innerJoin(
        bookTags,
        bookTags.tagId.equalsExp(tags.id) & bookTags.bookId.equals(bookId),
      ),
    ])
      ..orderBy(<OrderingTerm>[
        OrderingTerm(expression: tags.name.collate(Collate.noCase)),
      ]);
    return select.watch().map(
          (List<TypedResult> rows) =>
              rows.map((TypedResult row) => row.readTable(tags).toDomain()).toList(),
        );
  }
}
