// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Mon marque-page';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get add => 'Ajouter';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Valider';

  @override
  String get apply => 'Appliquer';

  @override
  String get retry => 'Réessayer';

  @override
  String get clear => 'Effacer';

  @override
  String get share => 'Partager';

  @override
  String get unknownAuthor => 'Auteur inconnu';

  @override
  String get errorTitle => 'Ça n\'a pas marché';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navSearch => 'Chercher';

  @override
  String get navSettings => 'Réglages';

  @override
  String percent(int percent) {
    return '$percent %';
  }

  @override
  String pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get pageCountUnknown => 'Nombre de pages inconnu';

  @override
  String get shelfToRead => 'À lire';

  @override
  String get shelfReading => 'En cours';

  @override
  String get shelfRead => 'Lu';

  @override
  String shelfAdded(String shelf) {
    return 'Ajouté à « $shelf »';
  }

  @override
  String get currentShelf => 'Étagère actuelle';

  @override
  String progressPageUnknownTotal(int page) {
    return 'Page $page · nombre de pages inconnu';
  }

  @override
  String progressPageOf(int page, int total, int percent) {
    return 'Page $page sur $total · $percent %';
  }

  @override
  String get notRatedYet => 'Pas encore noté';

  @override
  String ratedOutOf(int rating, int max) {
    return 'Noté $rating sur $max';
  }

  @override
  String starCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étoiles',
      one: '1 étoile',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'Ma bibliothèque';

  @override
  String get addBookManually => 'Saisir un livre';

  @override
  String get addBookManuallyTooltip =>
      'Ajouter un livre que la recherche ne trouve pas';

  @override
  String get filterAll => 'Toutes';

  @override
  String get sortTooltip => 'Trier';

  @override
  String get sortTitle => 'Titre';

  @override
  String get sortAuthor => 'Auteur';

  @override
  String get sortAddedAt => 'Date d\'ajout';

  @override
  String get sortRating => 'Note';

  @override
  String get readNotRated => 'Lu · pas encore noté';

  @override
  String toReadWithPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'À lire · $count pages',
      one: 'À lire · 1 page',
    );
    return '$_temp0';
  }

  @override
  String emptyShelfTitle(String shelf) {
    return 'Rien dans « $shelf »';
  }

  @override
  String get emptyShelfMessage =>
      'Aucun livre sur cette étagère pour le moment.';

  @override
  String get emptyLibraryTitle => 'Votre bibliothèque est vide';

  @override
  String get emptyLibraryMessage =>
      'Cherchez un livre pour commencer à suivre vos lectures.';

  @override
  String get searchABook => 'Chercher un livre';

  @override
  String get searchHint => 'Titre ou auteur';

  @override
  String get searchPromptTitle => 'Cherchez un livre';

  @override
  String get searchPromptMessage => 'Tapez un titre ou un nom d\'auteur.';

  @override
  String searchMinChars(int count) {
    return 'Encore $count caractères minimum.';
  }

  @override
  String get noResultsTitle => 'Aucun résultat';

  @override
  String get noResultsMessage =>
      'Ni Open Library ni Apple Books ne connaissent ce titre. Vérifiez l\'orthographe, ou saisissez le livre vous-même.';

  @override
  String get addBookByHand => 'Saisir le livre à la main';

  @override
  String get alreadyInLibrary => 'Déjà dans votre bibliothèque';

  @override
  String get bookDeletedTitle => 'Livre supprimé';

  @override
  String get bookDeletedMessage =>
      'Ce livre n\'est plus dans votre bibliothèque.';

  @override
  String get actionsTooltip => 'Actions';

  @override
  String get shareProgress => 'Partager ma progression';

  @override
  String get editBookDetails => 'Corriger les informations';

  @override
  String get startReread => 'Commencer une relecture';

  @override
  String get removeFromLibrary => 'Supprimer de ma bibliothèque';

  @override
  String get rereadStarted =>
      'Relecture commencée. La lecture précédente reste dans l\'historique.';

  @override
  String get deleteBookTitle => 'Supprimer ce livre ?';

  @override
  String deleteBookMessage(String title) {
    return '« $title » sera retiré de votre bibliothèque, avec sa note, son avis et tout son historique de lecture. C\'est définitif.';
  }

  @override
  String get enteredManually => 'Saisi à la main';

  @override
  String get readingDates => 'Dates de lecture';

  @override
  String get startedOn => 'Commencé le';

  @override
  String get finishedOn => 'Terminé le';

  @override
  String get readingStart => 'Début de lecture';

  @override
  String get readingEnd => 'Fin de lecture';

  @override
  String get endBeforeStart =>
      'La date de fin ne peut pas précéder la date de début.';

  @override
  String get dateNotSet => 'Pas renseignée';

  @override
  String get clearDate => 'Effacer la date';

  @override
  String longDate(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String historyFrom(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'du $dateString';
  }

  @override
  String historyTo(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'au $dateString';
  }

  @override
  String get datesNotSet => 'Dates non renseignées';

  @override
  String previousReadings(int count) {
    return 'Lectures précédentes ($count)';
  }

  @override
  String get summary => 'Résumé';

  @override
  String get noSummaryManual =>
      'Aucun résumé saisi. Vous pouvez en ajouter un en corrigeant les informations du livre.';

  @override
  String get noSummaryOnline =>
      'Open Library ne fournit pas de résumé pour ce livre.';

  @override
  String get showLess => 'Replier';

  @override
  String get readMore => 'Tout lire';

  @override
  String get progressTitle => 'Progression';

  @override
  String get currentPage => 'Page en cours';

  @override
  String ofPages(int count) {
    return 'sur $count';
  }

  @override
  String get lastPage => 'Dernière page';

  @override
  String pageClamped(int count, int page) {
    return 'Ce livre fait $count pages : la progression a été enregistrée à la page $page.';
  }

  @override
  String get ratingAndReview => 'Ma note et mon avis';

  @override
  String get myReview => 'Mon avis';

  @override
  String get reviewHint => 'Ce que vous en avez pensé, pour vous en souvenir.';

  @override
  String get saveReview => 'Enregistrer l\'avis';

  @override
  String get reviewSaved => 'Avis enregistré';

  @override
  String get appearance => 'Apparence';

  @override
  String get themeSystem => 'Comme le système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Langue du téléphone';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get myData => 'Mes données';

  @override
  String get dataExplanation =>
      'Tout est enregistré sur ce téléphone, sans compte ni serveur. L\'export est le seul moyen de garder une copie de votre bibliothèque ou de la transférer sur un autre appareil.';

  @override
  String get exportLibrary => 'Exporter ma bibliothèque';

  @override
  String get exportSubtitle => 'Enregistre un fichier JSON';

  @override
  String get importBackup => 'Importer une sauvegarde';

  @override
  String get importSubtitle => 'Depuis un fichier JSON';

  @override
  String exportedTo(String name) {
    return 'Bibliothèque exportée dans $name';
  }

  @override
  String get importTitle => 'Importer cette sauvegarde ?';

  @override
  String importFileDated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Fichier du $dateString :';
  }

  @override
  String importBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres',
      one: '1 livre',
      zero: 'aucun livre',
    );
    return '$_temp0';
  }

  @override
  String importReadingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lectures',
      one: '1 lecture',
      zero: 'aucune lecture',
    );
    return '$_temp0';
  }

  @override
  String importAlreadyPresent(int present, int library) {
    String _temp0 = intl.Intl.pluralLogic(
      present,
      locale: localeName,
      other: '$present de ces livres sont déjà dans votre bibliothèque',
      one: '1 de ces livres est déjà dans votre bibliothèque',
      zero: 'Aucun de ces livres n\'est déjà dans votre bibliothèque',
    );
    return '$_temp0, qui en compte $library.';
  }

  @override
  String importChoice(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Fusionner ajoute les $missing livres absents',
      one: 'Fusionner ajoute le livre absent',
      zero: 'Fusionner n\'ajoute aucun livre',
    );
    return '$_temp0 et ne touche à rien d\'autre. Remplacer efface toute votre bibliothèque actuelle.';
  }

  @override
  String get replaceAll => 'Remplacer tout';

  @override
  String get merge => 'Fusionner';

  @override
  String get libraryReplaced => 'Bibliothèque remplacée';

  @override
  String get backupMerged => 'Sauvegarde fusionnée';

  @override
  String booksImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres importés',
      one: '1 livre importé',
      zero: 'aucun livre importé',
    );
    return '$_temp0';
  }

  @override
  String booksSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count déjà présents',
      one: '1 déjà présent',
    );
    return '$_temp0';
  }

  @override
  String get addBookTitle => 'Ajouter un livre';

  @override
  String get titleRequiredLabel => 'Titre *';

  @override
  String get requiredHint => 'Obligatoire';

  @override
  String get titleRequired => 'Le titre est obligatoire.';

  @override
  String get authorLabel => 'Auteur';

  @override
  String get pageCountLabel => 'Nombre de pages';

  @override
  String get pageCountHelper => 'Laissez vide si vous ne le connaissez pas.';

  @override
  String get yearLabel => 'Année de parution';

  @override
  String get shelfLabel => 'Étagère';

  @override
  String get pageCountInvalid =>
      'Indiquez un nombre de pages supérieur à zéro.';

  @override
  String yearInvalid(int max) {
    return 'Indiquez une année entre 1 et $max.';
  }

  @override
  String get detailsUpdated => 'Informations mises à jour';

  @override
  String get bookGone => 'Ce livre n\'existe plus.';

  @override
  String get searchOnline => 'Chercher en ligne';

  @override
  String get fromGallery => 'Depuis la galerie';

  @override
  String get removeCover => 'Retirer la couverture';

  @override
  String get searchCover => 'Chercher une couverture';

  @override
  String get searchFailed => 'La recherche a échoué.';

  @override
  String get noCoverFound =>
      'Aucune couverture trouvée. Essayez un autre titre.';

  @override
  String get myColor => 'Ma couleur';

  @override
  String get myGradient => 'Mon dégradé';

  @override
  String get textPreview => 'Aperçu du texte';

  @override
  String get gradientTop => 'Haut';

  @override
  String get gradientBottom => 'Bas';

  @override
  String get intensity => 'Intensité';

  @override
  String get lightness => 'Clarté';

  @override
  String get hue => 'Teinte';

  @override
  String sliderValue(String label, int value) {
    return '$label $value %';
  }

  @override
  String get backgroundAuto => 'Automatique';

  @override
  String get backgroundDark => 'Sombre';

  @override
  String get backgroundLight => 'Clair';

  @override
  String get backgroundVivid => 'Vif';

  @override
  String get backgroundNight => 'Nuit';

  @override
  String get backgroundPaper => 'Papier';

  @override
  String get formatCompact => 'Bloc';

  @override
  String get formatStory => 'Moyen';

  @override
  String get cardKickerReading => 'EN COURS DE LECTURE';

  @override
  String get cardKickerRead => 'LECTURE TERMINÉE';

  @override
  String get cardKickerToRead => 'DANS MA PILE';

  @override
  String cardPage(int page) {
    return 'page $page';
  }

  @override
  String get cardPageUnknown => 'nombre de pages inconnu';

  @override
  String cardPageOf(int page, int total) {
    return 'page $page sur $total';
  }

  @override
  String get storyTooltip => 'Partager en story Instagram';

  @override
  String get story => 'Story';

  @override
  String get preparing => 'Préparation…';

  @override
  String get saveToGallery => 'Enregistrer dans la galerie';

  @override
  String get imageSaved => 'Image enregistrée dans la galerie.';

  @override
  String get imageNotReady => 'Impossible de préparer l\'image.';

  @override
  String get welcomeTitle => 'Bienvenue';

  @override
  String get welcomeChooseLanguage => 'Choisissez votre langue';

  @override
  String get welcomeHint =>
      'Vous pourrez la changer à tout moment dans les réglages.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get errorNetwork =>
      'Pas de connexion. Vérifiez votre réseau et réessayez.';

  @override
  String get errorTimeout => 'La recherche met trop de temps à répondre.';

  @override
  String get errorServer =>
      'Le service de livres a renvoyé une erreur. Réessayez plus tard.';

  @override
  String get errorMalformedResponse =>
      'Réponse illisible du service de livres.';

  @override
  String get errorCancelled => 'Requête annulée.';

  @override
  String get errorDuplicateBook => 'Ce livre est déjà dans votre bibliothèque.';

  @override
  String get errorSaveFailed =>
      'Enregistrement impossible. Vérifiez la saisie.';

  @override
  String get errorBookReadFailed => 'Lecture du livre impossible.';

  @override
  String get errorLibraryReadFailed => 'Lecture de la bibliothèque impossible.';

  @override
  String get errorMalformedBackup =>
      'Ce fichier n\'est pas une sauvegarde valide.';

  @override
  String get errorBackupUntitledBook =>
      'Ce fichier contient un livre sans titre.';

  @override
  String get errorBackupUnknownShelf =>
      'Ce fichier contient une étagère inconnue.';

  @override
  String get errorBackupNotText => 'Ce fichier n\'est pas du texte lisible.';

  @override
  String get errorBackupTooRecent =>
      'Cette sauvegarde vient d\'une version plus récente de l\'application. Mettez-la à jour pour la lire.';

  @override
  String get errorFileAccess => 'Impossible d\'accéder au fichier choisi.';

  @override
  String get errorFileRead => 'Lecture du fichier impossible.';

  @override
  String get errorExportLocation =>
      'Enregistrement impossible à cet emplacement.';

  @override
  String get errorImageRead => 'Lecture de l\'image impossible.';

  @override
  String get errorImageCopy => 'Copie de l\'image impossible.';

  @override
  String get errorImagePrepare => 'Impossible de préparer l\'image à partager.';

  @override
  String get errorShareFailed => 'Le partage a échoué.';

  @override
  String get errorInstagramFailed => 'Instagram n\'a pas pu être ouvert.';

  @override
  String get errorPhotoAccess =>
      'Autorisez l\'accès aux photos pour enregistrer l\'image.';

  @override
  String get errorNotEnoughSpace => 'Plus assez de place sur le téléphone.';

  @override
  String get errorImageSaveFailed => 'L\'image n\'a pas pu être enregistrée.';
}
