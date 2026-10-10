import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/library_item.dart';
import '../../../domain/services/reading_progress.dart';
import '../../l10n/error_text.dart';
import '../../l10n/l10n.dart';
import '../../providers/book_actions_controller.dart';
import '../../share/open_progress_sharing.dart';
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
      title: context.l10n.progressTitle,
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
                    labelText: context.l10n.currentPage,
                    helperText: pageCount == null
                        ? context.l10n.pageCountUnknown
                        : context.l10n.ofPages(pageCount),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: FilledButton(
                  onPressed: busy ? null : _save,
                  child: Text(context.l10n.save),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Aux extrémités quand la place suffit ; l'un sous l'autre avec une
          // grande taille de police, plutôt que de déborder.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: <Widget>[
                if (pageCount != null)
                  TextButton.icon(
                    onPressed: busy ? null : () => _saveValue(pageCount),
                    icon: const Icon(Icons.done_all),
                    label: Text(context.l10n.lastPage),
                  ),
                TextButton.icon(
                  onPressed: () => openProgressSharing(context, widget.item),
                  icon: const Icon(Icons.share_outlined),
                  label: Text(context.l10n.share),
                ),
              ],
            ),
          ),
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

    final outcome = await ref
        .read(bookActionsProvider.notifier)
        .updateProgress(entryId: widget.item.currentEntry.id, page: page);
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    switch (outcome) {
      case ActionSuccess():
        if (clamped != page && pageCount != null) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.pageClamped(pageCount, clamped))),
          );
        }
      case ActionFailure(:final error):
        messenger.showSnackBar(SnackBar(content: Text(error.describe(l10n))));
    }
  }
}
