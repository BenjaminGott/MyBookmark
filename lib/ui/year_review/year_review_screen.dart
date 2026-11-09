import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/failure.dart';
import '../../domain/models/year_review.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../providers/share_providers.dart';
import '../widgets/status_views.dart';
import 'year_review_providers.dart';
import 'year_review_slides.dart';

/// Un bilan annuel, page après page, comme une story : toucher à droite
/// avance, toucher à gauche recule. Chaque page se partage ou s'enregistre en
/// image 1080 × 1920.
class YearReviewScreen extends ConsumerStatefulWidget {
  const YearReviewScreen({required this.year, super.key});

  final int year;

  @override
  ConsumerState<YearReviewScreen> createState() => _YearReviewScreenState();
}

class _YearReviewScreenState extends ConsumerState<YearReviewScreen> {
  final PageController _pages = PageController();
  final Map<int, GlobalKey> _slideKeys = <int, GlobalKey>{};
  int _index = 0;
  bool _busy = false;

  /// L'export se fait à trois fois la taille de dessin : 1080 × 1920.
  static const double _captureRatio = 3;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(int index) => _slideKeys.putIfAbsent(index, GlobalKey.new);

  void _go(int delta, int count) {
    final target = (_index + delta).clamp(0, count - 1);
    if (target != _index) {
      _pages.animateToPage(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<Uint8List?> _capture() async {
    final boundary =
        _keyFor(_index).currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }
    final image = await boundary.toImage(pixelRatio: _captureRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  Future<void> _export({required bool share}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.yearReviewExportFailed)),
        );
        return;
      }
      final name = 'mybookmark-${widget.year}-${_index + 1}';
      if (share) {
        await ref
            .read(imageSharingProvider)
            .sharePng(bytes: bytes, fileName: '$name.png');
      } else {
        await ref.read(imageSavingProvider).savePng(bytes: bytes, name: name);
        messenger.showSnackBar(SnackBar(content: Text(l10n.yearReviewSaved)));
      }
    } on AppException catch (error) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(error.describe(context.l10n))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _update() async {
    final message = context.l10n.yearReviewUpdated;
    final messenger = ScaffoldMessenger.of(context);
    await refreshYearReview(ref, widget.year);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final review = ref.watch(yearReviewProvider(widget.year));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l10n.yearReviewTitle('${widget.year}')),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.yearReviewUpdate,
            onPressed: _busy ? null : _update,
          ),
        ],
      ),
      body: review.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorView(
          error: error is AppException
              ? error
              : const StorageException(AppErrorReason.libraryReadFailed),
        ),
        data: (review) => review == null
            ? EmptyState(
                icon: Icons.auto_stories_outlined,
                title: l10n.yearReviewNone('${widget.year}'),
              )
            : _buildStory(context, review),
      ),
    );
  }

  Widget _buildStory(BuildContext context, YearReview review) {
    final l10n = context.l10n;
    final slides = yearReviewSlides(review);

    return SafeArea(
      top: false,
      child: Column(
        children: <Widget>[
          // Une barre par page, comme dans une story.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: <Widget>[
                for (var i = 0; i < slides.length; i++)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i <= _index ? Colors.white : Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) => _go(
                  details.localPosition.dx < constraints.maxWidth / 3 ? -1 : 1,
                  slides.length,
                ),
                child: PageView.builder(
                  controller: _pages,
                  itemCount: slides.length,
                  onPageChanged: (index) => setState(() => _index = index),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: yearReviewSlideSize.aspectRatio,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FittedBox(
                            // Le texte du bilan a sa taille de dessin : la
                            // police du téléphone ne doit pas déborder.
                            child: MediaQuery.withNoTextScaling(
                              child: RepaintBoundary(
                                key: _keyFor(index),
                                child: slides[index],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    onPressed: _busy ? null : () => _export(share: false),
                    icon: const Icon(Icons.download_outlined),
                    label: Text(l10n.yearReviewSave),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : () => _export(share: true),
                    icon: const Icon(Icons.share_outlined),
                    label: Text(l10n.yearReviewShare),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
