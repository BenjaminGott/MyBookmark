import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/cancellation.dart';
import '../../core/failure.dart';

/// Un GET qui renvoie du JSON, partagé par les clients des API de livres.
///
/// Toutes les erreurs sortent d'ici sous la forme d'une [AppException] déjà
/// rédigée en français ; ni le domaine ni l'interface ne voient jamais de
/// `SocketException`.
class JsonHttp {
  JsonHttp({http.Client? httpClient, Duration? timeout})
      : _client = httpClient ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 10);

  final http.Client _client;
  final Duration _timeout;

  Future<Object?> get(Uri uri, {CancellationToken? token}) async {
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
