import 'package:flutter/material.dart';

import '../domain/models/library_query.dart';
import '../domain/models/shelf.dart';
import 'l10n/l10n.dart';

/// Comment chaque étagère se présente à l'écran.
extension ShelfPresentation on Shelf {
  String label(AppLocalizations l10n) => switch (this) {
        Shelf.toRead => l10n.shelfToRead,
        Shelf.reading => l10n.shelfReading,
        Shelf.read => l10n.shelfRead,
      };

  /// Formulation utilisée dans les confirmations : « Ajouté à « À lire » ».
  String addedMessage(AppLocalizations l10n) => l10n.shelfAdded(label(l10n));

  IconData get icon => switch (this) {
        Shelf.toRead => Icons.bookmark_border,
        Shelf.reading => Icons.auto_stories_outlined,
        Shelf.read => Icons.check_circle_outline,
      };
}

/// Libellé de chaque critère dans le menu de tri de la bibliothèque.
extension LibrarySortPresentation on LibrarySort {
  String label(AppLocalizations l10n) => switch (this) {
        LibrarySort.title => l10n.sortTitle,
        LibrarySort.author => l10n.sortAuthor,
        LibrarySort.addedAt => l10n.sortAddedAt,
        LibrarySort.rating => l10n.sortRating,
      };
}
