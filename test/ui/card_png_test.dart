import 'dart:io' show ZLibCodec;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:biblivre/ui/share/card_png.dart';
import 'package:flutter_test/flutter_test.dart';

/// Relit les pixels d'un PNG produit par [encodeCardPng] : un seul bloc IDAT,
/// sans filtre.
Uint8List _pixels(Uint8List png, int width, int height) {
  final data = ByteData.sublistView(png);
  var offset = 8;
  while (offset < png.length) {
    final length = data.getUint32(offset);
    final type = String.fromCharCodes(png.sublist(offset + 4, offset + 8));
    if (type == 'IDAT') {
      final raw = ZLibCodec().decode(
        png.sublist(offset + 8, offset + 8 + length),
      );
      final stride = width * 4;
      final out = Uint8List(height * stride);
      for (var y = 0; y < height; y++) {
        out.setRange(y * stride, (y + 1) * stride, raw, y * (stride + 1) + 1);
      }
      return out;
    }
    offset += 12 + length;
  }
  throw StateError('pas de IDAT');
}

void main() {
  // Une ligne de 4 pixels : coin transparent, liseré à moitié opaque, puis
  // deux pixels de la carte.
  Uint8List row() => Uint8List.fromList(<int>[
    0, 0, 0, 0, //
    10, 20, 30, 128,
    10, 80, 70, 255,
    90, 80, 70, 255,
  ]);

  test('les coins transparents prennent la couleur du bord, pas le noir', () {
    final png = encodeCardPng(row(), 4, 1);
    final pixels = _pixels(png, 4, 1);

    // Le coin reste transparent, mais coloré comme le bord de la carte.
    expect(pixels.sublist(0, 4), <int>[10, 80, 70, 0]);
    // Le liseré et la carte ne changent pas.
    expect(pixels.sublist(4), row().sublist(4));
  });

  test('le bord droit est traité comme le gauche', () {
    final rgba = Uint8List.fromList(<int>[
      90, 80, 70, 255, //
      0, 0, 0, 0,
    ]);
    final pixels = _pixels(encodeCardPng(rgba, 2, 1), 2, 1);
    expect(pixels.sublist(4), <int>[90, 80, 70, 0]);
  });

  test('produit un PNG que le moteur sait lire', () async {
    final codec = await ui.instantiateImageCodec(encodeCardPng(row(), 4, 1));
    final frame = await codec.getNextFrame();
    expect(frame.image.width, 4);
    expect(frame.image.height, 1);
  });
}
