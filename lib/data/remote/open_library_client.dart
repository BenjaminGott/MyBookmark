import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/cancellation.dart';
import '../../core/failure.dart';
import '../../domain/models/book_search_result.dart';
import 'dto/ol_search_response.dart';

/// Accès à l'API publique d'Open Library : pas de clé, pas de compte.
///
/// C'est le seul endroit de l'application qui parle au réseau. Toutes les
/// erreurs sortent d'ici sous la forme d'une [AppException] déjà rédigée en
/// français ; ni le domaine ni l'interface ne voient jamais de `SocketException`.
class OpenLibraryClient {
  OpenLibraryClient({http.Client? httpClient, Duration? timeout})
      : _client = httpClient ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 10);

  static const String _host = 'openlibrary.org';

  /// Les seuls champs dont l'application a besoin : demander moins, c'est une
  /// réponse plus courte à télécharger sur un réseau mobile.
  static const String _searchFields =
      'title,author_name,number_of_pages_median,cover_i,first_publish_year,key';

  final http.Client _client;
  final Duration _timeout;

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

    final uri = Uri.https(_host, '/search.json', <String, String>{
      'q': normalizedQuery,
      'fields': _searchFields,
      'limit': '$limit',
    });

    final body = await _get(uri, token: token);
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
      final body = await _get(uri, token: token);
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

  Future<Object?> _get(Uri uri, {CancellationToken? token}) async {
    if (token != null && token.isCancelled) {
      throw const RequestCancelledException();
    }

    http.StreamedResponse response;
    try {
      final request = http.Request('GET', uri)
        ..headers['Accept'] = 'application/json'
        // Open Library demande poliment d'identifier les clients.
        ..headers['User-Agent'] = 'Biblivre/1.0 (application de lecture locale)';

      response = await _withCancellation(
        _client.send(request).timeout(_timeout),
        token,
      );
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    } on HandshakeException {
      throw const NetworkException();
    } on TimeoutException {
      throw const RequestTimeoutException();
    }

    final bytes = await _withCancellation(
      _readBody(response, token),
      token,
    );

    if (response.statusCode != 200) {
      throw ServerException(response.statusCode);
    }

    try {
      return jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw const MalformedResponseException();
    }
  }

  /// Lit le corps de la réponse en coupant la connexion dès l'annulation.
  Future<List<int>> _readBody(
    http.StreamedResponse response,
    CancellationToken? token,
  ) async {
    final bytes = <int>[];
    final completer = Completer<List<int>>();

    late StreamSubscription<List<int>> subscription;
    subscription = response.stream.listen(
      bytes.addAll,
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(bytes);
        }
      },
      onError: (Object error) {
        if (!completer.isCompleted) {
          completer.completeError(const NetworkException());
        }
      },
      cancelOnError: true,
    );

    if (token != null) {
      unawaited(
        token.whenCancelled.then((_) async {
          await subscription.cancel();
          if (!completer.isCompleted) {
            completer.completeError(const RequestCancelledException());
          }
        }),
      );
    }

    try {
      return await completer.future.timeout(_timeout);
    } on TimeoutException {
      await subscription.cancel();
      throw const RequestTimeoutException();
    }
  }

  /// Fait échouer [operation] dès que le jeton est annulé, sans l'attendre.
  Future<T> _withCancellation<T>(
    Future<T> operation,
    CancellationToken? token,
  ) {
    if (token == null) {
      return operation;
    }
    return Future.any(<Future<T>>[
      operation,
      token.whenCancelled.then<T>(
        (_) => throw const RequestCancelledException(),
      ),
    ]);
  }

  void close() => _client.close();
}
