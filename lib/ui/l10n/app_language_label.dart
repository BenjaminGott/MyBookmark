import '../../domain/models/app_language.dart';
import 'l10n.dart';

/// Nom de chaque choix de langue. Les langues sont écrites dans leur propre
/// langue, pour qu'on retrouve la sienne même dans une interface inconnue.
extension AppLanguageLabel on AppLanguage {
  String label(AppLocalizations l10n) => switch (this) {
    AppLanguage.system => l10n.languageSystem,
    AppLanguage.french => l10n.languageFrench,
    AppLanguage.english => l10n.languageEnglish,
  };
}
