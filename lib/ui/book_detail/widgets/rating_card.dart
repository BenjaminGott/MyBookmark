import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/library_item.dart';
import '../../providers/book_actions_controller.dart';
import '../../widgets/star_rating.dart';
import 'section_card.dart';

/// Note en étoiles et avis libre, indépendants l'un de l'autre.
class RatingCard extends ConsumerStatefulWidget {
  const RatingCard({required this.item, super.key});

  final LibraryItem item;

  @override
  ConsumerState<RatingCard> createState() => _RatingCardState();
}

class _RatingCardState extends ConsumerState<RatingCard> {
  late final TextEditingController _review =
      TextEditingController(text: widget.item.currentEntry.review ?? '');

  /// Vrai dès que l'avis affiché diffère de celui enregistré.
  bool _dirty = false;

  @override
  void dispose() {
    _review.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(bookActionsProvider);
    final entry = widget.item.currentEntry;

    return SectionCard(
      title: 'Ma note et mon avis',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              StarRating(
                rating: entry.rating,
                size: 32,
                onChanged: busy ? null : _rate,
              ),
              const SizedBox(width: 8),
              if (entry.rating == null)
                Text(
                  'Pas encore noté',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _review,
            minLines: 3,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            onChanged: (value) {
              final dirty = value.trim() != (entry.review ?? '').trim();
              if (dirty != _dirty) {
                setState(() => _dirty = dirty);
              }
            },
            decoration: const InputDecoration(
              labelText: 'Mon avis',
              hintText: 'Ce que vous en avez pensé, pour vous en souvenir.',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              // Rien à enregistrer tant que le texte n'a pas changé.
              onPressed: busy || !_dirty ? null : _saveReview,
              child: const Text('Enregistrer l\'avis'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rate(int? rating) async {
    final outcome = await ref
        .read(bookActionsProvider.notifier)
        .rate(entryId: widget.item.currentEntry.id, rating: rating);
    if (!mounted || outcome is ActionSuccess) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text((outcome as ActionFailure).message)),
    );
  }

  Future<void> _saveReview() async {
    final outcome = await ref
        .read(bookActionsProvider.notifier)
        .writeReview(entryId: widget.item.currentEntry.id, review: _review.text);
    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    switch (outcome) {
      case ActionSuccess():
        setState(() => _dirty = false);
        messenger.showSnackBar(const SnackBar(content: Text('Avis enregistré')));
      case ActionFailure(message: final message):
        messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
