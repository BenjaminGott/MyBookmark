import 'dart:convert';

import 'package:biblivre/data/remote/open_library_client.dart';
import 'package:biblivre/data/repositories/search_repository_open_library.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  late List<String> queries;
  late OpenLibrarySearchRepository repository;

  /// Un serveur factice qui note chaque `q` reçu et répond un livre bidon.
  void buildRepository({int cacheSize = 50}) {
    queries = <String>[];
    repository = OpenLibrarySearchRepository(
      cacheSize: cacheSize,
      client: OpenLibraryClient(
        httpClient: MockClient((request) async {
          queries.add(request.url.queryParameters['q'] ?? '');
          return http.Response(
            jsonEncode(<String, Object?>{
              'docs': <Object?>[
                <String, Object?>{'key': '/works/OL1W', 'title': 'Dune'},
              ],
            }),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }),
      ),
    );
  }

  setUp(buildRepository);

  test('normalise la saisie avant d\'appeler l\'API', () async {
    await repository.search('  Le Comte de Monte-Cristo !  ');

    expect(queries, <String>['le comte de monte cristo']);
  });

  test('n\'appelle pas l\'API en dessous de deux caractères', () async {
    expect(await repository.search('d'), isEmpty);
    expect(await repository.search(' '), isEmpty);
    expect(await repository.search('.'), isEmpty);

    expect(queries, isEmpty);
  });

  test('appelle l\'API dès deux caractères', () async {
    await repository.search('du');

    expect(queries, <String>['du']);
  });

  test('sert la même requête depuis le cache', () async {
    await repository.search('Dune');
    await repository.search('dune');
    await repository.search('DUNE !');

    expect(queries, <String>['dune'], reason: 'un seul appel réseau attendu');
  });

  test('rappelle l\'API pour une requête différente', () async {
    await repository.search('dune');
    await repository.search('dune messie');

    expect(queries, <String>['dune', 'dune messie']);
  });

  test('oublie la requête la plus ancienne quand le cache est plein', () async {
    buildRepository(cacheSize: 2);

    await repository.search('aa');
    await repository.search('bb');
    await repository.search('cc'); // « aa » sort du cache.
    await repository.search('bb'); // toujours en cache
    await repository.search('aa'); // doit repartir sur le réseau

    expect(queries, <String>['aa', 'bb', 'cc', 'aa']);
  });

  test('met aussi les résumés en cache', () async {
    final descriptions = <String>[];
    final repository = OpenLibrarySearchRepository(
      client: OpenLibraryClient(
        httpClient: MockClient((request) async {
          descriptions.add(request.url.path);
          return http.Response(
            jsonEncode(<String, Object?>{'description': 'Un résumé.'}),
            200,
            headers: <String, String>{'content-type': 'application/json'},
          );
        }),
      ),
    );

    expect(await repository.loadDescription('/works/OL1W'), 'Un résumé.');
    expect(await repository.loadDescription('/works/OL1W'), 'Un résumé.');

    expect(descriptions, <String>['/works/OL1W.json']);
  });

  test('renvoie une liste non modifiable pour éviter les surprises', () async {
    final results = await repository.search('dune');

    expect(() => results.add(results.first), throwsUnsupportedError);
  });
}
