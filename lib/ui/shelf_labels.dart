import 'package:flutter/material.dart';

import '../domain/models/shelf.dart';

/// Comment chaque étagère se présente à l'écran.
extension ShelfPresentation on Shelf {
  String get label => switch (this) {
        Shelf.toRead => 'À lire',
        Shelf.reading => 'En cours',
        Shelf.read => 'Lu',
      };

  /// Formulation utilisée dans les confirmations : « Ajouté à lire ».
  String get addedMessage => switch (this) {
        Shelf.toRead => 'Ajouté à « À lire »',
        Shelf.reading => 'Ajouté à « En cours »',
        Shelf.read => 'Ajouté à « Lu »',
      };

  IconData get icon => switch (this) {
        Shelf.toRead => Icons.bookmark_border,
        Shelf.reading => Icons.auto_stories_outlined,
        Shelf.read => Icons.check_circle_outline,
      };
}
