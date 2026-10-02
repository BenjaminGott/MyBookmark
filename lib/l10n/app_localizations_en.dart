// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyBookmark';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'OK';

  @override
  String get apply => 'Apply';

  @override
  String get retry => 'Try again';

  @override
  String get clear => 'Clear';

  @override
  String get share => 'Share';

  @override
  String get unknownAuthor => 'Unknown author';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSearch => 'Search';

  @override
  String get navSettings => 'Settings';

  @override
  String percent(int percent) {
    return '$percent%';
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
  String get pageCountUnknown => 'Page count unknown';

  @override
  String get shelfToRead => 'To read';

  @override
  String get shelfReading => 'Reading';

  @override
  String get shelfRead => 'Read';

  @override
  String shelfAdded(String shelf) {
    return 'Added to “$shelf”';
  }

  @override
  String get currentShelf => 'Current shelf';

  @override
  String progressPageUnknownTotal(int page) {
    return 'Page $page · page count unknown';
  }

  @override
  String progressPageOf(int page, int total, int percent) {
    return 'Page $page of $total · $percent%';
  }

  @override
  String get notRatedYet => 'Not rated yet';

  @override
  String ratedOutOf(int rating, int max) {
    return 'Rated $rating out of $max';
  }

  @override
  String starCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'My library';

  @override
  String get addBookManually => 'Add a book';

  @override
  String get addBookManuallyTooltip => 'Add a book the search can\'t find';

  @override
  String get filterAll => 'All';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get sortTitle => 'Title';

  @override
  String get sortAuthor => 'Author';

  @override
  String get sortAddedAt => 'Date added';

  @override
  String get sortRating => 'Rating';

  @override
  String get readNotRated => 'Read · not rated yet';

  @override
  String toReadWithPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'To read · $count pages',
      one: 'To read · 1 page',
    );
    return '$_temp0';
  }

  @override
  String emptyShelfTitle(String shelf) {
    return 'Nothing in “$shelf”';
  }

  @override
  String get emptyShelfMessage => 'No books on this shelf yet.';

  @override
  String get emptyLibraryTitle => 'Your library is empty';

  @override
  String get emptyLibraryMessage =>
      'Search for a book to start tracking your reading.';

  @override
  String get searchABook => 'Search for a book';

  @override
  String get searchHint => 'Title or author';

  @override
  String get searchPromptTitle => 'Look up a book';

  @override
  String get searchPromptMessage => 'Type a title or an author\'s name.';

  @override
  String searchMinChars(int count) {
    return 'At least $count characters.';
  }

  @override
  String get noResultsTitle => 'No results';

  @override
  String get noResultsMessage =>
      'Neither Open Library nor Apple Books knows this title. Check the spelling, or add the book yourself.';

  @override
  String get addBookByHand => 'Add the book manually';

  @override
  String get alreadyInLibrary => 'Already in your library';

  @override
  String get bookDeletedTitle => 'Book deleted';

  @override
  String get bookDeletedMessage => 'This book is no longer in your library.';

  @override
  String get actionsTooltip => 'Actions';

  @override
  String get shareProgress => 'Share my progress';

  @override
  String get editBookDetails => 'Edit details';

  @override
  String get startReread => 'Start a re-read';

  @override
  String get removeFromLibrary => 'Remove from my library';

  @override
  String get rereadStarted =>
      'Re-read started. The previous reading stays in the history.';

  @override
  String get deleteBookTitle => 'Delete this book?';

  @override
  String deleteBookMessage(String title) {
    return '“$title” will be removed from your library, along with its rating, review and whole reading history. This can\'t be undone.';
  }

  @override
  String get enteredManually => 'Added manually';

  @override
  String get readingDates => 'Reading dates';

  @override
  String get startedOn => 'Started on';

  @override
  String get finishedOn => 'Finished on';

  @override
  String get readingStart => 'Reading start';

  @override
  String get readingEnd => 'Reading end';

  @override
  String get endBeforeStart => 'The end date can\'t be before the start date.';

  @override
  String get dateNotSet => 'Not set';

  @override
  String get clearDate => 'Clear date';

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

    return 'from $dateString';
  }

  @override
  String historyTo(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'to $dateString';
  }

  @override
  String get datesNotSet => 'No dates';

  @override
  String previousReadings(int count) {
    return 'Previous readings ($count)';
  }

  @override
  String get summary => 'Summary';

  @override
  String get noSummaryManual =>
      'No summary yet. You can add one by editing the book\'s details.';

  @override
  String get noSummaryOnline => 'No summary is available for this book.';

  @override
  String get showLess => 'Show less';

  @override
  String get readMore => 'Read more';

  @override
  String get progressTitle => 'Progress';

  @override
  String get currentPage => 'Current page';

  @override
  String ofPages(int count) {
    return 'of $count';
  }

  @override
  String get lastPage => 'Last page';

  @override
  String pageClamped(int count, int page) {
    return 'This book has $count pages: progress was saved at page $page.';
  }

  @override
  String get ratingAndReview => 'My rating and review';

  @override
  String get myReview => 'My review';

  @override
  String get reviewHint => 'What you thought of it, so you remember.';

  @override
  String get saveReview => 'Save review';

  @override
  String get reviewSaved => 'Review saved';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Phone language';

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
  String get myData => 'My data';

  @override
  String get dataExplanation =>
      'Everything is stored on this phone, with no account or server. Exporting is the only way to keep a copy of your library or move it to another device.';

  @override
  String get exportLibrary => 'Export my library';

  @override
  String get exportSubtitle => 'Saves a JSON file';

  @override
  String get importBackup => 'Import a backup';

  @override
  String get importSubtitle => 'From a JSON file';

  @override
  String get importGoodreads => 'Import from Goodreads';

  @override
  String get importGoodreadsSubtitle =>
      'CSV file exported from goodreads.com (My Books → Import and export)';

  @override
  String get importGoodreadsFile => 'Goodreads export:';

  @override
  String get errorMalformedGoodreads =>
      'This file isn\'t a Goodreads export. On goodreads.com, open My Books → Import and export → Export Library.';

  @override
  String exportedTo(String name) {
    return 'Library exported to $name';
  }

  @override
  String get importTitle => 'Import this backup?';

  @override
  String importFileDated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'File from $dateString:';
  }

  @override
  String importBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '1 book',
      zero: 'no books',
    );
    return '$_temp0';
  }

  @override
  String importReadingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count readings',
      one: '1 reading',
      zero: 'no readings',
    );
    return '$_temp0';
  }

  @override
  String importAlreadyPresent(int present, int library) {
    String _temp0 = intl.Intl.pluralLogic(
      present,
      locale: localeName,
      other: '$present of these books are already in your library',
      one: '1 of these books is already in your library',
      zero: 'None of these books are in your library yet',
    );
    return '$_temp0, which has $library.';
  }

  @override
  String importChoice(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Merging adds the $missing missing books',
      one: 'Merging adds the missing book',
      zero: 'Merging adds no books',
    );
    return '$_temp0 and changes nothing else. Replacing erases your whole current library.';
  }

  @override
  String get replaceAll => 'Replace all';

  @override
  String get merge => 'Merge';

  @override
  String get libraryReplaced => 'Library replaced';

  @override
  String get backupMerged => 'Backup merged';

  @override
  String booksImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books imported',
      one: '1 book imported',
      zero: 'no books imported',
    );
    return '$_temp0';
  }

  @override
  String booksSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count already there',
      one: '1 already there',
    );
    return '$_temp0';
  }

  @override
  String get addBookTitle => 'Add a book';

  @override
  String get titleRequiredLabel => 'Title *';

  @override
  String get requiredHint => 'Required';

  @override
  String get titleRequired => 'The title is required.';

  @override
  String get authorLabel => 'Author';

  @override
  String get pageCountLabel => 'Number of pages';

  @override
  String get pageCountHelper => 'Leave empty if you don\'t know it.';

  @override
  String get yearLabel => 'Publication year';

  @override
  String get shelfLabel => 'Shelf';

  @override
  String get pageCountInvalid => 'Enter a page count greater than zero.';

  @override
  String yearInvalid(int max) {
    return 'Enter a year between 1 and $max.';
  }

  @override
  String get detailsUpdated => 'Details updated';

  @override
  String get bookGone => 'This book no longer exists.';

  @override
  String get searchOnline => 'Search online';

  @override
  String get fromGallery => 'From gallery';

  @override
  String get removeCover => 'Remove cover';

  @override
  String get searchCover => 'Search for a cover';

  @override
  String get searchFailed => 'The search failed.';

  @override
  String get noCoverFound => 'No cover found. Try another title.';

  @override
  String get myColor => 'My color';

  @override
  String get myGradient => 'My gradient';

  @override
  String get textPreview => 'Text preview';

  @override
  String get gradientTop => 'Top';

  @override
  String get gradientBottom => 'Bottom';

  @override
  String get intensity => 'Intensity';

  @override
  String get lightness => 'Lightness';

  @override
  String get hue => 'Hue';

  @override
  String sliderValue(String label, int value) {
    return '$label $value%';
  }

  @override
  String get backgroundAuto => 'Automatic';

  @override
  String get backgroundDark => 'Dark';

  @override
  String get backgroundLight => 'Light';

  @override
  String get backgroundVivid => 'Vivid';

  @override
  String get backgroundNight => 'Night';

  @override
  String get backgroundPaper => 'Paper';

  @override
  String get formatCompact => 'Card';

  @override
  String get formatStory => 'Story';

  @override
  String get cardKickerReading => 'CURRENTLY READING';

  @override
  String get cardKickerRead => 'FINISHED';

  @override
  String get cardKickerToRead => 'ON MY PILE';

  @override
  String cardPage(int page) {
    return 'page $page';
  }

  @override
  String get cardPageUnknown => 'page count unknown';

  @override
  String cardPageOf(int page, int total) {
    return 'page $page of $total';
  }

  @override
  String get storyTooltip => 'Share to an Instagram story';

  @override
  String get story => 'Story';

  @override
  String get preparing => 'Preparing…';

  @override
  String get saveToGallery => 'Save to gallery';

  @override
  String get imageSaved => 'Image saved to gallery.';

  @override
  String get imageNotReady => 'Couldn\'t prepare the image.';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeChooseLanguage => 'Choose your language';

  @override
  String get welcomeHint => 'You can change it anytime in Settings.';

  @override
  String get continueButton => 'Continue';

  @override
  String get errorNetwork => 'No connection. Check your network and try again.';

  @override
  String get errorTimeout => 'The search is taking too long to respond.';

  @override
  String get errorServer =>
      'The book service returned an error. Please try again later.';

  @override
  String get errorMalformedResponse =>
      'Unreadable response from the book service.';

  @override
  String get errorCancelled => 'Request cancelled.';

  @override
  String get errorDuplicateBook => 'This book is already in your library.';

  @override
  String get errorSaveFailed => 'Couldn\'t save. Check what you entered.';

  @override
  String get errorBookReadFailed => 'Couldn\'t load the book.';

  @override
  String get errorLibraryReadFailed => 'Couldn\'t load the library.';

  @override
  String get errorMalformedBackup => 'This file isn\'t a valid backup.';

  @override
  String get errorBackupUntitledBook =>
      'This file contains a book without a title.';

  @override
  String get errorBackupUnknownShelf => 'This file contains an unknown shelf.';

  @override
  String get errorBackupNotText => 'This file isn\'t readable text.';

  @override
  String get errorBackupTooRecent =>
      'This backup comes from a newer version of the app. Update the app to read it.';

  @override
  String get errorFileAccess => 'Couldn\'t access the selected file.';

  @override
  String get errorFileRead => 'Couldn\'t read the file.';

  @override
  String get errorExportLocation => 'Can\'t save to this location.';

  @override
  String get errorImageRead => 'Couldn\'t read the image.';

  @override
  String get errorImageCopy => 'Couldn\'t copy the image.';

  @override
  String get errorImagePrepare => 'Couldn\'t prepare the image for sharing.';

  @override
  String get errorShareFailed => 'Sharing failed.';

  @override
  String get errorInstagramFailed => 'Couldn\'t open Instagram.';

  @override
  String get errorPhotoAccess => 'Allow photo access to save the image.';

  @override
  String get errorNotEnoughSpace => 'Not enough space on the phone.';

  @override
  String get errorImageSaveFailed => 'The image couldn\'t be saved.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutSubtitle => 'Who I am, the app\'s spirit, get in touch';

  @override
  String get aboutBy => 'by libergot';

  @override
  String get aboutWhoTitle => 'Who I am';

  @override
  String get aboutWhoBody =>
      'I\'m libergot, an independent developer. I built MyBookmark because I wanted a simple way to keep track of my reading: where I\'m at, what I thought of it, and the books I love enough to share.';

  @override
  String get aboutSpiritTitle => 'The app\'s spirit';

  @override
  String get aboutSpiritFree => 'Free, with no ads';

  @override
  String get aboutSpiritNoAccount => 'No account to create';

  @override
  String get aboutSpiritLocal => 'Your books stay on your phone';

  @override
  String get aboutSpiritNoTracking => 'No tracking, no usage statistics';

  @override
  String get aboutFeedbackTitle => 'An idea, a bug?';

  @override
  String get aboutFeedbackBody =>
      'MyBookmark grows with your feedback. A feature you miss, something that doesn\'t work: write to me.';

  @override
  String get aboutFeedbackButton => 'Write to me';

  @override
  String get aboutFeedbackSubject => 'MyBookmark: a suggestion';

  @override
  String aboutNoMailApp(String email) {
    return 'No email app found. My address has been copied: $email';
  }

  @override
  String get aboutRateTitle => 'Enjoying MyBookmark?';

  @override
  String get aboutRateBody =>
      'A rating on Google Play helps other readers discover the app. Thank you!';

  @override
  String get aboutRateButton => 'Rate on Google Play';

  @override
  String get aboutWebsite => 'Website';

  @override
  String get aboutPrivacy => 'Privacy policy';

  @override
  String get aboutLinkFailed => 'Couldn\'t open the link.';
}
