import 'package:meta/meta.dart';

import 'shelf.dart';

/// Critère de tri de « Ma bibliothèque ».
///
/// Le libellé affiché dépend de la langue : il est donné par l'interface.
enum LibrarySort { title, author, addedAt, rating }

/// Le filtre et le tri actuellement appliqués à la bibliothèque.
@immutable
class LibraryQuery {
  const LibraryQuery({
    this.shelf,
    this.sort = LibrarySort.addedAt,
    this.descending = true,
  });

  /// `null` signifie « toutes les étagères ».
  final Shelf? shelf;

  final LibrarySort sort;
  final bool descending;

  LibraryQuery copyWith({
    Shelf? Function()? shelf,
    LibrarySort? sort,
    bool? descending,
  }) {
    return LibraryQuery(
      shelf: shelf == null ? this.shelf : shelf(),
      sort: sort ?? this.sort,
      descending: descending ?? this.descending,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryQuery &&
          other.shelf == shelf &&
          other.sort == sort &&
          other.descending == descending;

  @override
  int get hashCode => Object.hash(shelf, sort, descending);
}
