import 'package:flutter/material.dart';

import '../../domain/models/app_language.dart';
import 'app_language_label.dart';
import 'l10n.dart';

/// Liste déroulante des langues, utilisée à l'accueil et dans les réglages.
class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({
    super.key,
    required this.languages,
    required this.value,
    required this.onChanged,
  });

  final List<AppLanguage> languages;
  final AppLanguage value;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Pas d'intitulé : les deux écrans ont déjà un titre au-dessus.
    return DropdownButtonFormField<AppLanguage>(
      // La clé recrée le champ si la langue change ailleurs : il affiche
      // toujours la langue en cours.
      key: ValueKey<AppLanguage>(value),
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.translate),
        border: OutlineInputBorder(),
      ),
      items: <DropdownMenuItem<AppLanguage>>[
        for (final language in languages)
          DropdownMenuItem<AppLanguage>(
            value: language,
            child: Text(language.label(l10n)),
          ),
      ],
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}
