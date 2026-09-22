import 'package:meta/meta.dart';

/// Un livre de la bibliothèque, tel qu'il est stocké localement.
///
/// Toutes les métadonnées sont recopiées au moment de l'ajout : l'application
/// n'a plus jamais besoin d'Open Library pour afficher un livre déjà ajouté.
/// Seule la couverture reste une URL distante, chargée et mise en cache par
/// `cached_network_image`.
@immutable
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.isManual,
    required this.createdAt,
    required this.updatedAt,
    this.olKey,
    this.author,
    this.pageCount,
    this.coverId,
    this.coverUrl,
    this.firstPublishYear,
    this.description,
    this.isbn,
  });

  /// Identifiant local. Vaut 0 tant que le livre n'a pas été inséré.
  final int id;

  /// Clé Open Library, par exemple `/works/OL45804W`. Nulle si saisie manuelle.
  final String? olKey;

  final String title;
  final String? author;
  final int? pageCount;

  /// `cover_i` d'Open Library, qui permet de régénérer l'URL en taille S, M ou L.
  final int? coverId;

  /// URL figée au moment de l'ajout. Nulle si le livre n'a pas de couverture.
  final String? coverUrl;

  final int? firstPublishYear;
  final String? description;
  final String? isbn;
  final bool isManual;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasCover => coverUrl != null && coverUrl!.isNotEmpty;
  bool get hasKnownPageCount => pageCount != null && pageCount! > 0;

  Book copyWith({
    int? id,
    String? Function()? olKey,
    String? title,
    String? Function()? author,
    int? Function()? pageCount,
    int? Function()? coverId,
    String? Function()? coverUrl,
    int? Function()? firstPublishYear,
    String? Function()? description,
    String? Function()? isbn,
    bool? isManual,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      olKey: olKey == null ? this.olKey : olKey(),
      title: title ?? this.title,
      author: author == null ? this.author : author(),
      pageCount: pageCount == null ? this.pageCount : pageCount(),
      coverId: coverId == null ? this.coverId : coverId(),
      coverUrl: coverUrl == null ? this.coverUrl : coverUrl(),
      firstPublishYear:
          firstPublishYear == null ? this.firstPublishYear : firstPublishYear(),
      description: description == null ? this.description : description(),
      isbn: isbn == null ? this.isbn : isbn(),
      isManual: isManual ?? this.isManual,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Book &&
          other.id == id &&
          other.olKey == olKey &&
          other.title == title &&
          other.author == author &&
          other.pageCount == pageCount &&
          other.coverId == coverId &&
          other.coverUrl == coverUrl &&
          other.firstPublishYear == firstPublishYear &&
          other.description == description &&
          other.isbn == isbn &&
          other.isManual == isManual &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        olKey,
        title,
        author,
        pageCount,
        coverId,
        coverUrl,
        firstPublishYear,
        description,
        isbn,
        isManual,
        createdAt,
        updatedAt,
      );

  @override
  String toString() => 'Book(id: $id, title: $title, author: $author)';
}
