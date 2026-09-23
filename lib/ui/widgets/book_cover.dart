import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// L'image d'une couverture, qu'elle soit distante ou choisie dans la galerie.
///
/// Une couverture de la galerie est enregistrée comme URI `file://` : c'est
/// la même colonne `coverUrl`, lue par un autre fournisseur d'image.
ImageProvider coverImageProvider(String url) {
  final uri = Uri.tryParse(url);
  if (uri != null && uri.isScheme('file')) {
    return FileImage(File(uri.toFilePath()));
  }
  return CachedNetworkImageProvider(url);
}

/// La couverture d'un livre, ou un substitut quand il n'y en a pas.
///
/// L'image distante n'est jamais stockée en base : `cached_network_image` la
/// garde dans son propre cache disque, que le système peut vider quand il veut.
class BookCover extends StatelessWidget {
  const BookCover({
    required this.url,
    super.key,
    this.width = 48,
    this.height = 72,
    this.borderRadius = 6,
  });

  final String? url;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final address = url;

    // Décodée à la taille où elle s'affiche : une vignette de liste n'a pas
    // besoin des 600 × 900 pixels de l'original, et défile sans à-coups.
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth = (width * pixelRatio).round();

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: address == null || address.isEmpty
            ? _Placeholder(height: height)
            : Image(
                image: ResizeImage(
                  coverImageProvider(address),
                  width: cacheWidth,
                ),
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    return child;
                  }
                  return _Placeholder(height: height);
                },
                // Couverture annoncée mais absente du serveur, ou fichier
                // effacé : on retombe sur le substitut plutôt que sur une
                // icône d'image cassée.
                errorBuilder: (context, _, _) => _Placeholder(height: height),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.menu_book_outlined,
          size: height / 3,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
