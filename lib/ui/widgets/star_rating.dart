import 'package:flutter/material.dart';

/// Une note de 1 à 5 étoiles entières.
///
/// En lecture seule quand [onChanged] est nul. Sinon, toucher une étoile note,
/// et retoucher la même étoile efface la note — on peut donc revenir à « pas
/// encore noté » sans passer par un menu.
class StarRating extends StatelessWidget {
  const StarRating({
    required this.rating,
    super.key,
    this.onChanged,
    this.size = 24,
  });

  static const int maxRating = 5;

  final int? rating;
  final ValueChanged<int?>? onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final current = rating;
    final interactive = onChanged != null;

    return Semantics(
      label: current == null
          ? 'Pas encore noté'
          : 'Noté $current sur $maxRating',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var star = 1; star <= maxRating; star++)
            IconButton(
              padding: EdgeInsets.all(interactive ? 4 : 0),
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              iconSize: size,
              tooltip: interactive ? '$star étoile${star > 1 ? 's' : ''}' : null,
              onPressed: interactive
                  ? () => onChanged!(current == star ? null : star)
                  : null,
              icon: Icon(
                current != null && star <= current
                    ? Icons.star
                    : Icons.star_border,
                color: current != null && star <= current
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
