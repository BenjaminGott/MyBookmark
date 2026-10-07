import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Ce que montre le widget d'écran d'accueil : le livre en cours, ou rien.
@immutable
class ReadingWidgetContent {
  const ReadingWidgetContent({
    required this.bookId,
    required this.kicker,
    required this.title,
    required this.author,
    required this.progress,
    required this.percent,
    this.cover,
  });

  final int bookId;
  final String kicker;
  final String title;
  final String author;

  /// « Page 248 sur 400 · 62 % », déjà traduit.
  final String progress;

  /// De 0 à 100 ; `null` si le nombre de pages est inconnu.
  final int? percent;

  /// La couverture, déjà réduite, en PNG.
  final Uint8List? cover;
}

/// Le widget Android de l'écran d'accueil.
abstract class ReadingWidget {
  /// Affiche ce livre, ou, avec `null`, l'invitation à en commencer un.
  Future<void> show(
    ReadingWidgetContent? content, {
    required String emptyTitle,
    required String emptyHint,
  });

  /// Le livre touché dans le widget pour ouvrir l'application, s'il y en a un.
  Future<int?> launchedBook();

  /// Les livres touchés pendant que l'application est ouverte.
  Stream<int> get tappedBooks;
}
