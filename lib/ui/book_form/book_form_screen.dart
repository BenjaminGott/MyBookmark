import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/book.dart';
import '../../domain/models/shelf.dart';
import '../providers/book_actions_controller.dart';
import '../providers/book_providers.dart';
import '../shelf_labels.dart';

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

  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _author =
      TextEditingController(text: widget.existing?.author ?? '');
  late final TextEditingController _pageCount = TextEditingController(
    text: widget.existing?.pageCount?.toString() ?? '',
  );
  late final TextEditingController _year = TextEditingController(
    text: widget.existing?.firstPublishYear?.toString() ?? '',
  );
  late final TextEditingController _description =
      TextEditingController(text: widget.existing?.description ?? '');

  Shelf _shelf = Shelf.toRead;

  @override
  void dispose() {
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Corriger les informations' : 'Ajouter un livre',
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              controller: _title,
              autofocus: !widget.isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titre *',
                hintText: 'Obligatoire',
              ),
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'Le titre est obligatoire.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _author,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Auteur'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pageCount,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Nombre de pages',
                helperText: 'Laissez vide si vous ne le connaissez pas.',
              ),
              validator: _validatePageCount,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _year,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                labelText: 'Année de parution',
              ),
              validator: _validateYear,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 10,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Résumé',
                alignLabelWithHint: true,
              ),
            ),
            if (!widget.isEditing) ...<Widget>[
              const SizedBox(height: 24),
              Text('Étagère', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<Shelf>(
                segments: <ButtonSegment<Shelf>>[
                  for (final shelf in Shelf.values)
                    ButtonSegment<Shelf>(
                      value: shelf,
                      icon: Icon(shelf.icon),
                      label: Text(shelf.label),
                    ),
                ],
                selected: <Shelf>{_shelf},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    setState(() => _shelf = selection.first),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: busy ? null : _submit,
              child: Text(widget.isEditing ? 'Enregistrer' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validatePageCount(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return null;
    }
    final pages = int.tryParse(text);
    if (pages == null || pages <= 0) {
      return 'Indiquez un nombre de pages supérieur à zéro.';
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
      return 'Indiquez une année entre 1 et $nextYear.';
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
          )
        : await controller.editBook(
            bookId: existing.id,
            title: _title.text,
            author: _author.text,
            pageCount: pageCount,
            firstPublishYear: year,
            description: _description.text,
          );

    if (!mounted) {
      return;
    }

    // Le messager est récupéré avant de fermer l'écran : après le pop, ce
    // contexte n'est plus monté.
    final messenger = ScaffoldMessenger.of(context);

    switch (outcome) {
      case ActionSuccess():
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Informations mises à jour'
                  : _shelf.addedMessage,
            ),
          ),
        );
      case ActionFailure(message: final message):
        messenger.showSnackBar(SnackBar(content: Text(message)));
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ce livre n\'existe plus.')),
    );
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
