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
