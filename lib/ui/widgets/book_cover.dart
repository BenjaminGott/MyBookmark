import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// La couverture d'un livre, ou un substitut quand il n'y en a pas.
///
/// L'image n'est jamais stockée en base : `cached_network_image` la garde dans
/// son propre cache disque, que le système peut vider quand il veut.
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

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: address == null || address.isEmpty
            ? _Placeholder(height: height)
            : CachedNetworkImage(
                imageUrl: address,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (context, _) => _Placeholder(height: height),
                // Couverture annoncée mais absente du serveur : on retombe sur
                // le substitut plutôt que sur une icône d'image cassée.
                errorWidget: (context, _, _) => _Placeholder(height: height),
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
