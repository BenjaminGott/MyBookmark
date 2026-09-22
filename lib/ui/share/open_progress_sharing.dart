import 'package:flutter/material.dart';

import '../../domain/models/library_item.dart';
import 'share_progress_screen.dart';

/// Ouvre l'aperçu de la carte de progression d'un livre.
///
/// Un seul point d'entrée pour les deux endroits qui le proposent : le bouton de
/// la carte de progression, et le menu de la fiche livre.
Future<void> openProgressSharing(BuildContext context, LibraryItem item) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => ShareProgressScreen(item: item),
    ),
  );
}
