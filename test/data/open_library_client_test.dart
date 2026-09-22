import 'dart:convert';
import 'dart:io';

import 'package:biblivre/core/cancellation.dart';
import 'package:biblivre/core/failure.dart';
import 'package:biblivre/data/remote/open_library_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object? body) => http.Response(
      jsonEncode(body),
      200,
      headers: <String, String>{'content-type': 'application/json'},
    );

void main() {
  group('search', () {
    test('interroge la bonne URL avec les champs attendus', () async {
      late Uri captured;
      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          captured = request.url;
          return _json(<String, Object?>{'docs': <Object?>[]});
        }),
      );

      await client.search('le comte de monte cristo', limit: 20);

      expect(captured.host, 'openlibrary.org');
      expect(captured.path, '/search.json');
      expect(captured.queryParameters['q'], 'le comte de monte cristo');
      expect(captured.queryParameters['limit'], '20');
      expect(
        captured.queryParameters['fields'],
        'title,author_name,number_of_pages_median,cover_i,'
        'first_publish_year,key',
      );
    });

    test('renvoie les livres lus dans la réponse', () async {
      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          return _json(<String, Object?>{
            'docs': <Object?>[
              <String, Object?>{
                'key': '/works/OL893415W',
                'title': 'Dune',
                'author_name': <String>['Frank Herbert'],
              },
            ],
          });
        }),
      );

      final results = await client.search('dune');
      expect(results.single.title, 'Dune');
    });

    test('n\'appelle pas le réseau sur une requête vide', () async {
      var called = false;
      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          called = true;
          return _json(<String, Object?>{'docs': <Object?>[]});
        }),
      );

      expect(await client.search(''), isEmpty);
      expect(called, isFalse);
    });

    test('traduit une absence de réseau', () async {
      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          throw const SocketException('pas de route vers l\'hôte');
        }),
      );

      await expectLater(
        client.search('dune'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('traduit une erreur serveur', () async {
      final client = OpenLibraryClient(
        httpClient: MockClient((request) async => http.Response('oups', 503)),
      );

      await expectLater(
        client.search('dune'),
        throwsA(
          isA<ServerException>()
              .having((error) => error.statusCode, 'statusCode', 503),
        ),
      );
    });

    test('traduit une réponse illisible', () async {
      final client = OpenLibraryClient(
        httpClient: MockClient((request) async => http.Response('<html>', 200)),
      );

      await expectLater(
        client.search('dune'),
        throwsA(isA<MalformedResponseException>()),
      );
    });

    test('traduit un délai dépassé', () async {
      final client = OpenLibraryClient(
        timeout: const Duration(milliseconds: 30),
        httpClient: MockClient((request) async {
          await Future<void>.delayed(const Duration(seconds: 2));
          return _json(<String, Object?>{'docs': <Object?>[]});
        }),
      );

      await expectLater(
        client.search('dune'),
        throwsA(isA<RequestTimeoutException>()),
      );
    });
  });

  group('annulation', () {
    test('abandonne une requête annulée avant l\'envoi', () async {
      var called = false;
      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          called = true;
          return _json(<String, Object?>{'docs': <Object?>[]});
        }),
      );

      final token = CancellationToken()..cancel();

      await expectLater(
        client.search('dune', token: token),
        throwsA(isA<RequestCancelledException>()),
      );
      expect(called, isFalse);
    });

    test('abandonne une requête annulée en vol', () async {
      final token = CancellationToken();
      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          // La frappe suivante arrive pendant que le serveur réfléchit.
          token.cancel();
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return _json(<String, Object?>{'docs': <Object?>[]});
        }),
      );

      await expectLater(
        client.search('dune', token: token),
        throwsA(isA<RequestCancelledException>()),
      );
    });
  });

  group('fetchDescription', () {
    test('construit l\'URL de l\'œuvre à partir de sa clé', () async {
      late Uri captured;
      final client = OpenLibraryClient(
        httpClient: MockClient((request) async {
          captured = request.url;
          return _json(<String, Object?>{'description': 'Un résumé.'});
        }),
      );

      final description = await client.fetchDescription('/works/OL893415W');

      expect(captured.toString(),
          'https://openlibrary.org/works/OL893415W.json');
      expect(description, 'Un résumé.');
    });

    test('renvoie null quand l\'œuvre est introuvable', () async {
      final client = OpenLibraryClient(
        httpClient:
            MockClient((request) async => http.Response('not found', 404)),
      );

      expect(await client.fetchDescription('/works/OL1W'), isNull);
    });

    test('remonte les autres erreurs serveur', () async {
      final client = OpenLibraryClient(
        httpClient: MockClient((request) async => http.Response('oups', 500)),
      );

      await expectLater(
        client.fetchDescription('/works/OL1W'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
