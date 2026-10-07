import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/failure.dart';
import '../../domain/models/book.dart';
import '../../domain/models/book_search_result.dart';
import '../../domain/models/shelf.dart';
import '../../domain/repositories/cover_store.dart';
import '../l10n/error_text.dart';
import '../l10n/l10n.dart';
import '../providers/book_actions_controller.dart';
import '../providers/book_providers.dart';
import '../shelf_labels.dart';
import '../widgets/book_cover.dart';
import 'cover_search_sheet.dart';

/// Saisie manuelle d'un livre, et correction d'un livre existant.
///
/// Le même formulaire sert aux deux cas : ajouter un ouvrage qu'Open Library
/// ne connaît pas, et rectifier des métadonnées fausses — un nombre de pages
/// aberrant, par exemple, ce qui arrive souvent avec
/// `number_of_pages_median`.
class BookFormScreen extends ConsumerStatefulWidget {
  /// Formulaire d'ajout d'un livre saisi à la main.
  const BookFormScreen.create({super.key}) : existing = null;

  /// Formulaire de correction d'un livre déjà en bibliothèque.
  const BookFormScreen.edit({required Book book, super.key}) : existing = book;

  final Book? existing;

  bool get isEditing => existing != null;

  @override
  ConsumerState<BookFormScreen> createState() => _BookFormScreenState();
}

