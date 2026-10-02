// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MyBookmark';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get add => 'Añadir';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Aceptar';

  @override
  String get apply => 'Aplicar';

  @override
  String get retry => 'Reintentar';

  @override
  String get clear => 'Borrar';

  @override
  String get share => 'Compartir';

  @override
  String get unknownAuthor => 'Autor desconocido';

  @override
  String get errorTitle => 'Algo ha fallado';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navSettings => 'Ajustes';

  @override
  String percent(int percent) {
    return '$percent %';
  }

  @override
  String pageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas',
      one: '1 página',
    );
    return '$_temp0';
  }

  @override
  String get pageCountUnknown => 'Número de páginas desconocido';

  @override
  String get shelfToRead => 'Por leer';

  @override
  String get shelfReading => 'Leyendo';

  @override
  String get shelfRead => 'Leído';

  @override
  String shelfAdded(String shelf) {
    return 'Añadido a «$shelf»';
  }

  @override
  String get currentShelf => 'Estantería actual';

  @override
  String progressPageUnknownTotal(int page) {
    return 'Página $page · número de páginas desconocido';
  }

  @override
  String progressPageOf(int page, int total, int percent) {
    return 'Página $page de $total · $percent %';
  }

  @override
  String get notRatedYet => 'Sin valorar';

  @override
  String ratedOutOf(int rating, int max) {
    return 'Valorado con $rating de $max';
  }

  @override
  String starCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrellas',
      one: '1 estrella',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'Mi biblioteca';

  @override
  String get addBookManually => 'Añadir un libro';

  @override
  String get addBookManuallyTooltip =>
      'Añadir un libro que la búsqueda no encuentra';

  @override
  String get filterAll => 'Todos';

  @override
  String get sortTooltip => 'Ordenar';

  @override
  String get sortTitle => 'Título';

  @override
  String get sortAuthor => 'Autor';

  @override
  String get sortAddedAt => 'Fecha de adición';

  @override
  String get sortRating => 'Valoración';

  @override
  String get readNotRated => 'Leído · sin valorar';

  @override
  String toReadWithPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Por leer · $count páginas',
      one: 'Por leer · 1 página',
    );
    return '$_temp0';
  }

  @override
  String emptyShelfTitle(String shelf) {
    return 'Nada en «$shelf»';
  }

  @override
  String get emptyShelfMessage => 'Todavía no hay libros en esta estantería.';

  @override
  String get emptyLibraryTitle => 'Tu biblioteca está vacía';

  @override
  String get emptyLibraryMessage =>
      'Busca un libro para empezar a seguir tus lecturas.';

  @override
  String get searchABook => 'Buscar un libro';

  @override
  String get searchHint => 'Título o autor';

  @override
  String get searchPromptTitle => 'Busca un libro';

  @override
  String get searchPromptMessage =>
      'Escribe un título o el nombre de un autor.';

  @override
  String searchMinChars(int count) {
    return 'Al menos $count caracteres.';
  }

  @override
  String get noResultsTitle => 'Sin resultados';

  @override
  String get noResultsMessage =>
      'Ni Open Library ni Apple Books conocen este título. Revisa la ortografía o añade el libro tú mismo.';

  @override
  String get addBookByHand => 'Añadir el libro a mano';

  @override
  String get alreadyInLibrary => 'Ya está en tu biblioteca';

  @override
  String get bookDeletedTitle => 'Libro eliminado';

  @override
  String get bookDeletedMessage => 'Este libro ya no está en tu biblioteca.';

  @override
  String get actionsTooltip => 'Acciones';

  @override
  String get shareProgress => 'Compartir mi progreso';

  @override
  String get editBookDetails => 'Editar la información';

  @override
  String get startReread => 'Empezar una relectura';

  @override
  String get removeFromLibrary => 'Quitar de mi biblioteca';

  @override
  String get rereadStarted =>
      'Relectura empezada. La lectura anterior se queda en el historial.';

  @override
  String get deleteBookTitle => '¿Eliminar este libro?';

  @override
  String deleteBookMessage(String title) {
    return '«$title» se quitará de tu biblioteca, junto con su valoración, su reseña y todo su historial de lectura. No se puede deshacer.';
  }

  @override
  String get enteredManually => 'Añadido a mano';

  @override
  String get readingDates => 'Fechas de lectura';

  @override
  String get startedOn => 'Empezado el';

  @override
  String get finishedOn => 'Terminado el';

  @override
  String get readingStart => 'Inicio de la lectura';

  @override
  String get readingEnd => 'Fin de la lectura';

  @override
  String get endBeforeStart =>
      'La fecha de fin no puede ser anterior a la de inicio.';

  @override
  String get dateNotSet => 'Sin indicar';

  @override
  String get clearDate => 'Borrar la fecha';

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

    return 'del $dateString';
  }

  @override
  String historyTo(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'al $dateString';
  }

  @override
  String get datesNotSet => 'Sin fechas';

  @override
  String previousReadings(int count) {
    return 'Lecturas anteriores ($count)';
  }

  @override
  String get summary => 'Resumen';

  @override
  String get noSummaryManual =>
      'Todavía no hay resumen. Puedes añadir uno editando la información del libro.';

  @override
  String get noSummaryOnline => 'No hay resumen disponible para este libro.';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get readMore => 'Leer más';

  @override
  String get progressTitle => 'Progreso';

  @override
  String get currentPage => 'Página actual';

  @override
  String ofPages(int count) {
    return 'de $count';
  }

  @override
  String get lastPage => 'Última página';

  @override
  String pageClamped(int count, int page) {
    return 'Este libro tiene $count páginas: el progreso se ha guardado en la página $page.';
  }

  @override
  String get ratingAndReview => 'Mi valoración y mi reseña';

  @override
  String get myReview => 'Mi reseña';

  @override
  String get reviewHint => 'Lo que te pareció, para recordarlo.';

  @override
  String get saveReview => 'Guardar la reseña';

  @override
  String get reviewSaved => 'Reseña guardada';

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeSystem => 'Como el sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Idioma del teléfono';

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
  String get myData => 'Mis datos';

  @override
  String get dataExplanation =>
      'Todo se guarda en este teléfono, sin cuenta ni servidor. Exportar es la única forma de conservar una copia de tu biblioteca o de pasarla a otro dispositivo.';

  @override
  String get exportLibrary => 'Exportar mi biblioteca';

  @override
  String get exportSubtitle => 'Guarda un archivo JSON';

  @override
  String get importBackup => 'Importar una copia de seguridad';

  @override
  String get importSubtitle => 'Desde un archivo JSON';

  @override
  String get importGoodreads => 'Importar desde Goodreads';

  @override
  String get importGoodreadsSubtitle =>
      'Archivo CSV exportado desde goodreads.com (My Books → Import and export)';

  @override
  String get importGoodreadsFile => 'Exportación de Goodreads:';

  @override
  String get errorMalformedGoodreads =>
      'Este archivo no es una exportación de Goodreads. En goodreads.com, abre My Books → Import and export → Export Library.';

  @override
  String exportedTo(String name) {
    return 'Biblioteca exportada en $name';
  }

  @override
  String get importTitle => '¿Importar esta copia de seguridad?';

  @override
  String importFileDated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Archivo del $dateString:';
  }

  @override
  String importBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros',
      one: '1 libro',
      zero: 'ningún libro',
    );
    return '$_temp0';
  }

  @override
  String importReadingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lecturas',
      one: '1 lectura',
      zero: 'ninguna lectura',
    );
    return '$_temp0';
  }

  @override
  String importAlreadyPresent(int present, int library) {
    String _temp0 = intl.Intl.pluralLogic(
      present,
      locale: localeName,
      other: '$present de estos libros ya están en tu biblioteca',
      one: '1 de estos libros ya está en tu biblioteca',
      zero: 'Ninguno de estos libros está ya en tu biblioteca',
    );
    return '$_temp0, que tiene $library.';
  }

  @override
  String importChoice(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Combinar añade los $missing libros que faltan',
      one: 'Combinar añade el libro que falta',
      zero: 'Combinar no añade ningún libro',
    );
    return '$_temp0 y no cambia nada más. Reemplazar borra toda tu biblioteca actual.';
  }

  @override
  String get replaceAll => 'Reemplazar todo';

  @override
  String get merge => 'Combinar';

  @override
  String get libraryReplaced => 'Biblioteca reemplazada';

  @override
  String get backupMerged => 'Copia de seguridad combinada';

  @override
  String booksImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros importados',
      one: '1 libro importado',
      zero: 'ningún libro importado',
    );
    return '$_temp0';
  }

  @override
  String booksSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ya estaban',
      one: '1 ya estaba',
    );
    return '$_temp0';
  }

  @override
  String get addBookTitle => 'Añadir un libro';

  @override
  String get titleRequiredLabel => 'Título *';

  @override
  String get requiredHint => 'Obligatorio';

  @override
  String get titleRequired => 'El título es obligatorio.';

  @override
  String get authorLabel => 'Autor';

  @override
  String get pageCountLabel => 'Número de páginas';

  @override
  String get pageCountHelper => 'Déjalo vacío si no lo sabes.';

  @override
  String get yearLabel => 'Año de publicación';

  @override
  String get shelfLabel => 'Estantería';

  @override
  String get pageCountInvalid => 'Indica un número de páginas mayor que cero.';

  @override
  String yearInvalid(int max) {
    return 'Indica un año entre 1 y $max.';
  }

  @override
  String get detailsUpdated => 'Información actualizada';

  @override
  String get bookGone => 'Este libro ya no existe.';

  @override
  String get searchOnline => 'Buscar en internet';

  @override
  String get fromGallery => 'Desde la galería';

  @override
  String get removeCover => 'Quitar la portada';

  @override
  String get searchCover => 'Buscar una portada';

  @override
  String get searchFailed => 'La búsqueda ha fallado.';

  @override
  String get noCoverFound =>
      'No se ha encontrado ninguna portada. Prueba con otro título.';

  @override
  String get myColor => 'Mi color';

  @override
  String get myGradient => 'Mi degradado';

  @override
  String get textPreview => 'Vista previa del texto';

  @override
  String get gradientTop => 'Arriba';

  @override
  String get gradientBottom => 'Abajo';

  @override
  String get intensity => 'Intensidad';

  @override
  String get lightness => 'Luminosidad';

  @override
  String get hue => 'Tono';

  @override
  String sliderValue(String label, int value) {
    return '$label $value %';
  }

  @override
  String get backgroundAuto => 'Automático';

  @override
  String get backgroundDark => 'Oscuro';

  @override
  String get backgroundLight => 'Claro';

  @override
  String get backgroundVivid => 'Vivo';

  @override
  String get backgroundNight => 'Noche';

  @override
  String get backgroundPaper => 'Papel';

  @override
  String get formatCompact => 'Tarjeta';

  @override
  String get formatStory => 'Historia';

  @override
  String get cardKickerReading => 'LEYENDO AHORA';

  @override
  String get cardKickerRead => 'LECTURA TERMINADA';

  @override
  String get cardKickerToRead => 'EN MI PILA';

  @override
  String cardPage(int page) {
    return 'página $page';
  }

  @override
  String get cardPageUnknown => 'número de páginas desconocido';

  @override
  String cardPageOf(int page, int total) {
    return 'página $page de $total';
  }

  @override
  String get storyTooltip => 'Compartir en una historia de Instagram';

  @override
  String get story => 'Historia';

  @override
  String get preparing => 'Preparando…';

  @override
  String get saveToGallery => 'Guardar en la galería';

  @override
  String get imageSaved => 'Imagen guardada en la galería.';

  @override
  String get imageNotReady => 'No se ha podido preparar la imagen.';

  @override
  String get welcomeTitle => 'Bienvenido';

  @override
  String get welcomeChooseLanguage => 'Elige tu idioma';

  @override
  String get welcomeHint => 'Puedes cambiarlo cuando quieras en los ajustes.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get errorNetwork =>
      'Sin conexión. Revisa tu red e inténtalo de nuevo.';

  @override
  String get errorTimeout => 'La búsqueda tarda demasiado en responder.';

  @override
  String get errorServer =>
      'El servicio de libros ha devuelto un error. Inténtalo más tarde.';

  @override
  String get errorMalformedResponse =>
      'Respuesta ilegible del servicio de libros.';

  @override
  String get errorCancelled => 'Solicitud cancelada.';

  @override
  String get errorDuplicateBook => 'Este libro ya está en tu biblioteca.';

  @override
  String get errorSaveFailed =>
      'No se ha podido guardar. Revisa lo que has escrito.';

  @override
  String get errorBookReadFailed => 'No se ha podido cargar el libro.';

  @override
  String get errorLibraryReadFailed => 'No se ha podido cargar la biblioteca.';

  @override
  String get errorMalformedBackup =>
      'Este archivo no es una copia de seguridad válida.';

  @override
  String get errorBackupUntitledBook =>
      'Este archivo contiene un libro sin título.';

  @override
  String get errorBackupUnknownShelf =>
      'Este archivo contiene una estantería desconocida.';

  @override
  String get errorBackupNotText => 'Este archivo no es texto legible.';

  @override
  String get errorBackupTooRecent =>
      'Esta copia de seguridad viene de una versión más reciente de la app. Actualiza la app para leerla.';

  @override
  String get errorFileAccess => 'No se ha podido acceder al archivo elegido.';

  @override
  String get errorFileRead => 'No se ha podido leer el archivo.';

  @override
  String get errorExportLocation => 'No se puede guardar en esta ubicación.';

  @override
  String get errorImageRead => 'No se ha podido leer la imagen.';

  @override
  String get errorImageCopy => 'No se ha podido copiar la imagen.';

  @override
  String get errorImagePrepare =>
      'No se ha podido preparar la imagen para compartir.';

  @override
  String get errorShareFailed => 'No se ha podido compartir.';

  @override
  String get errorInstagramFailed => 'No se ha podido abrir Instagram.';

  @override
  String get errorPhotoAccess =>
      'Permite el acceso a las fotos para guardar la imagen.';

  @override
  String get errorNotEnoughSpace =>
      'No queda espacio suficiente en el teléfono.';

  @override
  String get errorImageSaveFailed => 'No se ha podido guardar la imagen.';
}
