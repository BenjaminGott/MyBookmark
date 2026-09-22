import 'package:drift/drift.dart';

/// Les métadonnées d'un livre, recopiées une fois pour toutes à l'ajout.
@DataClassName('BookRow')
class Books extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Clé Open Library (`/works/OL45804W`), nulle pour un livre saisi à la main.
  ///
  /// L'unicité empêche d'ajouter deux fois le même ouvrage ; SQLite autorisant
  /// plusieurs NULL dans un index unique, les livres manuels ne se gênent pas.
  TextColumn get olKey => text().nullable().unique()();

  TextColumn get title => text().withLength(min: 1, max: 500)();

  /// Open Library peut ne renvoyer aucun auteur.
  TextColumn get author => text().nullable()();

  /// `number_of_pages_median`, souvent absent et parfois faux : l'utilisateur
  /// peut le corriger à la main.
  IntColumn get pageCount => integer().nullable()();

  /// `cover_i`, conservé pour régénérer l'URL dans une autre taille.
  IntColumn get coverId => integer().nullable()();

  /// URL figée à l'ajout. L'image elle-même n'est jamais stockée en base.
  TextColumn get coverUrl => text().nullable()();

  IntColumn get firstPublishYear => integer().nullable()();

  /// Résumé recopié depuis l'œuvre Open Library.
  TextColumn get description => text().nullable()();

  /// Prévu pour le scan de code-barres, pas encore alimenté.
  TextColumn get isbn => text().nullable()();

  BoolColumn get isManual => boolean().withDefault(const Constant(false))();

  /// Date d'ajout, qui sert de critère de tri dans « Ma bibliothèque ».
  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => <String>[
        'CHECK (page_count IS NULL OR page_count > 0)',
        'CHECK (length(trim(title)) > 0)',
      ];
}
