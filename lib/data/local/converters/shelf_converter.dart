import 'package:drift/drift.dart';

import '../../../domain/models/shelf.dart';

/// Stocke une [Shelf] sous sa forme textuelle stable (`to_read`, `reading`,
/// `read`) plutôt que sous son index, pour que la base survive à un renommage.
class ShelfConverter extends TypeConverter<Shelf, String> {
  const ShelfConverter();

  @override
  Shelf fromSql(String fromDb) => Shelf.parse(fromDb);

  @override
  String toSql(Shelf value) => value.wireName;
}
