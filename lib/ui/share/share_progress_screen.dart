import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/failure.dart';
import '../../domain/models/library_item.dart';
import '../providers/share_providers.dart';
import 'background_picker.dart';
import 'card_backgrounds.dart';
import 'progress_card_palette.dart';
import 'progress_share_card.dart';

/// Aperçu de la carte de progression, puis partage.
///
/// L'ordre des opérations compte : la couverture est chargée et décodée, puis sa
/// palette est calculée, et seulement ensuite la carte est dessinée. Capturer
/// avant que l'image ne soit en cache donnerait une couverture vide.
class ShareProgressScreen extends ConsumerStatefulWidget {
  const ShareProgressScreen({required this.item, super.key});

  final LibraryItem item;

  @override
  ConsumerState<ShareProgressScreen> createState() =>
      _ShareProgressScreenState();
}

class _ShareProgressScreenState extends ConsumerState<ShareProgressScreen> {
  final GlobalKey _cardKey = GlobalKey();

  /// Les fonds proposés, le premier étant l'automatique.
  List<BackgroundOption>? _backgrounds;

  /// Index choisi dans [_backgrounds], ou `null` si c'est le fond personnel.
  int? _selected = 0;

  /// Le dégradé composé à la main, conservé même quand on repasse sur un
  /// fond proposé : revenir à son choix ne doit pas le faire refaire.
  ProgressCardPalette? _custom;

  ImageProvider? _cover;
  ShareCardFormat _format = ShareCardFormat.large;
  bool _sharing = false;

  /// Le fond réellement appliqué à la carte.
  ProgressCardPalette? get _palette {
    final backgrounds = _backgrounds;
    if (backgrounds == null) {
      return null;
    }
    final index = _selected;
    return index == null ? _custom : backgrounds[index].palette;
  }

  @override
  void initState() {
    super.initState();
    // Le chargement a besoin d'un contexte monté pour `precacheImage`.
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepare());
  }

  Future<void> _prepare() async {
    final url = widget.item.book.coverUrl;
    ImageProvider? cover;

    if (url != null && url.isNotEmpty) {
      final candidate = ref.read(coverImageProviderFactory)(url);
      var failed = false;
      try {
        // Décodage effectif : sans cette attente, la capture partirait avant
        // que l'image ne soit disponible et la couverture sortirait blanche.
        //
        // `onError` est indispensable : sans lui, `precacheImage` avale l'échec
        // et rend la main comme si tout allait bien, ce qui ferait dessiner une
        // image cassée au lieu de basculer sur la variante sans couverture.
        await precacheImage(
          candidate,
          context,
          onError: (error, stackTrace) => failed = true,
        );
      } on Object {
        failed = true;
      }
      cover = failed ? null : candidate;
    }

    final backgrounds = CardBackgrounds.forCover(
      await CoverColors.fromCover(cover),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _cover = cover;
      _backgrounds = backgrounds;
    });
  }

  Future<void> _editCustom() async {
    final chosen = await showCustomBackgroundEditor(
      context,
      initial: _custom ?? _palette,
    );
    if (chosen == null || !mounted) {
      // Annulation : on garde le fond courant, et le fond personnel précédent
      // reste disponible s'il en existait un.
      return;
    }
    setState(() {
      _custom = chosen;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    // La carte plein écran suit les proportions de l'appareil : une story en
    // 16:9 laisserait des bandes sur un téléphone allongé.
    final size = MediaQuery.sizeOf(context);
    final cardHeight = _format.heightForAspect(size.height / size.width);

    return Scaffold(
      appBar: AppBar(title: const Text('Partager ma progression')),
      body: palette == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _CardPreview(
                      cardKey: _cardKey,
                      item: widget.item,
                      palette: palette,
                      cover: _cover,
                      format: _format,
                      cardHeight: cardHeight,
                    ),
                  ),
                ),
                BackgroundPicker(
                  options: _backgrounds!,
                  selectedIndex: _selected,
                  customPalette: _custom,
                  onSelected: (index) => setState(() => _selected = index),
                  onCustom: _editCustom,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SegmentedButton<ShareCardFormat>(
                    segments: <ButtonSegment<ShareCardFormat>>[
                      for (final format in ShareCardFormat.values)
                        ButtonSegment<ShareCardFormat>(
                          value: format,
                          label: Text(format.label),
                        ),
                    ],
                    selected: <ShareCardFormat>{_format},
                    showSelectedIcon: false,
                    onSelectionChanged: _sharing
                        ? null
                        : (selection) =>
                            setState(() => _format = selection.first),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _format.pixelsFor(cardHeight),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: FilledButton.icon(
                      onPressed: _sharing ? null : _share,
                      icon: const Icon(Icons.share_outlined),
                      label: Text(_sharing ? 'Préparation…' : 'Partager'),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        _tell('Impossible de préparer l\'image.');
        return;
      }

      await ref.read(imageSharingProvider).sharePng(
            bytes: bytes,
            fileName: _format.fileName,
            text: _shareText(),
          );
    } on AppException catch (error) {
      _tell(error.message);
    } finally {
      if (mounted) {
        setState(() => _sharing = false);
      }
    }
  }

  /// Capture la carte dans la taille de son format.
  Future<Uint8List?> _capture() async {
    final boundary =
        _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      return null;
    }

    final image =
        await boundary.toImage(pixelRatio: ProgressShareCard.captureRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  String _shareText() {
    final book = widget.item.book;
    final author = book.author;
    return author == null ? book.title : '${book.title} — $author';
  }

  void _tell(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// La carte à sa taille réelle, mise à l'échelle pour l'aperçu.
///
/// La mise à l'échelle est appliquée **au-dessus** de la frontière de capture,
/// que la carte porte elle-même : la carte est donc toujours dessinée en
/// 360 × 640, quelle que soit la place disponible à l'écran, et l'image
/// partagée ne dépend pas de la taille du téléphone.
class _CardPreview extends StatelessWidget {
  const _CardPreview({
    required this.cardKey,
    required this.item,
    required this.palette,
    required this.cover,
    required this.format,
    required this.cardHeight,
  });

  final GlobalKey cardKey;
  final LibraryItem item;
  final ProgressCardPalette palette;
  final ImageProvider? cover;
  final ShareCardFormat format;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = math.min(
          constraints.maxWidth / format.width,
          constraints.maxHeight / cardHeight,
        );

        return Transform.scale(
          scale: scale,
          child: ProgressShareCard(
            item: item,
            palette: palette,
            cover: cover,
            format: format,
            height: cardHeight,
            captureKey: cardKey,
          ),
        );
      },
    );
  }
}
