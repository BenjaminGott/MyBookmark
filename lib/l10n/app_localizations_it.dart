// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'MyBookmark';

  @override
  String get cancel => 'Annulla';

  @override
  String get save => 'Salva';

  @override
  String get add => 'Aggiungi';

  @override
  String get delete => 'Elimina';

  @override
  String get confirm => 'OK';

  @override
  String get apply => 'Applica';

  @override
  String get retry => 'Riprova';

  @override
  String get clear => 'Cancella';

  @override
  String get share => 'Condividi';

  @override
  String get unknownAuthor => 'Autore sconosciuto';

  @override
  String get errorTitle => 'Qualcosa è andato storto';

  @override
  String get navLibrary => 'Libreria';

  @override
  String get navSearch => 'Cerca';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String percent(int percent) {
    return '$percent%';
  }

  @override
  String pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pagine',
      one: '1 pagina',
    );
    return '$_temp0';
  }

  @override
  String get pageCountUnknown => 'Numero di pagine sconosciuto';

  @override
  String get shelfToRead => 'Da leggere';

  @override
  String get shelfReading => 'In lettura';

  @override
  String get shelfRead => 'Letto';

  @override
  String shelfAdded(String shelf) {
    return 'Aggiunto a «$shelf»';
  }

  @override
  String get currentShelf => 'Scaffale attuale';

  @override
  String progressPageUnknownTotal(int page) {
    return 'Pagina $page · numero di pagine sconosciuto';
  }

  @override
  String progressPageOf(int page, int total, int percent) {
    return 'Pagina $page di $total · $percent%';
  }

  @override
  String get notRatedYet => 'Non ancora valutato';

  @override
  String ratedOutOf(int rating, int max) {
    return 'Valutato $rating su $max';
  }

  @override
  String starCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stelle',
      one: '1 stella',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'La mia libreria';

  @override
  String get addBookManually => 'Aggiungi un libro';

  @override
  String get addBookManuallyTooltip =>
      'Aggiungi un libro che la ricerca non trova';

  @override
  String get filterAll => 'Tutti';

  @override
  String get sortTooltip => 'Ordina';

  @override
  String get sortTitle => 'Titolo';

  @override
  String get sortAuthor => 'Autore';

  @override
  String get sortAddedAt => 'Data di aggiunta';

  @override
  String get sortRating => 'Valutazione';

  @override
  String get readNotRated => 'Letto · non ancora valutato';

  @override
  String toReadWithPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Da leggere · $count pagine',
      one: 'Da leggere · 1 pagina',
    );
    return '$_temp0';
  }

  @override
  String emptyShelfTitle(String shelf) {
    return 'Niente in «$shelf»';
  }

  @override
  String get emptyShelfMessage => 'Ancora nessun libro su questo scaffale.';

  @override
  String get emptyLibraryTitle => 'La tua libreria è vuota';

  @override
  String get emptyLibraryMessage =>
      'Cerca un libro per iniziare a seguire le tue letture.';

  @override
  String get searchABook => 'Cerca un libro';

  @override
  String get searchHint => 'Titolo o autore';

  @override
  String get searchPromptTitle => 'Cerca un libro';

  @override
  String get searchPromptMessage => 'Scrivi un titolo o il nome di un autore.';

  @override
  String searchMinChars(int count) {
    return 'Almeno $count caratteri.';
  }

  @override
  String get noResultsTitle => 'Nessun risultato';

  @override
  String get noResultsMessage =>
      'Né Open Library né Apple Books conoscono questo titolo. Controlla l\'ortografia o aggiungi il libro tu stesso.';

  @override
  String get addBookByHand => 'Aggiungi il libro a mano';

  @override
  String get alreadyInLibrary => 'Già nella tua libreria';

  @override
  String get bookDeletedTitle => 'Libro eliminato';

  @override
  String get bookDeletedMessage => 'Questo libro non è più nella tua libreria.';

  @override
  String get actionsTooltip => 'Azioni';

  @override
  String get shareProgress => 'Condividi i miei progressi';

  @override
  String get editBookDetails => 'Modifica le informazioni';

  @override
  String get startReread => 'Inizia una rilettura';

  @override
  String get removeFromLibrary => 'Rimuovi dalla mia libreria';

  @override
  String get rereadStarted =>
      'Rilettura iniziata. La lettura precedente resta nella cronologia.';

  @override
  String get deleteBookTitle => 'Eliminare questo libro?';

  @override
  String deleteBookMessage(String title) {
    return '«$title» verrà rimosso dalla tua libreria, insieme a valutazione, recensione e tutta la cronologia di lettura. L\'operazione è definitiva.';
  }

  @override
  String get enteredManually => 'Aggiunto a mano';

  @override
  String get readingDates => 'Date di lettura';

  @override
  String get startedOn => 'Iniziato il';

  @override
  String get finishedOn => 'Finito il';

  @override
  String get readingStart => 'Inizio lettura';

  @override
  String get readingEnd => 'Fine lettura';

  @override
  String get endBeforeStart =>
      'La data di fine non può precedere quella di inizio.';

  @override
  String get dateNotSet => 'Non indicata';

  @override
  String get clearDate => 'Cancella la data';

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

    return 'dal $dateString';
  }

  @override
  String historyTo(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'al $dateString';
  }

  @override
  String get datesNotSet => 'Nessuna data';

  @override
  String previousReadings(int count) {
    return 'Letture precedenti ($count)';
  }

  @override
  String get summary => 'Riassunto';

  @override
  String get noSummaryManual =>
      'Ancora nessun riassunto. Puoi aggiungerne uno modificando le informazioni del libro.';

  @override
  String get noSummaryOnline =>
      'Nessun riassunto disponibile per questo libro.';

  @override
  String get showLess => 'Mostra meno';

  @override
  String get readMore => 'Leggi tutto';

  @override
  String get progressTitle => 'Progressi';

  @override
  String get currentPage => 'Pagina attuale';

  @override
  String ofPages(int count) {
    return 'di $count';
  }

  @override
  String get lastPage => 'Ultima pagina';

  @override
  String pageClamped(int count, int page) {
    return 'Questo libro ha $count pagine: i progressi sono stati salvati alla pagina $page.';
  }

  @override
  String get ratingAndReview => 'La mia valutazione e recensione';

  @override
  String get myReview => 'La mia recensione';

  @override
  String get reviewHint => 'Cosa ne hai pensato, per ricordartelo.';

  @override
  String get saveReview => 'Salva la recensione';

  @override
  String get reviewSaved => 'Recensione salvata';

  @override
  String get appearance => 'Aspetto';

  @override
  String get themeSystem => 'Come il sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Lingua del telefono';

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
  String get myData => 'I miei dati';

  @override
  String get dataExplanation =>
      'Tutto è salvato su questo telefono, senza account né server. L\'esportazione è l\'unico modo per conservare una copia della tua libreria o trasferirla su un altro dispositivo.';

  @override
  String get exportLibrary => 'Esporta la mia libreria';

  @override
  String get exportSubtitle => 'Salva un file JSON';

  @override
  String get importBackup => 'Importa un backup';

  @override
  String get importSubtitle => 'Da un file JSON';

  @override
  String get importGoodreads => 'Importa da Goodreads';

  @override
  String get importGoodreadsSubtitle =>
      'File CSV esportato da goodreads.com (My Books → Import and export)';

  @override
  String get importGoodreadsFile => 'Esportazione Goodreads:';

  @override
  String get errorMalformedGoodreads =>
      'Questo file non è un\'esportazione di Goodreads. Su goodreads.com, apri My Books → Import and export → Export Library.';

  @override
  String exportedTo(String name) {
    return 'Libreria esportata in $name';
  }

  @override
  String get importTitle => 'Importare questo backup?';

  @override
  String importFileDated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'File del $dateString:';
  }

  @override
  String importBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libri',
      one: '1 libro',
      zero: 'nessun libro',
    );
    return '$_temp0';
  }

  @override
  String importReadingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count letture',
      one: '1 lettura',
      zero: 'nessuna lettura',
    );
    return '$_temp0';
  }

  @override
  String importAlreadyPresent(int present, int library) {
    String _temp0 = intl.Intl.pluralLogic(
      present,
      locale: localeName,
      other: '$present di questi libri sono già nella tua libreria',
      one: '1 di questi libri è già nella tua libreria',
      zero: 'Nessuno di questi libri è già nella tua libreria',
    );
    return '$_temp0, che ne contiene $library.';
  }

  @override
  String importChoice(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Unire aggiunge i $missing libri mancanti',
      one: 'Unire aggiunge il libro mancante',
      zero: 'Unire non aggiunge nessun libro',
    );
    return '$_temp0 e non cambia nient\'altro. Sostituire cancella tutta la tua libreria attuale.';
  }

  @override
  String get replaceAll => 'Sostituisci tutto';

  @override
  String get merge => 'Unisci';

  @override
  String get libraryReplaced => 'Libreria sostituita';

  @override
  String get backupMerged => 'Backup unito';

  @override
  String booksImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libri importati',
      one: '1 libro importato',
      zero: 'nessun libro importato',
    );
    return '$_temp0';
  }

  @override
  String booksSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count già presenti',
      one: '1 già presente',
    );
    return '$_temp0';
  }

  @override
  String get addBookTitle => 'Aggiungi un libro';

  @override
  String get titleRequiredLabel => 'Titolo *';

  @override
  String get requiredHint => 'Obbligatorio';

  @override
  String get titleRequired => 'Il titolo è obbligatorio.';

  @override
  String get authorLabel => 'Autore';

  @override
  String get formSectionCover => 'Copertina';

  @override
  String get formSectionBook => 'Il libro';

  @override
  String get formSectionDetails => 'Dettagli';

  @override
  String get formDetailsHint => 'Facoltativo: lascia vuoto ciò che non sai.';

  @override
  String get pagesShortLabel => 'Pagine';

  @override
  String get yearShortLabel => 'Anno';

  @override
  String get shelfLabel => 'Scaffale';

  @override
  String get pageCountInvalid => 'Indica un numero di pagine maggiore di zero.';

  @override
  String yearInvalid(int max) {
    return 'Indica un anno tra 1 e $max.';
  }

  @override
  String get detailsUpdated => 'Informazioni aggiornate';

  @override
  String get bookGone => 'Questo libro non esiste più.';

  @override
  String get searchOnline => 'Cerca online';

  @override
  String get fromGallery => 'Dalla galleria';

  @override
  String get removeCover => 'Rimuovi la copertina';

  @override
  String get searchCover => 'Cerca una copertina';

  @override
  String get searchFailed => 'La ricerca non è riuscita.';

  @override
  String get noCoverFound =>
      'Nessuna copertina trovata. Prova un altro titolo.';

  @override
  String get myColor => 'Il mio colore';

  @override
  String get myGradient => 'Il mio sfondo sfumato';

  @override
  String get textPreview => 'Anteprima del testo';

  @override
  String get gradientTop => 'Sopra';

  @override
  String get gradientBottom => 'Sotto';

  @override
  String get intensity => 'Intensità';

  @override
  String get lightness => 'Luminosità';

  @override
  String get hue => 'Tonalità';

  @override
  String sliderValue(String label, int value) {
    return '$label $value%';
  }

  @override
  String get backgroundAuto => 'Automatico';

  @override
  String get backgroundDark => 'Scuro';

  @override
  String get backgroundLight => 'Chiaro';

  @override
  String get backgroundVivid => 'Vivace';

  @override
  String get backgroundNight => 'Notte';

  @override
  String get backgroundPaper => 'Carta';

  @override
  String get formatCompact => 'Scheda';

  @override
  String get formatStory => 'Storia';

  @override
  String get cardKickerReading => 'STO LEGGENDO';

  @override
  String get cardKickerRead => 'LETTURA FINITA';

  @override
  String get cardKickerToRead => 'NELLA MIA PILA';

  @override
  String cardPage(int page) {
    return 'pagina $page';
  }

  @override
  String get cardPageUnknown => 'numero di pagine sconosciuto';

  @override
  String cardPageOf(int page, int total) {
    return 'pagina $page di $total';
  }

  @override
  String get storyTooltip => 'Condividi in una storia di Instagram';

  @override
  String get story => 'Storia';

  @override
  String get preparing => 'Preparazione…';

  @override
  String get saveToGallery => 'Salva nella galleria';

  @override
  String get imageSaved => 'Immagine salvata nella galleria.';

  @override
  String get imageNotReady => 'Impossibile preparare l\'immagine.';

  @override
  String get welcomeTitle => 'Benvenuto';

  @override
  String get welcomeChooseLanguage => 'Scegli la tua lingua';

  @override
  String get welcomeHint =>
      'Puoi cambiarla in qualsiasi momento nelle impostazioni.';

  @override
  String get continueButton => 'Continua';

  @override
  String get errorNetwork =>
      'Nessuna connessione. Controlla la rete e riprova.';

  @override
  String get errorTimeout => 'La ricerca impiega troppo tempo a rispondere.';

  @override
  String get errorServer =>
      'Il servizio dei libri ha restituito un errore. Riprova più tardi.';

  @override
  String get errorMalformedResponse =>
      'Risposta illeggibile dal servizio dei libri.';

  @override
  String get errorCancelled => 'Richiesta annullata.';

  @override
  String get errorDuplicateBook => 'Questo libro è già nella tua libreria.';

  @override
  String get errorSaveFailed =>
      'Impossibile salvare. Controlla i dati inseriti.';

  @override
  String get errorBookReadFailed => 'Impossibile caricare il libro.';

  @override
  String get errorLibraryReadFailed => 'Impossibile caricare la libreria.';

  @override
  String get errorMalformedBackup => 'Questo file non è un backup valido.';

  @override
  String get errorBackupUntitledBook =>
      'Questo file contiene un libro senza titolo.';

  @override
  String get errorBackupUnknownShelf =>
      'Questo file contiene uno scaffale sconosciuto.';

  @override
  String get errorBackupNotText => 'Questo file non è testo leggibile.';

  @override
  String get errorBackupTooRecent =>
      'Questo backup proviene da una versione più recente dell\'app. Aggiorna l\'app per leggerlo.';

  @override
  String get errorFileAccess => 'Impossibile accedere al file scelto.';

  @override
  String get errorFileRead => 'Impossibile leggere il file.';

  @override
  String get errorExportLocation => 'Impossibile salvare in questa posizione.';

  @override
  String get errorImageRead => 'Impossibile leggere l\'immagine.';

  @override
  String get errorImageCopy => 'Impossibile copiare l\'immagine.';

  @override
  String get errorImagePrepare =>
      'Impossibile preparare l\'immagine da condividere.';

  @override
  String get errorShareFailed => 'Condivisione non riuscita.';

  @override
  String get errorInstagramFailed => 'Impossibile aprire Instagram.';

  @override
  String get errorPhotoAccess =>
      'Consenti l\'accesso alle foto per salvare l\'immagine.';

  @override
  String get errorNotEnoughSpace => 'Spazio insufficiente sul telefono.';

  @override
  String get errorImageSaveFailed => 'Impossibile salvare l\'immagine.';

  @override
  String get aboutTitle => 'Informazioni';

  @override
  String get aboutSubtitle => 'Chi sono, lo spirito dell\'app, contatti';

  @override
  String get aboutBy => 'di libergot';

  @override
  String get aboutWhoTitle => 'Chi sono';

  @override
  String get aboutWhoBody =>
      'Sono libergot, uno sviluppatore indipendente. Ho creato MyBookmark perché volevo un modo semplice per seguire le mie letture: sapere a che punto sono, ricordare cosa ne ho pensato e condividere i libri che amo.';

  @override
  String get aboutSpiritTitle => 'Lo spirito dell\'app';

  @override
  String get aboutSpiritFree => 'Gratuita e senza pubblicità';

  @override
  String get aboutSpiritNoAccount => 'Nessun account da creare';

  @override
  String get aboutSpiritLocal => 'I tuoi libri restano sul tuo telefono';

  @override
  String get aboutSpiritNoTracking =>
      'Nessun tracciamento, nessuna statistica d\'uso';

  @override
  String get aboutFeedbackTitle => 'Un\'idea, un bug?';

  @override
  String get aboutFeedbackBody =>
      'MyBookmark cresce con i tuoi suggerimenti. Una funzione che ti manca, qualcosa che non va: scrivimi.';

  @override
  String get aboutFeedbackButton => 'Scrivimi';

  @override
  String get aboutFeedbackSubject => 'MyBookmark: un suggerimento';

  @override
  String aboutNoMailApp(String email) {
    return 'Nessuna app di posta trovata. Il mio indirizzo è stato copiato: $email';
  }

  @override
  String get aboutRateTitle => 'Ti piace MyBookmark?';

  @override
  String get aboutRateBody =>
      'Una valutazione su Google Play aiuta altri lettori a scoprire l\'app. Grazie!';

  @override
  String get aboutRateButton => 'Valuta su Google Play';

  @override
  String get aboutWebsite => 'Sito web';

  @override
  String get aboutPrivacy => 'Informativa sulla privacy';

  @override
  String get aboutLinkFailed => 'Impossibile aprire il link.';
}
