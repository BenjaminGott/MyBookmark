import 'package:drift/drift.dart';

import '../converters/shelf_converter.dart';
import 'books.dart';

/// Une lecture d'un livre. Plusieurs entrées par livre permettent les
/// relectures ; une seule porte `is_current` et décide de l'étagère affichée.
@DataClassName('ReadingEntryRow')
class ReadingEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get bookId =>
      integer().references(Books, #id, onDelete: KeyAction.cascade)();

  TextColumn get shelf => text().map(const ShelfConverter())();

  /// Note en étoiles entières, de 1 à 5.
  IntColumn get rating => integer().nullable()();

  /// Commentaire libre, indépendant de la note.
  TextColumn get review => text().nullable()();

  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get finishedAt => dateTime().nullable()();

  IntColumn get currentPage => integer().withDefault(const Constant(0))();

  BoolColumn get isCurrent => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => <String>[
        'CHECK (rating IS NULL OR (rating BETWEEN 1 AND 5))',
        'CHECK (current_page >= 0)',
        'CHECK (finished_at IS NULL OR started_at IS NULL '
            'OR finished_at >= started_at)',
      ];
}
