// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'MyBookmark';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get add => 'Hinzufügen';

  @override
  String get delete => 'Löschen';

  @override
  String get confirm => 'OK';

  @override
  String get apply => 'Übernehmen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get clear => 'Löschen';

  @override
  String get share => 'Teilen';

  @override
  String get unknownAuthor => 'Unbekannter Autor';

  @override
  String get errorTitle => 'Das hat nicht geklappt';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navSearch => 'Suchen';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String percent(int percent) {
    return '$percent %';
  }

  @override
  String pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Seiten',
      one: '1 Seite',
    );
    return '$_temp0';
  }

  @override
  String get pageCountUnknown => 'Seitenzahl unbekannt';

  @override
  String get shelfToRead => 'Zu lesen';

  @override
  String get shelfReading => 'Am Lesen';

  @override
  String get shelfRead => 'Gelesen';

  @override
  String shelfAdded(String shelf) {
    return 'Zu „$shelf“ hinzugefügt';
  }

  @override
  String get currentShelf => 'Aktuelles Regal';

  @override
  String progressPageUnknownTotal(int page) {
    return 'Seite $page · Seitenzahl unbekannt';
  }

  @override
  String progressPageOf(int page, int total, int percent) {
    return 'Seite $page von $total · $percent %';
  }

  @override
  String get notRatedYet => 'Noch nicht bewertet';

  @override
  String ratedOutOf(int rating, int max) {
    return 'Mit $rating von $max bewertet';
  }

  @override
  String starCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sterne',
      one: '1 Stern',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'Meine Bibliothek';

  @override
  String get addBookManually => 'Buch hinzufügen';

  @override
  String get addBookManuallyTooltip =>
      'Ein Buch hinzufügen, das die Suche nicht findet';

  @override
  String get filterAll => 'Alle';

  @override
  String get sortTooltip => 'Sortieren';

  @override
  String get sortTitle => 'Titel';

  @override
  String get sortAuthor => 'Autor';

  @override
  String get sortAddedAt => 'Hinzugefügt am';

  @override
  String get sortRating => 'Bewertung';

  @override
  String get readNotRated => 'Gelesen · noch nicht bewertet';

  @override
  String toReadWithPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zu lesen · $count Seiten',
      one: 'Zu lesen · 1 Seite',
    );
    return '$_temp0';
  }

  @override
  String emptyShelfTitle(String shelf) {
    return 'Nichts in „$shelf“';
  }

  @override
  String get emptyShelfMessage => 'Noch keine Bücher in diesem Regal.';

  @override
  String get emptyLibraryTitle => 'Deine Bibliothek ist leer';

  @override
  String get emptyLibraryMessage =>
      'Suche ein Buch, um deine Lektüre zu verfolgen.';

  @override
  String get searchABook => 'Buch suchen';

  @override
  String get searchHint => 'Titel oder Autor';

  @override
  String get searchPromptTitle => 'Suche ein Buch';

  @override
  String get searchPromptMessage =>
      'Gib einen Titel oder den Namen eines Autors ein.';

  @override
  String searchMinChars(int count) {
    return 'Mindestens $count Zeichen.';
  }

  @override
  String get noResultsTitle => 'Keine Ergebnisse';

  @override
  String get noResultsMessage =>
      'Weder Open Library noch Apple Books kennen diesen Titel. Prüfe die Schreibweise oder füge das Buch selbst hinzu.';

  @override
  String get addBookByHand => 'Buch von Hand hinzufügen';

  @override
  String get alreadyInLibrary => 'Schon in deiner Bibliothek';

  @override
  String get bookDeletedTitle => 'Buch gelöscht';

  @override
  String get bookDeletedMessage =>
      'Dieses Buch ist nicht mehr in deiner Bibliothek.';

  @override
  String get actionsTooltip => 'Aktionen';

  @override
  String get shareProgress => 'Meinen Fortschritt teilen';

  @override
  String get editBookDetails => 'Angaben bearbeiten';

  @override
  String get startReread => 'Erneut lesen';

  @override
  String get removeFromLibrary => 'Aus meiner Bibliothek entfernen';

  @override
  String get rereadStarted =>
      'Erneutes Lesen begonnen. Die vorherige Lektüre bleibt im Verlauf.';

  @override
  String get deleteBookTitle => 'Dieses Buch löschen?';

  @override
  String deleteBookMessage(String title) {
    return '„$title“ wird aus deiner Bibliothek entfernt, mit Bewertung, Rezension und gesamtem Leseverlauf. Das lässt sich nicht rückgängig machen.';
  }

  @override
  String get enteredManually => 'Von Hand hinzugefügt';

  @override
  String get readingDates => 'Lesedaten';

  @override
  String get startedOn => 'Begonnen am';

  @override
  String get finishedOn => 'Beendet am';

  @override
  String get readingStart => 'Lesebeginn';

  @override
  String get readingEnd => 'Leseende';

  @override
  String get endBeforeStart =>
      'Das Enddatum darf nicht vor dem Startdatum liegen.';

  @override
  String get dateNotSet => 'Nicht angegeben';

  @override
  String get clearDate => 'Datum löschen';

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

    return 'vom $dateString';
  }

  @override
  String historyTo(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'bis $dateString';
  }

  @override
  String get datesNotSet => 'Keine Daten';

  @override
  String previousReadings(int count) {
    return 'Frühere Lektüren ($count)';
  }

  @override
  String get summary => 'Zusammenfassung';

  @override
  String get noSummaryManual =>
      'Noch keine Zusammenfassung. Du kannst eine hinzufügen, indem du die Angaben des Buchs bearbeitest.';

  @override
  String get noSummaryOnline =>
      'Für dieses Buch ist keine Zusammenfassung verfügbar.';

  @override
  String get showLess => 'Weniger anzeigen';

  @override
  String get readMore => 'Weiterlesen';

  @override
  String get progressTitle => 'Fortschritt';

  @override
  String get currentPage => 'Aktuelle Seite';

  @override
  String ofPages(int count) {
    return 'von $count';
  }

  @override
  String get lastPage => 'Letzte Seite';

  @override
  String pageClamped(int count, int page) {
    return 'Dieses Buch hat $count Seiten: Der Fortschritt wurde auf Seite $page gespeichert.';
  }

  @override
  String get ratingAndReview => 'Meine Bewertung und Rezension';

  @override
  String get myReview => 'Meine Rezension';

  @override
  String get reviewHint => 'Was du davon hältst, damit du es nicht vergisst.';

  @override
  String get saveReview => 'Rezension speichern';

  @override
  String get reviewSaved => 'Rezension gespeichert';

  @override
  String get appearance => 'Darstellung';

  @override
  String get themeSystem => 'Wie das System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get language => 'Sprache';

  @override
  String get languageSystem => 'Sprache des Telefons';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get myData => 'Meine Daten';

  @override
  String get dataExplanation =>
      'Alles wird auf diesem Telefon gespeichert, ohne Konto und ohne Server. Der Export ist die einzige Möglichkeit, eine Kopie deiner Bibliothek aufzubewahren oder sie auf ein anderes Gerät zu übertragen.';

  @override
  String get exportLibrary => 'Meine Bibliothek exportieren';

  @override
  String get exportSubtitle => 'Speichert eine JSON-Datei';

  @override
  String get importBackup => 'Sicherung importieren';

  @override
  String get importSubtitle => 'Aus einer JSON-Datei';

  @override
  String get importGoodreads => 'Aus Goodreads importieren';

  @override
  String get importGoodreadsSubtitle =>
      'CSV-Datei, exportiert von goodreads.com (My Books → Import and export)';

  @override
  String get importGoodreadsFile => 'Goodreads-Export:';

  @override
  String get errorMalformedGoodreads =>
      'Diese Datei ist kein Goodreads-Export. Öffne auf goodreads.com My Books → Import and export → Export Library.';

  @override
  String exportedTo(String name) {
    return 'Bibliothek exportiert nach $name';
  }

  @override
  String get importTitle => 'Diese Sicherung importieren?';

  @override
  String importFileDated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Datei vom $dateString:';
  }

  @override
  String importBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher',
      one: '1 Buch',
      zero: 'kein Buch',
    );
    return '$_temp0';
  }

  @override
  String importReadingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lektüren',
      one: '1 Lektüre',
      zero: 'keine Lektüre',
    );
    return '$_temp0';
  }

  @override
  String importAlreadyPresent(int present, int library) {
    String _temp0 = intl.Intl.pluralLogic(
      present,
      locale: localeName,
      other: '$present dieser Bücher sind schon in deiner Bibliothek',
      one: '1 dieser Bücher ist schon in deiner Bibliothek',
      zero: 'Keines dieser Bücher ist schon in deiner Bibliothek',
    );
    return '$_temp0, die $library enthält.';
  }

  @override
  String importChoice(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Zusammenführen fügt die $missing fehlenden Bücher hinzu',
      one: 'Zusammenführen fügt das fehlende Buch hinzu',
      zero: 'Zusammenführen fügt kein Buch hinzu',
    );
    return '$_temp0 und ändert sonst nichts. Ersetzen löscht deine gesamte aktuelle Bibliothek.';
  }

  @override
  String get replaceAll => 'Alles ersetzen';

  @override
  String get merge => 'Zusammenführen';

  @override
  String get libraryReplaced => 'Bibliothek ersetzt';

  @override
  String get backupMerged => 'Sicherung zusammengeführt';

  @override
  String booksImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher importiert',
      one: '1 Buch importiert',
      zero: 'kein Buch importiert',
    );
    return '$_temp0';
  }

  @override
  String booksSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count schon vorhanden',
      one: '1 schon vorhanden',
    );
    return '$_temp0';
  }

  @override
  String get addBookTitle => 'Buch hinzufügen';

  @override
  String get titleRequiredLabel => 'Titel *';

  @override
  String get requiredHint => 'Pflichtfeld';

  @override
  String get titleRequired => 'Der Titel ist ein Pflichtfeld.';

  @override
  String get authorLabel => 'Autor';

  @override
  String get pageCountLabel => 'Seitenzahl';

  @override
  String get pageCountHelper => 'Leer lassen, wenn du sie nicht kennst.';

  @override
  String get yearLabel => 'Erscheinungsjahr';

  @override
  String get shelfLabel => 'Regal';

  @override
  String get pageCountInvalid => 'Gib eine Seitenzahl größer als null ein.';

  @override
  String yearInvalid(int max) {
    return 'Gib ein Jahr zwischen 1 und $max ein.';
  }

  @override
  String get detailsUpdated => 'Angaben aktualisiert';

  @override
  String get bookGone => 'Dieses Buch existiert nicht mehr.';

  @override
  String get searchOnline => 'Online suchen';

  @override
  String get fromGallery => 'Aus der Galerie';

  @override
  String get removeCover => 'Cover entfernen';

  @override
  String get searchCover => 'Cover suchen';

  @override
  String get searchFailed => 'Die Suche ist fehlgeschlagen.';

  @override
  String get noCoverFound =>
      'Kein Cover gefunden. Versuche einen anderen Titel.';

  @override
  String get myColor => 'Meine Farbe';

  @override
  String get myGradient => 'Mein Farbverlauf';

  @override
  String get textPreview => 'Textvorschau';

  @override
  String get gradientTop => 'Oben';

  @override
  String get gradientBottom => 'Unten';

  @override
  String get intensity => 'Intensität';

  @override
  String get lightness => 'Helligkeit';

  @override
  String get hue => 'Farbton';

  @override
  String sliderValue(String label, int value) {
    return '$label $value %';
  }

  @override
  String get backgroundAuto => 'Automatisch';

  @override
  String get backgroundDark => 'Dunkel';

  @override
  String get backgroundLight => 'Hell';

  @override
  String get backgroundVivid => 'Kräftig';

  @override
  String get backgroundNight => 'Nacht';

  @override
  String get backgroundPaper => 'Papier';

  @override
  String get formatCompact => 'Karte';

  @override
  String get formatStory => 'Story';

  @override
  String get cardKickerReading => 'ICH LESE GERADE';

  @override
  String get cardKickerRead => 'AUSGELESEN';

  @override
  String get cardKickerToRead => 'AUF MEINEM STAPEL';

  @override
  String cardPage(int page) {
    return 'Seite $page';
  }

  @override
  String get cardPageUnknown => 'Seitenzahl unbekannt';

  @override
  String cardPageOf(int page, int total) {
    return 'Seite $page von $total';
  }

  @override
  String get storyTooltip => 'In einer Instagram-Story teilen';

  @override
  String get story => 'Story';

  @override
  String get preparing => 'Wird vorbereitet…';

  @override
  String get saveToGallery => 'In der Galerie speichern';

  @override
  String get imageSaved => 'Bild in der Galerie gespeichert.';

  @override
  String get imageNotReady => 'Das Bild konnte nicht vorbereitet werden.';

  @override
  String get welcomeTitle => 'Willkommen';

  @override
  String get welcomeChooseLanguage => 'Wähle deine Sprache';

  @override
  String get welcomeHint =>
      'Du kannst sie jederzeit in den Einstellungen ändern.';

  @override
  String get continueButton => 'Weiter';

  @override
  String get errorNetwork =>
      'Keine Verbindung. Prüfe dein Netzwerk und versuche es erneut.';

  @override
  String get errorTimeout => 'Die Suche braucht zu lange.';

  @override
  String get errorServer =>
      'Der Buchdienst hat einen Fehler gemeldet. Versuche es später erneut.';

  @override
  String get errorMalformedResponse => 'Unlesbare Antwort des Buchdienstes.';

  @override
  String get errorCancelled => 'Anfrage abgebrochen.';

  @override
  String get errorDuplicateBook =>
      'Dieses Buch ist schon in deiner Bibliothek.';

  @override
  String get errorSaveFailed =>
      'Speichern nicht möglich. Prüfe deine Eingaben.';

  @override
  String get errorBookReadFailed => 'Das Buch konnte nicht geladen werden.';

  @override
  String get errorLibraryReadFailed =>
      'Die Bibliothek konnte nicht geladen werden.';

  @override
  String get errorMalformedBackup => 'Diese Datei ist keine gültige Sicherung.';

  @override
  String get errorBackupUntitledBook =>
      'Diese Datei enthält ein Buch ohne Titel.';

  @override
  String get errorBackupUnknownShelf =>
      'Diese Datei enthält ein unbekanntes Regal.';

  @override
  String get errorBackupNotText => 'Diese Datei ist kein lesbarer Text.';

  @override
  String get errorBackupTooRecent =>
      'Diese Sicherung stammt aus einer neueren Version der App. Aktualisiere die App, um sie zu lesen.';

  @override
  String get errorFileAccess => 'Kein Zugriff auf die gewählte Datei.';

  @override
  String get errorFileRead => 'Die Datei konnte nicht gelesen werden.';

  @override
  String get errorExportLocation =>
      'An diesem Ort kann nicht gespeichert werden.';

  @override
  String get errorImageRead => 'Das Bild konnte nicht gelesen werden.';

  @override
  String get errorImageCopy => 'Das Bild konnte nicht kopiert werden.';

  @override
  String get errorImagePrepare =>
      'Das Bild konnte nicht zum Teilen vorbereitet werden.';

  @override
  String get errorShareFailed => 'Teilen fehlgeschlagen.';

  @override
  String get errorInstagramFailed => 'Instagram konnte nicht geöffnet werden.';

  @override
  String get errorPhotoAccess =>
      'Erlaube den Zugriff auf Fotos, um das Bild zu speichern.';

  @override
  String get errorNotEnoughSpace =>
      'Nicht genug Speicherplatz auf dem Telefon.';

  @override
  String get errorImageSaveFailed =>
      'Das Bild konnte nicht gespeichert werden.';
}
