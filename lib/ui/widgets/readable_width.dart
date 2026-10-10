import 'package:flutter/material.dart';

/// Garde le contenu d'un écran à une largeur lisible sur tablette : centré,
/// sans s'étirer d'un bord à l'autre. Sur téléphone, il ne change rien.
class ReadableWidth extends StatelessWidget {
  const ReadableWidth({required this.child, super.key, this.maxWidth = 760});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Largeur à partir de laquelle l'écran est traité comme une tablette.
const double kTabletWidth = 840;
