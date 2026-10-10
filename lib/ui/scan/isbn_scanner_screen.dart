import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

import '../../domain/services/isbn.dart';
import '../l10n/l10n.dart';

/// Ouvre l'appareil photo et rend l'ISBN lu au dos d'un livre, ou `null` si
/// l'utilisateur revient en arrière.
typedef IsbnScanner = Future<String?> Function(BuildContext context);

/// Le scanner, remplaçable dans les tests (pas d'appareil photo en test).
final Provider<IsbnScanner> isbnScannerProvider = Provider<IsbnScanner>(
  (ref) =>
      (context) => Navigator.of(context).push<String>(
        MaterialPageRoute<String>(builder: (_) => const IsbnScannerScreen()),
      ),
);

/// Le code-barres d'un livre, lu par l'appareil photo.
///
/// Le décodage se fait sur le téléphone (zxing) : aucune image ne sort de
/// l'appareil. Seuls les EAN-13 qui sont des ISBN sont acceptés.
class IsbnScannerScreen extends StatefulWidget {
  const IsbnScannerScreen({super.key});

  @override
  State<IsbnScannerScreen> createState() => _IsbnScannerScreenState();
}

class _IsbnScannerScreenState extends State<IsbnScannerScreen> {
  bool _done = false;

  void _onScan(Code code) {
    if (_done || !mounted) {
      return;
    }
    final isbn = Isbn.fromBarcode(code.text);
    if (isbn == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.scanNotIsbn)));
      return;
    }
    _done = true;
    Navigator.of(context).pop(isbn);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.scanTitle),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ReaderWidget(
              onScan: _onScan,
              codeFormat: Format.ean13,
              // Le dos d'un livre : un code-barres large et peu haut.
              cropPercent: 0.7,
              showGallery: false,
              showToggleCamera: false,
              tryHarder: true,
              scanDelay: const Duration(milliseconds: 300),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32 + MediaQuery.paddingOf(context).bottom,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(
                  l10n.scanHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
