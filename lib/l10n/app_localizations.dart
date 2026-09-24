import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon marque-page'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get confirm;

  /// No description provided for @apply.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get apply;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @clear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get clear;

  /// No description provided for @share.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get share;

  /// No description provided for @unknownAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Auteur inconnu'**
  String get unknownAuthor;

  /// No description provided for @errorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ça n\'a pas marché'**
  String get errorTitle;

  /// No description provided for @navLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque'**
  String get navLibrary;

  /// No description provided for @navSearch.
  ///
  /// In fr, this message translates to:
  /// **'Chercher'**
  String get navSearch;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get navSettings;

  /// No description provided for @percent.
  ///
  /// In fr, this message translates to:
  /// **'{percent} %'**
  String percent(int percent);

  /// No description provided for @pageCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String pageCount(int count);

  /// No description provided for @pageCountUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de pages inconnu'**
  String get pageCountUnknown;

  /// No description provided for @shelfToRead.
  ///
  /// In fr, this message translates to:
  /// **'À lire'**
  String get shelfToRead;

  /// No description provided for @shelfReading.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get shelfReading;

  /// No description provided for @shelfRead.
  ///
  /// In fr, this message translates to:
  /// **'Lu'**
  String get shelfRead;

  /// No description provided for @shelfAdded.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté à « {shelf} »'**
  String shelfAdded(String shelf);

  /// No description provided for @currentShelf.
  ///
  /// In fr, this message translates to:
  /// **'Étagère actuelle'**
  String get currentShelf;

  /// No description provided for @progressPageUnknownTotal.
  ///
  /// In fr, this message translates to:
  /// **'Page {page} · nombre de pages inconnu'**
  String progressPageUnknownTotal(int page);

  /// No description provided for @progressPageOf.
  ///
  /// In fr, this message translates to:
  /// **'Page {page} sur {total} · {percent} %'**
  String progressPageOf(int page, int total, int percent);

  /// No description provided for @notRatedYet.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore noté'**
  String get notRatedYet;

  /// No description provided for @ratedOutOf.
  ///
  /// In fr, this message translates to:
  /// **'Noté {rating} sur {max}'**
  String ratedOutOf(int rating, int max);

  /// No description provided for @starCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 étoile} other{{count} étoiles}}'**
  String starCount(int count);

  /// No description provided for @libraryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ma bibliothèque'**
  String get libraryTitle;

  /// No description provided for @addBookManually.
  ///
  /// In fr, this message translates to:
  /// **'Saisir un livre'**
  String get addBookManually;

  /// No description provided for @addBookManuallyTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un livre que la recherche ne trouve pas'**
  String get addBookManuallyTooltip;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get filterAll;

  /// No description provided for @sortTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get sortTooltip;

  /// No description provided for @sortTitle.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get sortTitle;

  /// No description provided for @sortAuthor.
  ///
  /// In fr, this message translates to:
  /// **'Auteur'**
  String get sortAuthor;

  /// No description provided for @sortAddedAt.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'ajout'**
  String get sortAddedAt;

  /// No description provided for @sortRating.
  ///
  /// In fr, this message translates to:
  /// **'Note'**
  String get sortRating;

  /// No description provided for @readNotRated.
  ///
  /// In fr, this message translates to:
  /// **'Lu · pas encore noté'**
  String get readNotRated;

  /// No description provided for @toReadWithPages.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{À lire · 1 page} other{À lire · {count} pages}}'**
  String toReadWithPages(int count);

  /// No description provided for @emptyShelfTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rien dans « {shelf} »'**
  String emptyShelfTitle(String shelf);

  /// No description provided for @emptyShelfMessage.
  ///
  /// In fr, this message translates to:
  /// **'Aucun livre sur cette étagère pour le moment.'**
  String get emptyShelfMessage;

  /// No description provided for @emptyLibraryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre bibliothèque est vide'**
  String get emptyLibraryTitle;

  /// No description provided for @emptyLibraryMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cherchez un livre pour commencer à suivre vos lectures.'**
  String get emptyLibraryMessage;

  /// No description provided for @searchABook.
  ///
  /// In fr, this message translates to:
  /// **'Chercher un livre'**
  String get searchABook;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Titre ou auteur'**
  String get searchHint;

  /// No description provided for @searchPromptTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cherchez un livre'**
  String get searchPromptTitle;

  /// No description provided for @searchPromptMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tapez un titre ou un nom d\'auteur.'**
  String get searchPromptMessage;

  /// No description provided for @searchMinChars.
  ///
  /// In fr, this message translates to:
  /// **'Encore {count} caractères minimum.'**
  String searchMinChars(int count);

  /// No description provided for @noResultsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get noResultsTitle;

  /// No description provided for @noResultsMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ni Open Library ni Apple Books ne connaissent ce titre. Vérifiez l\'orthographe, ou saisissez le livre vous-même.'**
  String get noResultsMessage;

  /// No description provided for @addBookByHand.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le livre à la main'**
  String get addBookByHand;

  /// No description provided for @alreadyInLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Déjà dans votre bibliothèque'**
  String get alreadyInLibrary;

  /// No description provided for @bookDeletedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Livre supprimé'**
  String get bookDeletedTitle;

  /// No description provided for @bookDeletedMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ce livre n\'est plus dans votre bibliothèque.'**
  String get bookDeletedMessage;

  /// No description provided for @actionsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get actionsTooltip;

  /// No description provided for @shareProgress.
  ///
  /// In fr, this message translates to:
  /// **'Partager ma progression'**
  String get shareProgress;

  /// No description provided for @editBookDetails.
  ///
  /// In fr, this message translates to:
  /// **'Corriger les informations'**
  String get editBookDetails;

  /// No description provided for @startReread.
  ///
  /// In fr, this message translates to:
  /// **'Commencer une relecture'**
  String get startReread;

  /// No description provided for @removeFromLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer de ma bibliothèque'**
  String get removeFromLibrary;

  /// No description provided for @rereadStarted.
  ///
  /// In fr, this message translates to:
  /// **'Relecture commencée. La lecture précédente reste dans l\'historique.'**
  String get rereadStarted;

  /// No description provided for @deleteBookTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce livre ?'**
  String get deleteBookTitle;

  /// No description provided for @deleteBookMessage.
  ///
  /// In fr, this message translates to:
  /// **'« {title} » sera retiré de votre bibliothèque, avec sa note, son avis et tout son historique de lecture. C\'est définitif.'**
  String deleteBookMessage(String title);

  /// No description provided for @enteredManually.
  ///
  /// In fr, this message translates to:
  /// **'Saisi à la main'**
  String get enteredManually;

  /// No description provided for @readingDates.
  ///
  /// In fr, this message translates to:
  /// **'Dates de lecture'**
  String get readingDates;

  /// No description provided for @startedOn.
  ///
  /// In fr, this message translates to:
  /// **'Commencé le'**
  String get startedOn;

  /// No description provided for @finishedOn.
  ///
  /// In fr, this message translates to:
  /// **'Terminé le'**
  String get finishedOn;

  /// No description provided for @readingStart.
  ///
  /// In fr, this message translates to:
  /// **'Début de lecture'**
  String get readingStart;

  /// No description provided for @readingEnd.
  ///
  /// In fr, this message translates to:
  /// **'Fin de lecture'**
  String get readingEnd;

  /// No description provided for @endBeforeStart.
  ///
  /// In fr, this message translates to:
  /// **'La date de fin ne peut pas précéder la date de début.'**
  String get endBeforeStart;

  /// No description provided for @dateNotSet.
  ///
  /// In fr, this message translates to:
  /// **'Pas renseignée'**
  String get dateNotSet;

  /// No description provided for @clearDate.
  ///
  /// In fr, this message translates to:
  /// **'Effacer la date'**
  String get clearDate;

  /// No description provided for @longDate.
  ///
  /// In fr, this message translates to:
  /// **'{date}'**
  String longDate(DateTime date);

  /// No description provided for @historyFrom.
  ///
  /// In fr, this message translates to:
  /// **'du {date}'**
  String historyFrom(DateTime date);

  /// No description provided for @historyTo.
  ///
  /// In fr, this message translates to:
  /// **'au {date}'**
  String historyTo(DateTime date);

  /// No description provided for @datesNotSet.
  ///
  /// In fr, this message translates to:
  /// **'Dates non renseignées'**
  String get datesNotSet;

  /// No description provided for @previousReadings.
  ///
  /// In fr, this message translates to:
  /// **'Lectures précédentes ({count})'**
  String previousReadings(int count);

  /// No description provided for @summary.
  ///
  /// In fr, this message translates to:
  /// **'Résumé'**
  String get summary;

  /// No description provided for @noSummaryManual.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résumé saisi. Vous pouvez en ajouter un en corrigeant les informations du livre.'**
  String get noSummaryManual;

  /// No description provided for @noSummaryOnline.
  ///
  /// In fr, this message translates to:
  /// **'Open Library ne fournit pas de résumé pour ce livre.'**
  String get noSummaryOnline;

  /// No description provided for @showLess.
  ///
  /// In fr, this message translates to:
  /// **'Replier'**
  String get showLess;

  /// No description provided for @readMore.
  ///
  /// In fr, this message translates to:
  /// **'Tout lire'**
  String get readMore;

  /// No description provided for @progressTitle.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get progressTitle;

  /// No description provided for @currentPage.
  ///
  /// In fr, this message translates to:
  /// **'Page en cours'**
  String get currentPage;

  /// No description provided for @ofPages.
  ///
  /// In fr, this message translates to:
  /// **'sur {count}'**
  String ofPages(int count);

  /// No description provided for @lastPage.
  ///
  /// In fr, this message translates to:
  /// **'Dernière page'**
  String get lastPage;

  /// No description provided for @pageClamped.
  ///
  /// In fr, this message translates to:
  /// **'Ce livre fait {count} pages : la progression a été enregistrée à la page {page}.'**
  String pageClamped(int count, int page);

  /// No description provided for @ratingAndReview.
  ///
  /// In fr, this message translates to:
  /// **'Ma note et mon avis'**
  String get ratingAndReview;

  /// No description provided for @myReview.
  ///
  /// In fr, this message translates to:
  /// **'Mon avis'**
  String get myReview;

  /// No description provided for @reviewHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce que vous en avez pensé, pour vous en souvenir.'**
  String get reviewHint;

  /// No description provided for @saveReview.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer l\'avis'**
  String get saveReview;

  /// No description provided for @reviewSaved.
  ///
  /// In fr, this message translates to:
  /// **'Avis enregistré'**
  String get reviewSaved;

  /// No description provided for @appearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Comme le système'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Langue du téléphone'**
  String get languageSystem;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In fr, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageGerman.
  ///
  /// In fr, this message translates to:
  /// **'Deutsch'**
  String get languageGerman;

  /// No description provided for @languageItalian.
  ///
  /// In fr, this message translates to:
  /// **'Italiano'**
  String get languageItalian;

  /// No description provided for @languagePortuguese.
  ///
  /// In fr, this message translates to:
  /// **'Português'**
  String get languagePortuguese;

  /// No description provided for @myData.
  ///
  /// In fr, this message translates to:
  /// **'Mes données'**
  String get myData;

  /// No description provided for @dataExplanation.
  ///
  /// In fr, this message translates to:
  /// **'Tout est enregistré sur ce téléphone, sans compte ni serveur. L\'export est le seul moyen de garder une copie de votre bibliothèque ou de la transférer sur un autre appareil.'**
  String get dataExplanation;

  /// No description provided for @exportLibrary.
  ///
  /// In fr, this message translates to:
  /// **'Exporter ma bibliothèque'**
  String get exportLibrary;

  /// No description provided for @exportSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Enregistre un fichier JSON'**
  String get exportSubtitle;

  /// No description provided for @importBackup.
  ///
  /// In fr, this message translates to:
  /// **'Importer une sauvegarde'**
  String get importBackup;

  /// No description provided for @importSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Depuis un fichier JSON'**
  String get importSubtitle;

  /// No description provided for @exportedTo.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque exportée dans {name}'**
  String exportedTo(String name);

  /// No description provided for @importTitle.
  ///
  /// In fr, this message translates to:
  /// **'Importer cette sauvegarde ?'**
  String get importTitle;

  /// No description provided for @importFileDated.
  ///
  /// In fr, this message translates to:
  /// **'Fichier du {date} :'**
  String importFileDated(DateTime date);

  /// No description provided for @importBookCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucun livre} =1{1 livre} other{{count} livres}}'**
  String importBookCount(int count);

  /// No description provided for @importReadingCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune lecture} =1{1 lecture} other{{count} lectures}}'**
  String importReadingCount(int count);

  /// No description provided for @importAlreadyPresent.
  ///
  /// In fr, this message translates to:
  /// **'{present, plural, =0{Aucun de ces livres n\'est déjà dans votre bibliothèque} =1{1 de ces livres est déjà dans votre bibliothèque} other{{present} de ces livres sont déjà dans votre bibliothèque}}, qui en compte {library}.'**
  String importAlreadyPresent(int present, int library);

  /// No description provided for @importChoice.
  ///
  /// In fr, this message translates to:
  /// **'{missing, plural, =0{Fusionner n\'ajoute aucun livre} =1{Fusionner ajoute le livre absent} other{Fusionner ajoute les {missing} livres absents}} et ne touche à rien d\'autre. Remplacer efface toute votre bibliothèque actuelle.'**
  String importChoice(int missing);

  /// No description provided for @replaceAll.
  ///
  /// In fr, this message translates to:
  /// **'Remplacer tout'**
  String get replaceAll;

  /// No description provided for @merge.
  ///
  /// In fr, this message translates to:
  /// **'Fusionner'**
  String get merge;

  /// No description provided for @libraryReplaced.
  ///
  /// In fr, this message translates to:
  /// **'Bibliothèque remplacée'**
  String get libraryReplaced;

  /// No description provided for @backupMerged.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde fusionnée'**
  String get backupMerged;

  /// No description provided for @booksImported.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucun livre importé} =1{1 livre importé} other{{count} livres importés}}'**
  String booksImported(int count);

  /// No description provided for @booksSkipped.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 déjà présent} other{{count} déjà présents}}'**
  String booksSkipped(int count);

  /// No description provided for @addBookTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un livre'**
  String get addBookTitle;

  /// No description provided for @titleRequiredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Titre *'**
  String get titleRequiredLabel;

  /// No description provided for @requiredHint.
  ///
  /// In fr, this message translates to:
  /// **'Obligatoire'**
  String get requiredHint;

  /// No description provided for @titleRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le titre est obligatoire.'**
  String get titleRequired;

  /// No description provided for @authorLabel.
  ///
  /// In fr, this message translates to:
  /// **'Auteur'**
  String get authorLabel;

  /// No description provided for @pageCountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de pages'**
  String get pageCountLabel;

  /// No description provided for @pageCountHelper.
  ///
  /// In fr, this message translates to:
  /// **'Laissez vide si vous ne le connaissez pas.'**
  String get pageCountHelper;

  /// No description provided for @yearLabel.
  ///
  /// In fr, this message translates to:
  /// **'Année de parution'**
  String get yearLabel;

  /// No description provided for @shelfLabel.
  ///
  /// In fr, this message translates to:
  /// **'Étagère'**
  String get shelfLabel;

  /// No description provided for @pageCountInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez un nombre de pages supérieur à zéro.'**
  String get pageCountInvalid;

  /// No description provided for @yearInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez une année entre 1 et {max}.'**
  String yearInvalid(int max);

  /// No description provided for @detailsUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Informations mises à jour'**
  String get detailsUpdated;

  /// No description provided for @bookGone.
  ///
  /// In fr, this message translates to:
  /// **'Ce livre n\'existe plus.'**
  String get bookGone;

  /// No description provided for @searchOnline.
  ///
  /// In fr, this message translates to:
  /// **'Chercher en ligne'**
  String get searchOnline;

  /// No description provided for @fromGallery.
  ///
  /// In fr, this message translates to:
  /// **'Depuis la galerie'**
  String get fromGallery;

  /// No description provided for @removeCover.
  ///
  /// In fr, this message translates to:
  /// **'Retirer la couverture'**
  String get removeCover;

  /// No description provided for @searchCover.
  ///
  /// In fr, this message translates to:
  /// **'Chercher une couverture'**
  String get searchCover;

  /// No description provided for @searchFailed.
  ///
  /// In fr, this message translates to:
  /// **'La recherche a échoué.'**
  String get searchFailed;

  /// No description provided for @noCoverFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune couverture trouvée. Essayez un autre titre.'**
  String get noCoverFound;

  /// No description provided for @myColor.
  ///
  /// In fr, this message translates to:
  /// **'Ma couleur'**
  String get myColor;

  /// No description provided for @myGradient.
  ///
  /// In fr, this message translates to:
  /// **'Mon dégradé'**
  String get myGradient;

  /// No description provided for @textPreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu du texte'**
  String get textPreview;

  /// No description provided for @gradientTop.
  ///
  /// In fr, this message translates to:
  /// **'Haut'**
  String get gradientTop;

  /// No description provided for @gradientBottom.
  ///
  /// In fr, this message translates to:
  /// **'Bas'**
  String get gradientBottom;

  /// No description provided for @intensity.
  ///
  /// In fr, this message translates to:
  /// **'Intensité'**
  String get intensity;

  /// No description provided for @lightness.
  ///
  /// In fr, this message translates to:
  /// **'Clarté'**
  String get lightness;

  /// No description provided for @hue.
  ///
  /// In fr, this message translates to:
  /// **'Teinte'**
  String get hue;

  /// No description provided for @sliderValue.
  ///
  /// In fr, this message translates to:
  /// **'{label} {value} %'**
  String sliderValue(String label, int value);

  /// No description provided for @backgroundAuto.
  ///
  /// In fr, this message translates to:
  /// **'Automatique'**
  String get backgroundAuto;

  /// No description provided for @backgroundDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get backgroundDark;

  /// No description provided for @backgroundLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get backgroundLight;

  /// No description provided for @backgroundVivid.
  ///
  /// In fr, this message translates to:
  /// **'Vif'**
  String get backgroundVivid;

  /// No description provided for @backgroundNight.
  ///
  /// In fr, this message translates to:
  /// **'Nuit'**
  String get backgroundNight;

  /// No description provided for @backgroundPaper.
  ///
  /// In fr, this message translates to:
  /// **'Papier'**
  String get backgroundPaper;

  /// No description provided for @formatCompact.
  ///
  /// In fr, this message translates to:
  /// **'Bloc'**
  String get formatCompact;

  /// No description provided for @formatStory.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get formatStory;

  /// No description provided for @cardKickerReading.
  ///
  /// In fr, this message translates to:
  /// **'EN COURS DE LECTURE'**
  String get cardKickerReading;

  /// No description provided for @cardKickerRead.
  ///
  /// In fr, this message translates to:
  /// **'LECTURE TERMINÉE'**
  String get cardKickerRead;

  /// No description provided for @cardKickerToRead.
  ///
  /// In fr, this message translates to:
  /// **'DANS MA PILE'**
  String get cardKickerToRead;

  /// No description provided for @cardPage.
  ///
  /// In fr, this message translates to:
  /// **'page {page}'**
  String cardPage(int page);

  /// No description provided for @cardPageUnknown.
  ///
  /// In fr, this message translates to:
  /// **'nombre de pages inconnu'**
  String get cardPageUnknown;

  /// No description provided for @cardPageOf.
  ///
  /// In fr, this message translates to:
  /// **'page {page} sur {total}'**
  String cardPageOf(int page, int total);

  /// No description provided for @storyTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Partager en story Instagram'**
  String get storyTooltip;

  /// No description provided for @story.
  ///
  /// In fr, this message translates to:
  /// **'Story'**
  String get story;

  /// No description provided for @preparing.
  ///
  /// In fr, this message translates to:
  /// **'Préparation…'**
  String get preparing;

  /// No description provided for @saveToGallery.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer dans la galerie'**
  String get saveToGallery;

  /// No description provided for @imageSaved.
  ///
  /// In fr, this message translates to:
  /// **'Image enregistrée dans la galerie.'**
  String get imageSaved;

  /// No description provided for @imageNotReady.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de préparer l\'image.'**
  String get imageNotReady;

  /// No description provided for @welcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get welcomeTitle;

  /// No description provided for @welcomeChooseLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez votre langue'**
  String get welcomeChooseLanguage;

  /// No description provided for @welcomeHint.
  ///
  /// In fr, this message translates to:
  /// **'Vous pourrez la changer à tout moment dans les réglages.'**
  String get welcomeHint;

  /// No description provided for @continueButton.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueButton;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion. Vérifiez votre réseau et réessayez.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In fr, this message translates to:
  /// **'La recherche met trop de temps à répondre.'**
  String get errorTimeout;

  /// No description provided for @errorServer.
  ///
  /// In fr, this message translates to:
  /// **'Le service de livres a renvoyé une erreur. Réessayez plus tard.'**
  String get errorServer;

  /// No description provided for @errorMalformedResponse.
  ///
  /// In fr, this message translates to:
  /// **'Réponse illisible du service de livres.'**
  String get errorMalformedResponse;

  /// No description provided for @errorCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Requête annulée.'**
  String get errorCancelled;

  /// No description provided for @errorDuplicateBook.
  ///
  /// In fr, this message translates to:
  /// **'Ce livre est déjà dans votre bibliothèque.'**
  String get errorDuplicateBook;

  /// No description provided for @errorSaveFailed.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement impossible. Vérifiez la saisie.'**
  String get errorSaveFailed;

  /// No description provided for @errorBookReadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du livre impossible.'**
  String get errorBookReadFailed;

  /// No description provided for @errorLibraryReadFailed.
  ///
  /// In fr, this message translates to:
  /// **'Lecture de la bibliothèque impossible.'**
  String get errorLibraryReadFailed;

  /// No description provided for @errorMalformedBackup.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'est pas une sauvegarde valide.'**
  String get errorMalformedBackup;

  /// No description provided for @errorBackupUntitledBook.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier contient un livre sans titre.'**
  String get errorBackupUntitledBook;

  /// No description provided for @errorBackupUnknownShelf.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier contient une étagère inconnue.'**
  String get errorBackupUnknownShelf;

  /// No description provided for @errorBackupNotText.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n\'est pas du texte lisible.'**
  String get errorBackupNotText;

  /// No description provided for @errorBackupTooRecent.
  ///
  /// In fr, this message translates to:
  /// **'Cette sauvegarde vient d\'une version plus récente de l\'application. Mettez-la à jour pour la lire.'**
  String get errorBackupTooRecent;

  /// No description provided for @errorFileAccess.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'accéder au fichier choisi.'**
  String get errorFileAccess;

  /// No description provided for @errorFileRead.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du fichier impossible.'**
  String get errorFileRead;

  /// No description provided for @errorExportLocation.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement impossible à cet emplacement.'**
  String get errorExportLocation;

  /// No description provided for @errorImageRead.
  ///
  /// In fr, this message translates to:
  /// **'Lecture de l\'image impossible.'**
  String get errorImageRead;

  /// No description provided for @errorImageCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copie de l\'image impossible.'**
  String get errorImageCopy;

  /// No description provided for @errorImagePrepare.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de préparer l\'image à partager.'**
  String get errorImagePrepare;

  /// No description provided for @errorShareFailed.
  ///
  /// In fr, this message translates to:
  /// **'Le partage a échoué.'**
  String get errorShareFailed;

  /// No description provided for @errorInstagramFailed.
  ///
  /// In fr, this message translates to:
  /// **'Instagram n\'a pas pu être ouvert.'**
  String get errorInstagramFailed;

  /// No description provided for @errorPhotoAccess.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez l\'accès aux photos pour enregistrer l\'image.'**
  String get errorPhotoAccess;

  /// No description provided for @errorNotEnoughSpace.
  ///
  /// In fr, this message translates to:
  /// **'Plus assez de place sur le téléphone.'**
  String get errorNotEnoughSpace;

  /// No description provided for @errorImageSaveFailed.
  ///
  /// In fr, this message translates to:
  /// **'L\'image n\'a pas pu être enregistrée.'**
  String get errorImageSaveFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
