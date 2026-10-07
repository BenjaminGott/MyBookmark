import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'card_backgrounds.dart';
import 'progress_card_palette.dart';

/// La rangée de fonds proposés, plus l'accès aux couleurs personnelles.
class BackgroundPicker extends StatelessWidget {
  const BackgroundPicker({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    required this.onCustom,
    super.key,
    this.customPalette,
  });

  final List<BackgroundOption> options;

  /// Index sélectionné dans [options], ou `null` si c'est le fond personnel.
  final int? selectedIndex;

  final ValueChanged<int> onSelected;
  final VoidCallback onCustom;

  /// Le dégradé personnel, une fois qu'il existe.
  final ProgressCardPalette? customPalette;

  @override
  Widget build(BuildContext context) {
    final custom = customPalette;

    // Les libellés sous les pastilles restent lisibles sans faire déborder la
    // rangée : leur grossissement est plafonné.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: SizedBox(
        height: 84,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: <Widget>[
            for (var index = 0; index < options.length; index++)
              _Swatch(
                label: options[index].kind.label(context.l10n),
                palette: options[index].palette,
                selected: selectedIndex == index,
                onTap: () => onSelected(index),
              ),
            _Swatch(
              label: context.l10n.myColor,
              palette: custom,
              selected: selectedIndex == null,
              onTap: onCustom,
              icon: Icons.palette_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.label,
    required this.palette,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;

  /// Nul tant qu'aucun dégradé personnel n'a été composé.
  final ProgressCardPalette? palette;

  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shown = palette;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: shown == null
                      ? null
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: <Color>[shown.top, shown.bottom],
                        ),
                  color: shown == null ? scheme.surfaceContainerHighest : null,
                  border: Border.all(
                    color: selected ? scheme.primary : scheme.outlineVariant,
                    width: selected ? 3 : 1,
                  ),
                ),
                child: icon == null
                    ? null
                    : Icon(
                        icon,
                        size: 20,
                        color: shown?.foreground ?? scheme.onSurfaceVariant,
                      ),
              ),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compose un dégradé à la main : une couleur en haut, une en bas.
///
/// Renvoie `null` si l'utilisateur referme sans valider.
Future<ProgressCardPalette?> showCustomBackgroundEditor(
  BuildContext context, {
  ProgressCardPalette? initial,
}) {
  return showModalBottomSheet<ProgressCardPalette>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _CustomBackgroundSheet(initial: initial),
  );
}

class _CustomBackgroundSheet extends StatefulWidget {
  const _CustomBackgroundSheet({this.initial});

  final ProgressCardPalette? initial;

  @override
  State<_CustomBackgroundSheet> createState() => _CustomBackgroundSheetState();
}

class _CustomBackgroundSheetState extends State<_CustomBackgroundSheet> {
  late HSVColor _top = HSVColor.fromColor(
    widget.initial?.top ?? const Color(0xFF2B4B6F),
  );
  late HSVColor _bottom = HSVColor.fromColor(
    widget.initial?.bottom ?? const Color(0xFF12202F),
  );

  /// `true` quand les réglages portent sur le haut du dégradé.
  bool _editingTop = true;

  HSVColor get _edited => _editingTop ? _top : _bottom;

  set _edited(HSVColor value) {
    if (_editingTop) {
      _top = value;
    } else {
      _bottom = value;
    }
  }

  ProgressCardPalette get _palette => ProgressCardPalette.custom(
    top: _top.toColor(),
    bottom: _bottom.toColor(),
  );

  @override
  Widget build(BuildContext context) {
    final palette = _palette;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              context.l10n.myGradient,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[palette.top, palette.bottom],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                context.l10n.textPreview,
                style: TextStyle(
                  color: palette.foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              segments: <ButtonSegment<bool>>[
                ButtonSegment<bool>(
                  value: true,
                  label: Text(context.l10n.gradientTop),
                ),
                ButtonSegment<bool>(
                  value: false,
                  label: Text(context.l10n.gradientBottom),
                ),
              ],
              selected: <bool>{_editingTop},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _editingTop = selection.first),
            ),
            const SizedBox(height: 12),
            _HueSlider(
              value: _edited.hue,
              onChanged: (hue) =>
                  setState(() => _edited = _edited.withHue(hue)),
            ),
            _LabelledSlider(
              label: context.l10n.intensity,
              value: _edited.saturation,
              gradient: <Color>[
                HSVColor.fromAHSV(1, _edited.hue, 0, _edited.value).toColor(),
                HSVColor.fromAHSV(1, _edited.hue, 1, _edited.value).toColor(),
              ],
              onChanged: (saturation) =>
                  setState(() => _edited = _edited.withSaturation(saturation)),
            ),
            _LabelledSlider(
              label: context.l10n.lightness,
              value: _edited.value,
              gradient: <Color>[
                Colors.black,
                HSVColor.fromAHSV(
                  1,
                  _edited.hue,
                  _edited.saturation,
                  1,
                ).toColor(),
              ],
              onChanged: (value) =>
                  setState(() => _edited = _edited.withValue(value)),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(_palette),
                    child: Text(context.l10n.apply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Un curseur de teinte, coloré sur toute la roue.
class _HueSlider extends StatelessWidget {
  const _HueSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return _LabelledSlider(
      label: context.l10n.hue,
      value: value / 360,
      gradient: <Color>[
        for (var hue = 0; hue <= 360; hue += 60)
          HSVColor.fromAHSV(1, hue.toDouble() % 360, 1, 1).toColor(),
      ],
      onChanged: (fraction) => onChanged(fraction * 360),
    );
  }
}

/// Un curseur posé sur une bande dégradée, qui montre ce qu'il règle.
class _LabelledSlider extends StatelessWidget {
  const _LabelledSlider({
    required this.label,
    required this.value,
    required this.gradient,
    required this.onChanged,
  });

  final String label;
  final double value;
  final List<Color> gradient;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  gradient: LinearGradient(colors: gradient),
                ),
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 10,
                activeTrackColor: Colors.transparent,
                inactiveTrackColor: Colors.transparent,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: value.clamp(0.0, 1.0),
                onChanged: onChanged,
                semanticFormatterCallback: (value) =>
                    context.l10n.sliderValue(label, (value * 100).round()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
