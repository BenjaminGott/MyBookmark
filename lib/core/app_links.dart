import 'dart:io' show Platform;

/// Les adresses publiques de l'application.
class AppLinks {
  const AppLinks._();

  static const String contactEmail = 'libergot.pro@gmail.com';
  static const String packageName = 'com.libergot.mybookmark';

  /// La fiche Play Store, dans l'application Play Store si elle est là.
  static final Uri playStoreApp = Uri.parse('market://details?id=$packageName');

  /// La même fiche, dans le navigateur.
  static final Uri playStoreWeb = Uri.parse(
    'https://play.google.com/store/apps/details?id=$packageName',
  );

  /// L'identifiant de l'application sur l'App Store (« Apple ID », un nombre,
  /// dans App Store Connect → Informations sur l'app). Tant qu'il est vide,
  /// « Noter l'application » est masqué sur iPhone.
  static const String? appStoreId = null;

  /// La page d'avis de l'App Store, ouverte dans l'application App Store.
  static Uri? get appStoreReview => appStoreId == null
      ? null
      : Uri.parse(
          'https://apps.apple.com/app/id$appStoreId?action=write-review',
        );

  /// La boutique de la plateforme, pour les textes : `apple` ou `google`.
  static String get store => Platform.isIOS ? 'apple' : 'google';

  /// Vrai si « Noter l'application » mène quelque part sur cette plateforme.
  static bool get canRate => !Platform.isIOS || appStoreId != null;

  /// Le site et la politique de confidentialité, en français ou en anglais.
  static Uri website({required bool french}) => Uri.parse(
    'https://benjamingott.github.io/mybookmark/${french ? 'fr/' : ''}',
  );

  static Uri privacy({required bool french}) => Uri.parse(
    'https://benjamingott.github.io/mybookmark/${french ? 'fr/' : ''}privacy/',
  );

  static Uri feedbackEmail({required String subject}) => Uri(
    scheme: 'mailto',
    path: contactEmail,
    // `queryParameters` coderait les espaces en « + », que les messageries
    // affichent tels quels.
    query: 'subject=${Uri.encodeComponent(subject)}',
  );
}
