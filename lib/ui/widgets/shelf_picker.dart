import 'package:flutter/material.dart';

import '../../domain/models/shelf.dart';
import '../shelf_labels.dart';

/// Demande dans quelle étagère ranger un livre.
///
/// Renvoie `null` si l'utilisateur referme la feuille sans choisir.
Future<Shelf?> showShelfPicker(
  BuildContext context, {
  required String bookTitle,
  Shelf? current,
}) {
  return showModalBottomSheet<Shelf>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              bookTitle,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          for (final shelf in Shelf.values)
            ListTile(
              leading: Icon(shelf.icon),
              title: Text(shelf.label),
              trailing: shelf == current
                  ? const Icon(Icons.check, semanticLabel: 'Étagère actuelle')
                  : null,
              onTap: () => Navigator.of(context).pop(shelf),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
