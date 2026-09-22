import 'package:meta/meta.dart';

import '../services/reading_progress.dart';
import 'book.dart';
import 'reading_entry.dart';
import 'shelf.dart';
import 'tag.dart';

/// Une ligne de « Ma bibliothèque » : un livre, sa lecture en cours et ses
/// étagères personnalisées, assemblés en une seule lecture de la base.
@immutable
class LibraryItem {
  const LibraryItem({
    required this.book,
    required this.currentEntry,
    this.tags = const <Tag>[],
  });

  final Book book;

  /// L'entrée `is_current` du livre. Un livre présent en base en a toujours une.
  final ReadingEntry currentEntry;

  final List<Tag> tags;

  Shelf get shelf => currentEntry.shelf;
  int? get rating => currentEntry.rating;

  /// Pourcentage lu, ou `null` si le nombre de pages est inconnu.
  int? get progressPercent => ReadingProgress.percent(
        currentPage: currentEntry.currentPage,
        pageCount: book.pageCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryItem &&
          other.book == book &&
          other.currentEntry == currentEntry &&
          _sameTags(other.tags);

  bool _sameTags(List<Tag> others) {
    if (others.length != tags.length) {
      return false;
    }
    for (var i = 0; i < tags.length; i++) {
      if (tags[i] != others[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(book, currentEntry, Object.hashAll(tags));
}
