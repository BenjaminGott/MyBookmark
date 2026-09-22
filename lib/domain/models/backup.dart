import 'package:meta/meta.dart';

import 'shelf.dart';

/// Version du format d'export. À incrémenter dès que la structure change.
const int kBackupFormatVersion = 1;

/// Une lecture, telle qu'elle voyage dans un fichier d'export.
///
/// Les identifiants locaux n'y figurent pas : ils n'ont aucun sens d'un
/// téléphone à l'autre, et l'import en attribue de nouveaux.
@immutable
class BackupReading {
  const BackupReading({
    required this.shelf,
    required this.currentPage,
    required this.isCurrent,
    this.rating,
    this.review,
    this.startedAt,
    this.finishedAt,
    this.createdAt,
  });

  final Shelf shelf;
  final int? rating;
  final String? review;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final int currentPage;
  final bool isCurrent;
  final DateTime? createdAt;
}

/// Un livre et tout ce qui s'y rattache.
@immutable
class BackupBook {
  const BackupBook({
    required this.title,
    required this.isManual,
    required this.readings,
    this.olKey,
    this.author,
    this.pageCount,
    this.coverId,
    this.coverUrl,
    this.firstPublishYear,
    this.description,
    this.isbn,
    this.createdAt,
    this.tags = const <String>[],
  });

  final String? olKey;
  final String title;
  final String? author;
  final int? pageCount;
  final int? coverId;
  final String? coverUrl;
  final int? firstPublishYear;
  final String? description;
  final String? isbn;
  final bool isManual;
  final DateTime? createdAt;
  final List<BackupReading> readings;
  final List<String> tags;
}

/// Le contenu complet d'un fichier d'export.
@immutable
class BackupArchive {
  const BackupArchive({
    required this.exportedAt,
    required this.books,
    this.version = kBackupFormatVersion,
    this.tags = const <String>[],
  });

  final int version;
  final DateTime exportedAt;
  final List<BackupBook> books;

  /// Les étagères personnalisées, y compris celles qui ne sont attachées à
  /// aucun livre.
  final List<String> tags;

  int get readingCount =>
      books.fold(0, (total, book) => total + book.readings.length);
}

/// Ce que l'application sait dire d'un fichier avant d'y toucher.
///
/// Sert à demander confirmation en connaissance de cause : combien de livres
/// le fichier contient, et combien sont déjà en bibliothèque.
@immutable
class BackupSummary {
  const BackupSummary({
    required this.version,
    required this.exportedAt,
    required this.bookCount,
    required this.readingCount,
    required this.alreadyPresentCount,
    required this.libraryCount,
  });

  final int version;
  final DateTime exportedAt;
  final int bookCount;
  final int readingCount;

  /// Livres du fichier déjà présents en bibliothèque.
  final int alreadyPresentCount;

  /// Livres actuellement en bibliothèque.
  final int libraryCount;

  int get newBookCount => bookCount - alreadyPresentCount;
}

/// Comment traiter un fichier quand la bibliothèque n'est pas vide.
enum ImportMode {
  /// Ajoute les livres absents et laisse les autres intacts.
  merge,

  /// Efface toute la bibliothèque et la remplace par le fichier.
  replace,
}

/// Ce qui s'est réellement passé pendant un import.
@immutable
class ImportReport {
  const ImportReport({
    required this.mode,
    required this.booksImported,
    required this.booksSkipped,
    required this.readingsImported,
    required this.tagsImported,
  });

  final ImportMode mode;
  final int booksImported;

  /// Livres ignorés parce qu'ils étaient déjà en bibliothèque.
  final int booksSkipped;

  final int readingsImported;
  final int tagsImported;
}
