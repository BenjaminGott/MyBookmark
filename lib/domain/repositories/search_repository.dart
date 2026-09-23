import '../../core/cancellation.dart';
import '../models/book_search_result.dart';

/// Nombre minimum de caractères, après normalisation, avant d'interroger l'API.
///
/// En dessous, la recherche renverrait des milliers de résultats sans intérêt
/// et consommerait du réseau pour rien.
const int kMinQueryLength = 2;

/// Recherche de livres auprès de sources distantes.
///
/// L'interface vit dans le domaine ; son implémentation, qui interroge Open
/// Library et Apple Books, dans `data`. Les écrans ne dépendent que de ce
/// contrat.
abstract class SearchRepository {
  /// Cherche des livres à partir du texte brut tapé par l'utilisateur.
  ///
  /// La normalisation est faite ici : l'appelant passe la saisie telle quelle.
  /// Le flux émet une première liste dès qu'une source répond, puis la liste
  /// complétée quand l'autre arrive ; la dernière émission est la liste
  /// définitive. Une requête trop courte émet une seule liste vide.
  Stream<List<BookSearchResult>> search(
    String rawQuery, {
    CancellationToken? token,
  });

  /// Récupère le résumé d'une œuvre, ou `null` s'il n'y en a pas.
  Future<String?> loadDescription(String olKey, {CancellationToken? token});
}
