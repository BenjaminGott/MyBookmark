import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_links.dart';
import '../l10n/l10n.dart';
import '../providers/settings_providers.dart';

/// Écrire au développeur, noter l'application, ouvrir un lien : partagé par
/// les réglages et l'écran « À propos ».
class FeedbackActions {
  const FeedbackActions._();

  /// Ouvre la messagerie. Sans messagerie, l'adresse est copiée pour pouvoir
  /// écrire d'ailleurs.
  static Future<void> writeToMe(BuildContext context, WidgetRef ref) async {
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
  static Future<void> rate(BuildContext context, WidgetRef ref) async {
    if (await ref.read(externalLinksProvider).open(AppLinks.playStoreApp)) {
      return;
    }
    if (context.mounted) {
      await open(context, ref, AppLinks.playStoreWeb);
    }
  }

  static Future<void> open(BuildContext context, WidgetRef ref, Uri uri) async {
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
