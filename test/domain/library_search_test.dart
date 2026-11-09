import 'package:biblivre/domain/models/book.dart';
import 'package:biblivre/domain/models/library_item.dart';
import 'package:biblivre/domain/models/reading_entry.dart';
import 'package:biblivre/domain/models/shelf.dart';
import 'package:biblivre/domain/services/library_search.dart';
import 'package:flutter_test/flutter_test.dart';

LibraryItem _item(int id, String title, {String? author, String? isbn}) {
  final now = DateTime(2026);
  return LibraryItem(
    book: Book(
      id: id,
      title: title,
      author: author,
      isbn: isbn,
      isManual: true,
      createdAt: now,
      updatedAt: now,
    ),
    currentEntry: ReadingEntry(
      id: id,
      bookId: id,
      shelf: Shelf.toRead,
      currentPage: 0,
      isCurrent: true,
      createdAt: now,
      updatedAt: now,
    ),
  );
}

void main() {
  const search = LibrarySearch();
  final items = <LibraryItem>[
    _item(1, 'Les Misérables', author: 'Victor Hugo', isbn: '9782253096344'),
    _item(2, 'Le Petit Prince', author: 'Antoine de Saint-Exupéry'),
    _item(3, 'Madame Bovary', author: 'Gustave Flaubert'),
  ];

  List<int> ids(String query) =>
      search.filter(items, query).map((item) => item.book.id).toList();

  test('une recherche vide garde tous les livres', () {
    expect(ids(''), <int>[1, 2, 3]);
    expect(ids('   '), <int>[1, 2, 3]);
  });

  test('ignore la casse et les accents', () {
    expect(ids('MISERABLES'), <int>[1]);
    expect(ids('exupery'), <int>[2]);
  });

  test('cherche dans le titre, l\'auteur et l\'ISBN', () {
    expect(ids('flaubert'), <int>[3]);
    expect(ids('9782253'), <int>[1]);
  });

  test('chaque mot doit apparaître, dans n\'importe quel ordre', () {
    expect(ids('hugo mis'), <int>[1]);
    expect(ids('hugo prince'), isEmpty);
  });

  test('garde l\'ordre de la bibliothèque', () {
    expect(ids('le'), <int>[1, 2]);
  });
}
