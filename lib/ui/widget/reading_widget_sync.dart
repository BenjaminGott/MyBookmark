import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/widget/home_widget_reading_widget.dart';
import '../../domain/models/library_item.dart';
import '../../domain/models/library_query.dart';
import '../../domain/models/shelf.dart';
import '../../domain/repositories/reading_widget.dart';
import '../../domain/services/reading_progress.dart';
import '../book_detail/book_detail_screen.dart';
import '../l10n/l10n.dart';
import '../providers/book_providers.dart';

final Provider<ReadingWidget> readingWidgetProvider = Provider<ReadingWidget>(
  (ref) => const HomeWidgetReadingWidget(),
);

/// Le livre que montre le widget : le dernier touché parmi ceux en cours.
final StreamProvider<LibraryItem?> widgetBookProvider =
    StreamProvider<LibraryItem?>((ref) {
      return ref
          .watch(bookRepositoryProvider)
          .watchLibrary(const LibraryQuery(shelf: Shelf.reading))
          .map((items) {
            if (items.isEmpty) {
              return null;
            }
            return items.reduce(
              (a, b) =>
                  a.currentEntry.updatedAt.isAfter(b.currentEntry.updatedAt)
                  ? a
                  : b,
            );
          });
    });

/// Tient le widget d'écran d'accueil à jour, et ouvre le livre qu'on y
/// touche. Posé sous le `MaterialApp`, pour en avoir la langue.
class ReadingWidgetSync extends ConsumerStatefulWidget {
  const ReadingWidgetSync({
    required this.navigatorKey,
    required this.child,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<ReadingWidgetSync> createState() => _ReadingWidgetSyncState();
}

class _ReadingWidgetSyncState extends ConsumerState<ReadingWidgetSync> {
  /// Le widget n'existe que sur Android ; ailleurs (et dans les tests), ce
  /// composant ne fait rien.
  static final bool _enabled = Platform.isAndroid;

  StreamSubscription<int>? _taps;
  Timer? _pending;
  String? _coverUrl;
  Uint8List? _cover;

  @override
  void initState() {
    super.initState();
    if (!_enabled) {
      return;
    }
    final widgetApi = ref.read(readingWidgetProvider);
    unawaited(widgetApi.launchedBook().then(_open));
    _taps = widgetApi.tappedBooks.listen(_open);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // La langue a pu changer : les textes du widget aussi.
    _schedule();
  }

  @override
  void dispose() {
    _taps?.cancel();
    _pending?.cancel();
    super.dispose();
  }

  void _open(int? bookId) {
    if (bookId == null) {
      return;
    }
    widget.navigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (_) => BookDetailScreen(bookId: bookId)),
    );
  }

  /// Regroupe les changements rapprochés (une page saisie, puis une autre).
  void _schedule() {
    if (!_enabled) {
      return;
    }
    _pending?.cancel();
    _pending = Timer(const Duration(milliseconds: 600), _update);
  }

  Future<void> _update() async {
    if (!mounted) {
      return;
    }
    final item = ref.read(widgetBookProvider).value;
    final l10n = context.l10n;
    ReadingWidgetContent? content;
    if (item != null) {
      final book = item.book;
      final page = item.currentEntry.currentPage;
      final total = book.pageCount;
      final percent = ReadingProgress.percent(
        currentPage: page,
        pageCount: total,
      );
      content = ReadingWidgetContent(
        bookId: book.id,
        kicker: l10n.cardKickerReading,
        title: book.title,
        author: book.author ?? '',
        progress: total == null || percent == null
            ? l10n.cardPage(page)
            : l10n.progressPageOf(page, total, percent),
        percent: percent,
        cover: await _coverOf(book.coverUrl),
      );
    }
    if (!mounted) {
      return;
    }
    await ref
        .read(readingWidgetProvider)
        .show(
          content,
          emptyTitle: l10n.widgetEmptyTitle,
          emptyHint: l10n.widgetEmptyHint,
        );
  }

  /// La couverture, réduite pour le widget : une seule fois par adresse.
  Future<Uint8List?> _coverOf(String? url) async {
    if (url == null || url.isEmpty) {
      return null;
    }
    if (url == _coverUrl) {
      return _cover;
    }
    Uint8List? small;
    try {
      final uri = Uri.parse(url);
      final bytes = uri.isScheme('file')
          ? await File(uri.toFilePath()).readAsBytes()
          : (await http.get(uri).timeout(const Duration(seconds: 15)))
                .bodyBytes;
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 180);
      final frame = await codec.getNextFrame();
      final png = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      frame.image.dispose();
      small = png?.buffer.asUint8List();
    } on Object {
      small = null;
    }
    _coverUrl = url;
    _cover = small;
    return small;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<LibraryItem?>>(widgetBookProvider, (_, _) {
      _schedule();
    });
    return widget.child;
  }
}
