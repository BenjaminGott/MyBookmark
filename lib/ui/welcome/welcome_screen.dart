import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/app_language.dart';
import '../l10n/app_language_label.dart';
import '../l10n/l10n.dart';
import '../providers/settings_providers.dart';

/// Premier lancement : le choix de la langue, avant tout le reste.
///
/// La langue du téléphone est proposée d'office. L'écran se traduit dès qu'on
/// touche une option, pour que chacun voie ce qu'il choisit.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  late AppLanguage _selected = systemLanguage();

  static const List<AppLanguage> _choices = <AppLanguage>[
    AppLanguage.french,
    AppLanguage.english,
  ];

  @override
  Widget build(BuildContext context) {
    return Localizations.override(
      context: context,
      locale: Locale(_selected.languageCode!),
      child: Builder(builder: _buildContent),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                Center(
                  child: ExcludeSemantics(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.green,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Image.asset(
                          'assets/logo.png',
                          width: 72,
                          height: 72,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.welcomeTitle,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.appTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  l10n.welcomeChooseLanguage,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                RadioGroup<AppLanguage>(
                  groupValue: _selected,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selected = value);
                    }
                  },
                  child: Column(
                    children: <Widget>[
                      for (final language in _choices)
                        RadioListTile<AppLanguage>(
                          value: language,
                          title: Text(language.label(l10n)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.welcomeHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () =>
                      ref.read(languageProvider.notifier).select(_selected),
                  child: Text(l10n.continueButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