class _BookFormScreenState extends ConsumerState<BookFormScreen> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  late final TextEditingController _title = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final TextEditingController _author = TextEditingController(
    text: widget.existing?.author ?? '',
  );
  late final TextEditingController _pageCount = TextEditingController(
    text: widget.existing?.pageCount?.toString() ?? '',
  );
  late final TextEditingController _year = TextEditingController(
    text: widget.existing?.firstPublishYear?.toString() ?? '',
  );
  late final TextEditingController _description = TextEditingController(
    text: widget.existing?.description ?? '',
  );

  Shelf _shelf = Shelf.toRead;

  late String? _coverUrl = widget.existing?.coverUrl;
  late int? _coverId = widget.existing?.coverId;

  /// Lu une fois ici : `ref` n'est plus utilisable dans [dispose].
  late final CoverStore _covers = ref.read(coverStoreProvider);

  /// Les images copiées depuis la galerie pendant cette saisie. Celles qui ne
  /// finissent pas sur le livre sont effacées en quittant l'écran.
  final List<String> _pickedCovers = <String>[];
  String? _savedCoverUrl;

  @override
  void initState() {
    super.initState();
    _covers;
  }

  @override
  void dispose() {
    for (final picked in _pickedCovers) {
      if (picked != _savedCoverUrl) {
        _covers.discard(picked);
      }
    }
    _title.dispose();
    _author.dispose();
    _pageCount.dispose();
    _year.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(bookActionsProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? l10n.editBookDetails : l10n.addBookTitle,
        ),
      ),
      // Le bouton reste en bas de l'écran, toujours visible, au-dessus de la
      // barre de navigation du téléphone.
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: busy ? null : _submit,
            icon: Icon(widget.isEditing ? Icons.check : Icons.add),
            label: Text(widget.isEditing ? l10n.save : l10n.add),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          // La marge du bas laisse passer la barre de navigation du
          // téléphone, pour les écrans sans barre en bas.
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16 + MediaQuery.paddingOf(context).bottom,
          ),
          children: <Widget>[
            _Section(
              icon: Icons.image_outlined,
              title: l10n.formSectionCover,
              child: _CoverField(
                url: _coverUrl,
                onSearch: busy ? null : _searchCover,
                onPick: busy ? null : _pickCover,
                onRemove: busy || _coverUrl == null
                    ? null
                    : () => setState(() {
                        _coverUrl = null;
                        _coverId = null;
                      }),
              ),
            ),
            _Section(
              icon: Icons.menu_book_outlined,
              title: l10n.formSectionBook,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _title,
                    autofocus: !widget.isEditing,
                    textCapitalization: TextCapitalization.sentences,
                    // Le titre est l'information principale : il est écrit
                    // plus gros que le reste.
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: _field(
                      context,
                      label: l10n.titleRequiredLabel,
                      icon: Icons.title,
                      hint: l10n.requiredHint,
                    ),
                    validator: (value) => (value ?? '').trim().isEmpty
                        ? l10n.titleRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _author,
                    textCapitalization: TextCapitalization.words,
                    decoration: _field(
                      context,
                      label: l10n.authorLabel,
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
            ),
            _Section(
              icon: Icons.tune,
              title: l10n.formSectionDetails,
              subtitle: l10n.formDetailsHint,
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          controller: _pageCount,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _field(
                            context,
                            label: l10n.pagesShortLabel,
                            icon: Icons.auto_stories_outlined,
                          ),
                          validator: _validatePageCount,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _year,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: _field(
                            context,
                            label: l10n.yearShortLabel,
                            icon: Icons.event_outlined,
                          ),
                          validator: _validateYear,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _description,
                    minLines: 3,
                    maxLines: 10,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _field(
                      context,
                      label: l10n.summary,
                      icon: Icons.notes,
                    ).copyWith(alignLabelWithHint: true),
                  ),
                ],
              ),
            ),
            if (!widget.isEditing)
              _Section(
                icon: Icons.shelves,
                title: l10n.shelfLabel,
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<Shelf>(
                    segments: <ButtonSegment<Shelf>>[
                      for (final shelf in Shelf.values)
                        ButtonSegment<Shelf>(
                          value: shelf,
                          // L'icône au-dessus du nom, comme un onglet : le
                          // texte a toute la largeur, « En cours » tient sur
                          // une ligne.
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(shelf.icon, size: 20),
                                const SizedBox(height: 4),
                                Text(shelf.label(l10n), maxLines: 1),
                              ],
                            ),
                          ),
                        ),
                    ],
                    selected: <Shelf>{_shelf},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) =>
                        setState(() => _shelf = selection.first),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Un champ du formulaire : fond teinté, coins arrondis et une icône qui
  /// dit ce qu'on y écrit, pour que les champs ne se ressemblent plus tous.
  static InputDecoration _field(
    BuildContext context, {
    required String label,
    required IconData icon,
    String? hint,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(12);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
      errorMaxLines: 3,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    );
  }

  Future<void> _searchCover() async {
    final query = <String>[
      _title.text.trim(),
      _author.text.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
    final picked = await showCoverSearchSheet(context, query: query);
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _coverUrl = picked.coverUrl(CoverSize.large);
      _coverId = picked.coverId;
    });
  }

  Future<void> _pickCover() async {
    try {
      final picked = await _covers.pickFromGallery();
      if (picked == null || !mounted) {
        return;
      }
      _pickedCovers.add(picked);
      setState(() {
        _coverUrl = picked;
        _coverId = null;
      });
    } on AppException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.describe(context.l10n))));
      }
    }
  }

  String? _validatePageCount(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    final pages = int.tryParse(text);
    if (pages == null || pages <= 0) {
      return context.l10n.pageCountInvalid;
    }
    return null;
  }

  String? _validateYear(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    final year = int.tryParse(text);
    final nextYear = DateTime.now().year + 1;
    if (year == null || year < 1 || year > nextYear) {
      return context.l10n.yearInvalid(nextYear);
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) {
      return;
    }

    final controller = ref.read(bookActionsProvider.notifier);
    final pageCount = int.tryParse(_pageCount.text.trim());
    final year = int.tryParse(_year.text.trim());
    final existing = widget.existing;

    final outcome = existing == null
        ? await controller.addManual(
            title: _title.text,
            shelf: _shelf,
            author: _author.text,
            pageCount: pageCount,
            firstPublishYear: year,
            description: _description.text,
            coverUrl: _coverUrl,
          )
        : await controller.editBook(
            bookId: existing.id,
            title: _title.text,
            author: _author.text,
            pageCount: pageCount,
            firstPublishYear: year,
            description: _description.text,
            coverId: _coverId,
            coverUrl: _coverUrl,
          );

    if (!mounted) {
      return;
    }

    // Le messager est récupéré avant de fermer l'écran : après le pop, ce
    // contexte n'est plus monté.
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    switch (outcome) {
      case ActionSuccess():
        _savedCoverUrl = _coverUrl;
        // L'ancienne image de la galerie, remplacée ou retirée, ne sert plus.
        if (existing != null && existing.coverUrl != _coverUrl) {
          unawaited(_covers.discard(existing.coverUrl));
        }
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? l10n.detailsUpdated
                  : _shelf.addedMessage(l10n),
            ),
          ),
        );
      case ActionFailure(:final error):
        messenger.showSnackBar(SnackBar(content: Text(error.describe(l10n))));
    }
  }
}

/// Ouvre le formulaire de correction d'un livre déjà en bibliothèque.
Future<void> openBookEditor(
  BuildContext context,
  WidgetRef ref, {
  required int bookId,
}) async {
  final book = await ref.read(bookRepositoryProvider).findById(bookId);
  if (!context.mounted) {
    return;
  }

  if (book == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.bookGone)));
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => BookFormScreen.edit(book: book),
    ),
  );
}

/// Ouvre le formulaire de saisie manuelle.
Future<void> openManualBookForm(BuildContext context) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => const BookFormScreen.create(),
    ),
  );
}

/// La couverture du livre et les trois façons de la changer.
class _CoverField extends StatelessWidget {
  const _CoverField({
    required this.url,
    required this.onSearch,
    required this.onPick,
    required this.onRemove,
  });

  final String? url;
  final VoidCallback? onSearch;
  final VoidCallback? onPick;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        BookCover(url: url, width: 80, height: 120),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.image_search),
                label: Text(context.l10n.searchOnline),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(context.l10n.fromGallery),
              ),
              if (url != null) ...<Widget>[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.hide_image_outlined),
                  label: Text(context.l10n.removeCover),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Un groupe de champs, posé sur une carte avec son titre.
class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, size: 20, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
