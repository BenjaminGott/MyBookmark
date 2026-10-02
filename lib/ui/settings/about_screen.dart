import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_links.dart';
import '../../core/theme/app_theme.dart';
import '../l10n/l10n.dart';
import '../providers/settings_providers.dart';

/// « À propos » : qui fait l'application, son esprit, et deux façons d'aider,
/// écrire au développeur ou noter l'application.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final french = Localizations.localeOf(context).languageCode == 'fr';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: <Widget>[
          Center(
            child: ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppTheme.green,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset('assets/logo.png', width: 64, height: 64),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.appTitle,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            l10n.aboutBy,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _Section(title: l10n.aboutWhoTitle, child: Text(l10n.aboutWhoBody)),
          _Section(
            title: l10n.aboutSpiritTitle,
            child: Column(
              children: <Widget>[
                _Point(Icons.volunteer_activism_outlined, l10n.aboutSpiritFree),
                _Point(Icons.person_off_outlined, l10n.aboutSpiritNoAccount),
                _Point(Icons.phone_android_outlined, l10n.aboutSpiritLocal),
                _Point(
                  Icons.visibility_off_outlined,
                  l10n.aboutSpiritNoTracking,
                ),
              ],
            ),
          ),
          _Section(
            title: l10n.aboutFeedbackTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.aboutFeedbackBody),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _writeToMe(context, ref),
                  icon: const Icon(Icons.mail_outline),
                  label: Text(l10n.aboutFeedbackButton),
                ),
              ],
            ),
          ),
          _Section(
            title: l10n.aboutRateTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(l10n.aboutRateBody),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _rate(context, ref),
                  icon: const Icon(Icons.star_outline),
                  label: Text(l10n.aboutRateButton),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.public),
            title: Text(l10n.aboutWebsite),
            onTap: () => _open(context, ref, AppLinks.website(french: french)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.aboutPrivacy),
            onTap: () => _open(context, ref, AppLinks.privacy(french: french)),
          ),
        ],
      ),
    );
  }

  /// Ouvre la messagerie. Sans messagerie, l'adresse est copiée pour pouvoir
  /// écrire d'ailleurs.
  Future<void> _writeToMe(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final opened = await ref
        .read(externalLinksProvider)
        .open(AppLinks.feedbackEmail(subject: l10n.aboutFeedbackSubject));
    if (opened || !context.mounted) {
      return;
    }
    await Clipboard.setData(const ClipboardData(text: AppLinks.contactEmail));
    if (context.mounted) {
      _tell(context, l10n.aboutNoMailApp(AppLinks.contactEmail));
    }
  }

  /// L'application Play Store si elle est là, sinon la fiche dans le
  /// navigateur.
  Future<void> _rate(BuildContext context, WidgetRef ref) async {
    final links = ref.read(externalLinksProvider);
    if (await links.open(AppLinks.playStoreApp)) {
      return;
    }
    if (context.mounted) {
      await _open(context, ref, AppLinks.playStoreWeb);
    }
  }

  Future<void> _open(BuildContext context, WidgetRef ref, Uri uri) async {
    final opened = await ref.read(externalLinksProvider).open(uri);
    if (!opened && context.mounted) {
      _tell(context, context.l10n.aboutLinkFailed);
    }
  }

  static void _tell(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

/// Une ligne de « l'esprit de l'application ».
class _Point extends StatelessWidget {
  const _Point(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
