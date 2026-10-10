import 'dart:io' show ZLibCodec;
import 'dart:typed_data';

/// Encode la carte capturée en PNG, coins arrondis compris.
///
/// [rgba] est l'image en RGBA non prémultiplié, ligne par ligne.
///
/// Les coins restent transparents, mais leurs pixels prennent la couleur du
/// bord de la carte au lieu du noir. Beaucoup d'applications ignorent la
/// transparence (galerie, messageries, Instagram selon les cas) : sans cela,
/// elles montraient des angles noirs autour des coins arrondis. Avec, elles
/// montrent au pire des angles droits de la couleur de la carte.
Uint8List encodeCardPng(Uint8List rgba, int width, int height) {
  _bleedEdges(rgba, width, height);
  return _encodePng(rgba, width, height);
}

/// Donne aux pixels transparents de chaque ligne la couleur du premier pixel
/// opaque, à gauche comme à droite. L'alpha n'est jamais touché.
void _bleedEdges(Uint8List rgba, int width, int height) {
  for (var y = 0; y < height; y++) {
    final row = y * width * 4;

    var first = 0;
    while (first < width && rgba[row + first * 4 + 3] != 255) {
      first++;
    }
    if (first == width) {
      // Aucune couleur sur cette ligne : rien à prolonger.
      continue;
    }
    var last = width - 1;
    while (rgba[row + last * 4 + 3] != 255) {
      last--;
    }

    for (var x = 0; x < first; x++) {
      _fillTransparent(rgba, row + first * 4, row + x * 4);
    }
    for (var x = last + 1; x < width; x++) {
      _fillTransparent(rgba, row + last * 4, row + x * 4);
    }
  }
}

/// Seuls les pixels entièrement transparents changent : le liseré
/// semi-transparent des coins garde sa couleur et son lissage.
void _fillTransparent(Uint8List rgba, int from, int to) {
  if (rgba[to + 3] != 0) {
    return;
  }
  rgba[to] = rgba[from];
  rgba[to + 1] = rgba[from + 1];
  rgba[to + 2] = rgba[from + 2];
}

/// Un PNG minimal : RGBA 8 bits, sans filtre, compressé par zlib.
///
/// Le moteur de Flutter ne sait produire que des pixels prémultipliés, où un
/// pixel transparent perd forcément sa couleur : d'où cet encodeur.
Uint8List _encodePng(Uint8List rgba, int width, int height) {
  final stride = width * 4;
  // Chaque ligne commence par l'octet de filtre 0 (« aucun »).
  final raw = Uint8List(height * (stride + 1));
  for (var y = 0; y < height; y++) {
    raw.setRange(
      y * (stride + 1) + 1,
      (y + 1) * (stride + 1),
      rgba,
      y * stride,
    );
  }

  final header = ByteData(13)
    ..setUint32(0, width)
    ..setUint32(4, height)
    ..setUint8(8, 8) // 8 bits par canal
    ..setUint8(9, 6) // RGBA
    ..setUint8(10, 0)
    ..setUint8(11, 0)
    ..setUint8(12, 0);

  final out = BytesBuilder(copy: false)
    ..add(const <int>[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  _chunk(out, 'IHDR', header.buffer.asUint8List());
  _chunk(out, 'IDAT', ZLibCodec(level: 6).encode(raw));
  _chunk(out, 'IEND', Uint8List(0));
  return out.takeBytes();
}

void _chunk(BytesBuilder out, String type, List<int> data) {
  final typeBytes = type.codeUnits;
  out
    ..add(_uint32(data.length))
    ..add(typeBytes)
    ..add(data)
    ..add(_uint32(_crc32(<List<int>>[typeBytes, data])));
}

Uint8List _uint32(int value) =>
    (ByteData(4)..setUint32(0, value)).buffer.asUint8List();

final List<int> _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<List<int>> parts) {
  var crc = 0xFFFFFFFF;
  for (final part in parts) {
    for (final byte in part) {
      crc = _crcTable[(crc ^ byte) & 0xFF] ^ (crc >> 8);
    }
  }
  return crc ^ 0xFFFFFFFF;
}
