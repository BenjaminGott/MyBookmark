import 'package:flutter/material.dart';

/// Un code-barres dans un cadre de visée : « scanner un livre ».
///
/// Material n'a pas cette icône (ses voisines évoquent un QR code ou une
/// douchette de caisse) : elle est dessinée ici, à la couleur et à la
/// taille du thème d'icônes, comme une icône ordinaire.
class ScanBarcodeIcon extends StatelessWidget {
  const ScanBarcodeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final size = theme.size ?? 24;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ScanBarcodePainter(
          theme.color ?? Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ScanBarcodePainter extends CustomPainter {
  const _ScanBarcodePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.09
      ..strokeCap = StrokeCap.round;

    // Les quatre coins du viseur.
    final margin = s * 0.1;
    final arm = s * 0.24;
    for (final (x, y, dx, dy) in <(double, double, double, double)>[
      (margin, margin, 1, 1),
      (s - margin, margin, -1, 1),
      (margin, s - margin, 1, -1),
      (s - margin, s - margin, -1, -1),
    ]) {
      canvas
        ..drawLine(Offset(x, y), Offset(x + dx * arm, y), stroke)
        ..drawLine(Offset(x, y), Offset(x, y + dy * arm), stroke);
    }

    // Les barres, de largeurs inégales comme un vrai code-barres.
    final fill = Paint()..color = color;
    final top = s * 0.32;
    final bottom = s * 0.68;
    var x = s * 0.3;
    for (final width in const <double>[
      0.06,
      0.03,
      0.08,
      0.03,
      0.05,
      0.03,
      0.07,
    ]) {
      canvas.drawRect(Rect.fromLTRB(x, top, x + s * width, bottom), fill);
      x += s * width + s * 0.035;
    }
  }

  @override
  bool shouldRepaint(_ScanBarcodePainter oldDelegate) =>
      oldDelegate.color != color;
}
