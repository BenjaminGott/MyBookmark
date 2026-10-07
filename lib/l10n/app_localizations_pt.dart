// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'MyBookmark';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get add => 'Adicionar';

  @override
  String get delete => 'Excluir';

  @override
  String get confirm => 'OK';

  @override
  String get apply => 'Aplicar';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get clear => 'Limpar';

  @override
  String get share => 'Compartilhar';

  @override
  String get unknownAuthor => 'Autor desconhecido';

  @override
  String get errorTitle => 'Algo deu errado';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navSettings => 'Ajustes';

  @override
  String percent(int percent) {
    return '$percent%';
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
  String get pageCountUnknown => 'Número de páginas desconhecido';

  @override
  String get shelfToRead => 'Para ler';

  @override
  String get shelfReading => 'Lendo';

  @override
  String get shelfRead => 'Lido';

  @override
  String shelfAdded(String shelf) {
    return 'Adicionado a “$shelf”';
  }

  @override
  String get currentShelf => 'Estante atual';

  @override
  String progressPageUnknownTotal(int page) {
    return 'Página $page · número de páginas desconhecido';
  }

  @override
  String progressPageOf(int page, int total, int percent) {
    return 'Página $page de $total · $percent%';
  }

  @override
  String get notRatedYet => 'Ainda sem nota';

  @override
  String ratedOutOf(int rating, int max) {
    return 'Nota $rating de $max';
  }

  @override
  String starCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrelas',
      one: '1 estrela',
    );
    return '$_temp0';
  }

  @override
  String get libraryTitle => 'Minha biblioteca';

  @override
  String get addBookManually => 'Adicionar um livro';

  @override
  String get addBookManuallyTooltip =>
      'Adicionar um livro que a busca não encontra';

  @override
  String get filterAll => 'Todos';

  @override
  String get sortTooltip => 'Ordenar';

  @override
  String get sortTitle => 'Título';

  @override
  String get sortAuthor => 'Autor';

  @override
  String get sortAddedAt => 'Data de adição';

  @override
  String get sortRating => 'Nota';

  @override
  String get readNotRated => 'Lido · ainda sem nota';

  @override
  String toReadWithPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Para ler · $count páginas',
      one: 'Para ler · 1 página',
    );
    return '$_temp0';
  }

  @override
  String emptyShelfTitle(String shelf) {
    return 'Nada em “$shelf”';
  }

  @override
  String get emptyShelfMessage => 'Ainda não há livros nesta estante.';

  @override
  String get emptyLibraryTitle => 'Sua biblioteca está vazia';

  @override
  String get emptyLibraryMessage =>
      'Busque um livro para começar a acompanhar suas leituras.';

  @override
  String get searchABook => 'Buscar um livro';

  @override
  String get searchHint => 'Título ou autor';

  @override
  String get searchPromptTitle => 'Busque um livro';

  @override
  String get searchPromptMessage => 'Digite um título ou o nome de um autor.';

  @override
  String searchMinChars(int count) {
    return 'Pelo menos $count caracteres.';
  }

  @override
  String get noResultsTitle => 'Nenhum resultado';

  @override
  String get noResultsMessage =>
      'Nem a Open Library nem a Apple Books conhecem este título. Confira a ortografia ou adicione o livro você mesmo.';

  @override
  String get addBookByHand => 'Adicionar o livro manualmente';

  @override
  String get alreadyInLibrary => 'Já está na sua biblioteca';

  @override
  String get bookDeletedTitle => 'Livro excluído';

  @override
  String get bookDeletedMessage =>
      'Este livro não está mais na sua biblioteca.';

  @override
  String get actionsTooltip => 'Ações';

  @override
  String get shareProgress => 'Compartilhar meu progresso';

  @override
  String get editBookDetails => 'Editar informações';

  @override
  String get startReread => 'Começar uma releitura';

  @override
  String get removeFromLibrary => 'Remover da minha biblioteca';

  @override
  String get rereadStarted =>
      'Releitura iniciada. A leitura anterior continua no histórico.';

  @override
  String get deleteBookTitle => 'Excluir este livro?';

  @override
  String deleteBookMessage(String title) {
    return '“$title” será removido da sua biblioteca, com a nota, a resenha e todo o histórico de leitura. Não dá para desfazer.';
  }

  @override
  String get enteredManually => 'Adicionado manualmente';

  @override
  String get readingDates => 'Datas de leitura';

  @override
  String get startedOn => 'Começou em';

  @override
  String get finishedOn => 'Terminou em';

  @override
  String get readingStart => 'Início da leitura';

  @override
  String get readingEnd => 'Fim da leitura';

  @override
  String get endBeforeStart =>
      'A data de término não pode ser anterior à de início.';

  @override
  String get dateNotSet => 'Não informada';

  @override
  String get clearDate => 'Limpar a data';

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

    return 'de $dateString';
  }

  @override
  String historyTo(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'a $dateString';
  }

  @override
  String get datesNotSet => 'Sem datas';

  @override
  String previousReadings(int count) {
    return 'Leituras anteriores ($count)';
  }

  @override
  String get summary => 'Resumo';

  @override
  String get noSummaryManual =>
      'Ainda não há resumo. Você pode adicionar um editando as informações do livro.';

  @override
  String get noSummaryOnline => 'Nenhum resumo disponível para este livro.';

  @override
  String get showLess => 'Mostrar menos';

  @override
  String get readMore => 'Ler mais';

  @override
  String get progressTitle => 'Progresso';

  @override
  String get currentPage => 'Página atual';

  @override
  String ofPages(int count) {
    return 'de $count';
  }

  @override
  String get lastPage => 'Última página';

  @override
  String pageClamped(int count, int page) {
    return 'Este livro tem $count páginas: o progresso foi salvo na página $page.';
  }

  @override
  String get ratingAndReview => 'Minha nota e minha resenha';

  @override
  String get myReview => 'Minha resenha';

  @override
  String get reviewHint => 'O que você achou, para não esquecer.';

  @override
  String get saveReview => 'Salvar a resenha';

  @override
  String get reviewSaved => 'Resenha salva';

  @override
  String get appearance => 'Aparência';

  @override
  String get themeSystem => 'Igual ao sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Idioma do telefone';

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
  String get myData => 'Meus dados';

  @override
  String get dataExplanation =>
      'Tudo fica salvo neste telefone, sem conta nem servidor. Exportar é a única forma de guardar uma cópia da sua biblioteca ou de levá-la para outro aparelho.';

  @override
  String get exportLibrary => 'Exportar minha biblioteca';

  @override
  String get exportSubtitle => 'Salva um arquivo JSON';

  @override
  String get importBackup => 'Importar um backup';

  @override
  String get importSubtitle => 'De um arquivo JSON';

  @override
  String get importGoodreads => 'Importar do Goodreads';

  @override
  String get importGoodreadsSubtitle =>
      'Arquivo CSV exportado do goodreads.com (My Books → Import and export)';

  @override
  String get importGoodreadsFile => 'Exportação do Goodreads:';

  @override
  String get errorMalformedGoodreads =>
      'Este arquivo não é uma exportação do Goodreads. No goodreads.com, abra My Books → Import and export → Export Library.';

  @override
  String exportedTo(String name) {
    return 'Biblioteca exportada em $name';
  }

  @override
  String get importTitle => 'Importar este backup?';

  @override
  String importFileDated(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Arquivo de $dateString:';
  }

  @override
  String importBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livros',
      one: '1 livro',
      zero: 'nenhum livro',
    );
    return '$_temp0';
  }

  @override
  String importReadingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count leituras',
      one: '1 leitura',
      zero: 'nenhuma leitura',
    );
    return '$_temp0';
  }

  @override
  String importAlreadyPresent(int present, int library) {
    String _temp0 = intl.Intl.pluralLogic(
      present,
      locale: localeName,
      other: '$present destes livros já estão na sua biblioteca',
      one: '1 destes livros já está na sua biblioteca',
      zero: 'Nenhum destes livros está na sua biblioteca',
    );
    return '$_temp0, que tem $library.';
  }

  @override
  String importChoice(int missing) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Mesclar adiciona os $missing livros que faltam',
      one: 'Mesclar adiciona o livro que falta',
      zero: 'Mesclar não adiciona nenhum livro',
    );
    return '$_temp0 e não muda mais nada. Substituir apaga toda a sua biblioteca atual.';
  }

  @override
  String get replaceAll => 'Substituir tudo';

  @override
  String get merge => 'Mesclar';

  @override
  String get libraryReplaced => 'Biblioteca substituída';

  @override
  String get backupMerged => 'Backup mesclado';

  @override
  String booksImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livros importados',
      one: '1 livro importado',
      zero: 'nenhum livro importado',
    );
    return '$_temp0';
  }

  @override
  String booksSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count já existiam',
      one: '1 já existia',
    );
    return '$_temp0';
  }

  @override
  String get addBookTitle => 'Adicionar um livro';

  @override
  String get titleRequiredLabel => 'Título *';

  @override
  String get requiredHint => 'Obrigatório';

  @override
  String get titleRequired => 'O título é obrigatório.';

  @override
  String get authorLabel => 'Autor';

  @override
  String get formSectionCover => 'Capa';

  @override
  String get formSectionBook => 'O livro';

  @override
  String get formSectionDetails => 'Detalhes';

  @override
  String get formDetailsHint =>
      'Opcional: deixe em branco o que você não souber.';

  @override
  String get pagesShortLabel => 'Páginas';

  @override
  String get yearShortLabel => 'Ano';

  @override
  String get shelfLabel => 'Estante';

  @override
  String get pageCountInvalid => 'Informe um número de páginas maior que zero.';

  @override
  String yearInvalid(int max) {
    return 'Informe um ano entre 1 e $max.';
  }

  @override
  String get detailsUpdated => 'Informações atualizadas';

  @override
  String get bookGone => 'Este livro não existe mais.';

  @override
  String get searchOnline => 'Buscar na internet';

  @override
  String get fromGallery => 'Da galeria';

  @override
  String get removeCover => 'Remover a capa';

  @override
  String get searchCover => 'Buscar uma capa';

  @override
  String get searchFailed => 'A busca falhou.';

  @override
  String get noCoverFound => 'Nenhuma capa encontrada. Tente outro título.';

  @override
  String get myColor => 'Minha cor';

  @override
  String get myGradient => 'Meu degradê';

  @override
  String get textPreview => 'Prévia do texto';

  @override
  String get gradientTop => 'Em cima';

  @override
  String get gradientBottom => 'Embaixo';

  @override
  String get intensity => 'Intensidade';

  @override
  String get lightness => 'Luminosidade';

  @override
  String get hue => 'Matiz';

  @override
  String sliderValue(String label, int value) {
    return '$label $value%';
  }

  @override
  String get backgroundAuto => 'Automático';

  @override
  String get backgroundDark => 'Escuro';

  @override
  String get backgroundLight => 'Claro';

  @override
  String get backgroundVivid => 'Vivo';

  @override
  String get backgroundNight => 'Noite';

  @override
  String get backgroundPaper => 'Papel';

  @override
  String get formatCompact => 'Cartão';

  @override
  String get formatStory => 'Story';

  @override
  String get cardKickerReading => 'LENDO AGORA';

  @override
  String get cardKickerRead => 'LEITURA CONCLUÍDA';

  @override
  String get cardKickerToRead => 'NA MINHA PILHA';

  @override
  String cardPage(int page) {
    return 'página $page';
  }

  @override
  String get cardPageUnknown => 'número de páginas desconhecido';

  @override
  String cardPageOf(int page, int total) {
    return 'página $page de $total';
  }

  @override
  String get storyTooltip => 'Compartilhar nos stories do Instagram';

  @override
  String get story => 'Story';

  @override
  String get preparing => 'Preparando…';

  @override
  String get saveToGallery => 'Salvar na galeria';

  @override
  String get imageSaved => 'Imagem salva na galeria.';

  @override
  String get imageNotReady => 'Não foi possível preparar a imagem.';

  @override
  String get welcomeTitle => 'Boas-vindas';

  @override
  String get welcomeChooseLanguage => 'Escolha seu idioma';

  @override
  String get welcomeHint => 'Você pode mudá-lo quando quiser nos ajustes.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get errorNetwork => 'Sem conexão. Verifique sua rede e tente de novo.';

  @override
  String get errorTimeout => 'A busca está demorando demais para responder.';

  @override
  String get errorServer =>
      'O serviço de livros retornou um erro. Tente mais tarde.';

  @override
  String get errorMalformedResponse =>
      'Resposta ilegível do serviço de livros.';

  @override
  String get errorCancelled => 'Solicitação cancelada.';

  @override
  String get errorDuplicateBook => 'Este livro já está na sua biblioteca.';

  @override
  String get errorSaveFailed =>
      'Não foi possível salvar. Confira o que você digitou.';

  @override
  String get errorBookReadFailed => 'Não foi possível carregar o livro.';

  @override
  String get errorLibraryReadFailed =>
      'Não foi possível carregar a biblioteca.';

  @override
  String get errorMalformedBackup => 'Este arquivo não é um backup válido.';

  @override
  String get errorBackupUntitledBook =>
      'Este arquivo contém um livro sem título.';

  @override
  String get errorBackupUnknownShelf =>
      'Este arquivo contém uma estante desconhecida.';

  @override
  String get errorBackupNotText => 'Este arquivo não é um texto legível.';

  @override
  String get errorBackupTooRecent =>
      'Este backup vem de uma versão mais recente do app. Atualize o app para lê-lo.';

  @override
  String get errorFileAccess => 'Não foi possível acessar o arquivo escolhido.';

  @override
  String get errorFileRead => 'Não foi possível ler o arquivo.';

  @override
  String get errorExportLocation => 'Não é possível salvar neste local.';

  @override
  String get errorImageRead => 'Não foi possível ler a imagem.';

  @override
  String get errorImageCopy => 'Não foi possível copiar a imagem.';

  @override
  String get errorImagePrepare =>
      'Não foi possível preparar a imagem para compartilhar.';

  @override
  String get errorShareFailed => 'O compartilhamento falhou.';

  @override
  String get errorInstagramFailed => 'Não foi possível abrir o Instagram.';

  @override
  String get errorPhotoAccess =>
      'Permita o acesso às fotos para salvar a imagem.';

  @override
  String get errorNotEnoughSpace => 'Espaço insuficiente no telefone.';

  @override
  String get errorImageSaveFailed => 'Não foi possível salvar a imagem.';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String get aboutSubtitle => 'Quem sou, o espírito do app, contato';

  @override
  String get aboutBy => 'por libergot';

  @override
  String get aboutWhoTitle => 'Quem sou';

  @override
  String get aboutWhoBody =>
      'Sou libergot, um desenvolvedor independente. Criei o MyBookmark porque queria um jeito simples de acompanhar minhas leituras: saber onde parei, lembrar o que achei de cada livro e compartilhar os meus favoritos.';

  @override
  String get aboutSpiritTitle => 'O espírito do app';

  @override
  String get aboutSpiritFree => 'Gratuito e sem anúncios';

  @override
  String get aboutSpiritNoAccount => 'Nenhuma conta para criar';

  @override
  String get aboutSpiritLocal => 'Seus livros ficam no seu celular';

  @override
  String get aboutSpiritNoTracking =>
      'Sem rastreamento, sem estatísticas de uso';

  @override
  String get aboutFeedbackTitle => 'Uma ideia, um bug?';

  @override
  String get aboutFeedbackBody =>
      'O MyBookmark cresce com o seu retorno. Uma função que faz falta, algo que não funciona: me escreva.';

  @override
  String get aboutFeedbackButton => 'Me escrever';

  @override
  String get aboutFeedbackSubject => 'MyBookmark: uma sugestão';

  @override
  String aboutNoMailApp(String email) {
    return 'Nenhum app de e-mail encontrado. Meu endereço foi copiado: $email';
  }

  @override
  String get aboutRateTitle => 'Gostou do MyBookmark?';

  @override
  String get aboutRateBody =>
      'Uma avaliação no Google Play ajuda outros leitores a descobrir o app. Obrigado!';

  @override
  String get aboutRateButton => 'Avaliar no Google Play';

  @override
  String get aboutWebsite => 'Site';

  @override
  String get aboutPrivacy => 'Política de privacidade';

  @override
  String get aboutLinkFailed => 'Não foi possível abrir o link.';
}
