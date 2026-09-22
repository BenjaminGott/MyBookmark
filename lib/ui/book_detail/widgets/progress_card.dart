import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/library_item.dart';
import '../../../domain/services/reading_progress.dart';
import '../../providers/book_actions_controller.dart';
import '../../widgets/progress_bar.dart';
import 'section_card.dart';

/// Saisie de la page en cours, avec pourcentage et barre.
///
/// Le champ accepte n'importe quel nombre : la valeur est ramenée dans les
/// bornes du livre à l'enregistrement, et l'utilisateur en est averti.
class ProgressCard extends ConsumerStatefulWidget {
  const ProgressCard({required this.item, super.key});

  final LibraryItem item;

  @override
  ConsumerState<ProgressCard> createState() => _ProgressCardState();
}

class _ProgressCardState extends ConsumerState<ProgressCard> {
  late final TextEditingController _page = TextEditingController(
    text: widget.item.currentEntry.currentPage == 0
        ? ''
        : '${widget.item.currentEntry.currentPage}',
  );

  @override
  void didUpdateWidget(ProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final page = widget.item.currentEntry.currentPage;
    // Une écriture venue d'ailleurs (bouton « terminé », relecture) doit se
    // refléter dans le champ, mais sans écraser une saisie en cours.
    if (page != oldWidget.item.currentEntry.currentPage) {
      _page.text = page == 0 ? '' : '$page';
    }
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(bookActionsProvider);
    final entry = widget.item.currentEntry;
    final pageCount = widget.item.book.pageCount;

    return SectionCard(
      title: 'Progression',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ReadingProgressBar(
            currentPage: entry.currentPage,
            pageCount: pageCount,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _page,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    labelText: 'Page en cours',
                    helperText: pageCount == null
                        ? 'Nombre de pages inconnu'
                        : 'sur $pageCount',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: FilledButton(
                  onPressed: busy ? null : _save,
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
          if (pageCount != null) ...<Widget>[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: busy ? null : () => _saveValue(pageCount),
                icon: const Icon(Icons.done_all),
                label: const Text('Je suis à la dernière page'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _save() {
    final typed = int.tryParse(_page.text.trim()) ?? 0;
    return _saveValue(typed);
  }

  Future<void> _saveValue(int page) async {
    final pageCount = widget.item.book.pageCount;
    final clamped = ReadingProgress.clampPage(page: page, pageCount: pageCount);

    final outcome = await ref.read(bookActionsProvider.notifier).updateProgress(
          entryId: widget.item.currentEntry.id,
          page: page,
        );
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    switch (outcome) {
      case ActionSuccess():
        if (clamped != page) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Ce livre fait $pageCount pages : la progression a été '
                'enregistrée à la page $clamped.',
              ),
            ),
          );
        }
      case ActionFailure(message: final message):
        messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
