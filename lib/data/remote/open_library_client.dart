import 'package:http/http.dart' as http;

import '../../core/cancellation.dart';
import '../../core/failure.dart';
import '../../domain/models/book_search_result.dart';
import '../../domain/services/isbn.dart';
import 'dto/ol_search_response.dart';
import 'json_http.dart';

/// Accès à l'API publique d'Open Library : pas de clé, pas de compte.
///
/// Les erreurs réseau sont traduites par [JsonHttp] : ce client ne voit que
/// des [AppException] déjà rédigées en français.
class OpenLibraryClient {
  OpenLibraryClient({http.Client? httpClient, Duration? timeout})
    : _http = JsonHttp(httpClient: httpClient, timeout: timeout);

  static const String _host = 'openlibrary.org';

  /// Les seuls champs dont l'application a besoin : demander moins, c'est une
  /// réponse plus courte à télécharger sur un réseau mobile.
  static const String _searchFields =
      'title,author_name,number_of_pages_median,cover_i,first_publish_year,key';

  final JsonHttp _http;

  /// Cherche des livres. [normalizedQuery] est déjà passé par TextNormalizer.
  ///
  /// Renvoie une liste vide si la recherche n'aboutit à rien — ce n'est pas
  /// une erreur, juste un résultat vide que l'interface sait afficher.
  Future<List<BookSearchResult>> search(
    String normalizedQuery, {
    int limit = 20,
    CancellationToken? token,
  }) async {
    if (normalizedQuery.isEmpty) {
      return const <BookSearchResult>[];
    }

    // Un ISBN (tapé ou scanné) se cherche tel quel : la recherche plein
    // texte le trouverait moins sûrement.
    final isbn = Isbn.fromQuery(normalizedQuery);
    final uri = Uri.https(_host, '/search.json', <String, String>{
      if (isbn != null) 'isbn': isbn else 'q': normalizedQuery,
      'fields': _searchFields,
      'limit': '$limit',
    });

    final body = await _http.get(uri, token: token);
    return OpenLibraryParser.parseSearchResponse(body);
  }

  /// Récupère le résumé d'une œuvre, recopié en base au moment de l'ajout.
  ///
  /// Renvoie `null` quand l'œuvre n'a pas de résumé : beaucoup n'en ont pas.
  Future<String?> fetchDescription(
    String olKey, {
    CancellationToken? token,
  }) async {
    final path = olKey.startsWith('/') ? olKey : '/$olKey';
    final uri = Uri.https(_host, '$path.json');

    try {
      final body = await _http.get(uri, token: token);
      return OpenLibraryParser.parseWorkDescription(body);
    } on ServerException catch (error) {
      // Une œuvre inconnue ne doit pas empêcher d'ajouter le livre : on ajoute
      // sans résumé plutôt que d'échouer.
      if (error.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  void close() => _http.close();
}
