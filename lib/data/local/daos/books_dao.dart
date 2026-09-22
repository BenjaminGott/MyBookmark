import 'package:drift/drift.dart';

import '../../../domain/models/book.dart';
import '../../../domain/models/library_item.dart';
import '../../../domain/models/library_query.dart';
import '../../../domain/models/shelf.dart';
import '../../../domain/models/tag.dart';
import '../app_database.dart';
import '../mappers.dart';
import '../tables/books.dart';
import '../tables/reading_entries.dart';
import '../tables/tags.dart';

part 'books_dao.g.dart';

@DriftAccessor(tables: <Type>[Books, ReadingEntries, Tags, BookTags])
class BooksDao extends DatabaseAccessor<AppDatabase> with _$BooksDaoMixin {
  BooksDao(super.attachedDatabase);

  /// Les livres de la bibliothèque, filtrés et triés, avec leur lecture en cours.
  ///
  /// Le flux se rafraîchit tout seul à chaque écriture sur `books` ou
  /// `reading_entries`.
  Stream<List<LibraryItem>> watchLibrary([
    LibraryQuery query = const LibraryQuery(),
  ]) {
    final select = this.select(books).join([
      innerJoin(
        readingEntries,
        readingEntries.bookId.equalsExp(books.id) &
            readingEntries.isCurrent.equals(true),
      ),
    ]);

    final shelf = query.shelf;
    if (shelf != null) {
      select.where(readingEntries.shelf.equalsValue(shelf));
    }

    select.orderBy(_orderingFor(query));

    return select.watch().asyncMap((List<TypedResult> rows) async {
      final items = <LibraryItem>[];
      for (final row in rows) {
        final book = row.readTable(books).toDomain();
        items.add(
          LibraryItem(
            book: book,
            currentEntry: row.readTable(readingEntries).toDomain(),
            tags: await _tagsForBook(book.id),
          ),
        );
      }
      return items;
    });
  }

  List<OrderingTerm> _orderingFor(LibraryQuery query) {
    final mode = query.descending ? OrderingMode.desc : OrderingMode.asc;
    // Les valeurs absentes (pas d'auteur, pas de note) finissent toujours en
    // bas de liste, quel que soit le sens du tri.
    const nulls = NullsOrder.last;

    final terms = <OrderingTerm>[
      switch (query.sort) {
        LibrarySort.title => OrderingTerm(
            expression: books.title.collate(Collate.noCase),
            mode: mode,
          ),
        LibrarySort.author => OrderingTerm(
            expression: books.author.collate(Collate.noCase),
            mode: mode,
            nulls: nulls,
          ),
        LibrarySort.addedAt =>
          OrderingTerm(expression: books.createdAt, mode: mode),
        LibrarySort.rating => OrderingTerm(
            expression: readingEntries.rating,
            mode: mode,
            nulls: nulls,
          ),
      },
    ];

    // Départage les ex æquo pour que l'ordre reste stable d'un affichage à
    // l'autre (deux livres sans note, deux livres ajoutés la même seconde…).
    if (query.sort != LibrarySort.title) {
      terms.add(
        OrderingTerm(expression: books.title.collate(Collate.noCase)),
      );
    }
    terms.add(OrderingTerm(expression: books.id));
    return terms;
  }

  Future<List<Tag>> _tagsForBook(int bookId) async {
    final rows = await (select(tags).join([
      innerJoin(
        bookTags,
        bookTags.tagId.equalsExp(tags.id) & bookTags.bookId.equals(bookId),
      ),
    ])..orderBy(<OrderingTerm>[
            OrderingTerm(expression: tags.name.collate(Collate.noCase)),
          ]))
        .get();
    return rows.map((TypedResult row) => row.readTable(tags).toDomain()).toList();
  }

  /// Le livre et sa lecture en cours, ou `null` s'il a été supprimé.
  Stream<LibraryItem?> watchLibraryItem(int bookId) {
    final select = this.select(books).join([
      innerJoin(
        readingEntries,
        readingEntries.bookId.equalsExp(books.id) &
            readingEntries.isCurrent.equals(true),
      ),
    ])
      ..where(books.id.equals(bookId));

    return select.watchSingleOrNull().asyncMap((TypedResult? row) async {
      if (row == null) {
        return null;
      }
      final book = row.readTable(books).toDomain();
      return LibraryItem(
        book: book,
        currentEntry: row.readTable(readingEntries).toDomain(),
        tags: await _tagsForBook(book.id),
      );
    });
  }

  Future<Book?> findById(int id) async {
    final row =
        await (select(books)..where(($BooksTable t) => t.id.equals(id)))
            .getSingleOrNull();
    return row?.toDomain();
  }

  /// Retrouve un livre déjà ajouté à partir de sa clé Open Library.
  ///
  /// Sert à ne pas proposer deux fois le même ouvrage dans la recherche.
  Future<Book?> findByOlKey(String olKey) async {
    final row =
        await (select(books)..where(($BooksTable t) => t.olKey.equals(olKey)))
            .getSingleOrNull();
    return row?.toDomain();
  }

  /// Les clés Open Library déjà présentes en base, pour marquer les résultats
  /// de recherche d'un coup d'œil.
  Stream<Set<String>> watchKnownOlKeys() {
    final query = selectOnly(books)
      ..addColumns(<Expression<Object>>[books.olKey])
      ..where(books.olKey.isNotNull());
    return query.watch().map(
          (List<TypedResult> rows) => rows
              .map((TypedResult row) => row.read(books.olKey))
              .whereType<String>()
              .toSet(),
        );
  }

  /// Ajoute un livre et sa première lecture, en une seule transaction.
  ///
  /// Renvoie l'identifiant local du livre créé.
  Future<int> addBook({
    required String title,
    required Shelf shelf,
    String? olKey,
    String? author,
    int? pageCount,
    int? coverId,
    String? coverUrl,
    int? firstPublishYear,
    String? description,
    String? isbn,
    bool isManual = false,
    DateTime? now,
  }) {
    final timestamp = now ?? DateTime.now();

    return transaction(() async {
      final bookId = await into(books).insert(
        BooksCompanion.insert(
          title: title,
          olKey: Value<String?>(olKey),
          author: Value<String?>(author),
          pageCount: Value<int?>(pageCount),
          coverId: Value<int?>(coverId),
          coverUrl: Value<String?>(coverUrl),
          firstPublishYear: Value<int?>(firstPublishYear),
          description: Value<String?>(description),
          isbn: Value<String?>(isbn),
          isManual: Value<bool>(isManual),
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      await into(readingEntries).insert(
        ReadingEntriesCompanion.insert(
          bookId: bookId,
          shelf: shelf,
          // Ajouter un livre directement en « en cours » ou en « lu » date la
          // lecture d'aujourd'hui ; la fiche livre permet de corriger.
          startedAt: Value<DateTime?>(shelf == Shelf.toRead ? null : timestamp),
          finishedAt: Value<DateTime?>(shelf == Shelf.read ? timestamp : null),
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
      );

      return bookId;
    });
  }

  /// Met à jour les métadonnées d'un livre, par exemple un nombre de pages faux.
  Future<void> updateBook(
    int bookId, {
    required BooksCompanion changes,
    DateTime? now,
  }) async {
    await (update(books)..where(($BooksTable t) => t.id.equals(bookId))).write(
      changes.copyWith(updatedAt: Value<DateTime>(now ?? DateTime.now())),
    );
  }

  /// Supprime un livre. Ses lectures et ses étagères partent en cascade.
  Future<void> deleteBook(int bookId) async {
    await (delete(books)..where(($BooksTable t) => t.id.equals(bookId))).go();
  }
}
