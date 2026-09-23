import 'dart:async';
import 'dart:convert';

import 'package:biblivre/core/failure.dart';
import 'package:biblivre/data/remote/apple_books_client.dart';
import 'package:biblivre/data/remote/open_library_client.dart';
import 'package:biblivre/data/repositories/search_repository_combined.dart';
import 'package:biblivre/domain/models/book_search_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object? body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: <String, String>{'content-type': 'application/json'},
    );

Map<String, Object?> _olDune = <String, Object?>{
  'key': '/works/OL893415W',
  'title': 'Dune',
  'author_name': <String>['Frank Herbert'],
  'number_of_pages_median': 658,
  'cover_i': 8231856,
  'first_publish_year': 1965,
};

Map<String, Object?> _appleDune = <String, Object?>{
  'trackId': 42,
  'trackName': 'Dune - Tome 1',
  'artistName': 'Frank Herbert',
  'releaseDate': '2012-03-01T08:00:00Z',
  'artworkUrl100':
      'https://is1-ssl.mzstatic.com/image/thumb/x/v4/cover.jpg/100x100bb.jpg',
  'description': 'Sur <b>Arrakis</b>,<br>la planète des sables.',
};

Map<String, Object?> _appleOther = <String, Object?>{
  'trackId': 7,
  'trackName': 'Les Enfants de Dune',
  'artistName': 'Frank Herbert',
};

void main() {
  late List<String> olQueries;
  late List<String> appleQueries;

  /// Des réponses par défaut que chaque test peut remplacer.
  late Future<http.Response> Function() olResponse;
  late Future<http.Response> Function() appleResponse;

  CombinedSearchRepository build({int cacheSize = 50}) {
    return CombinedSearchRepository(
      cacheSize: cacheSize,
      openLibrary: OpenLibraryClient(
        httpClient: MockClient((request) {
          olQueries.add(request.url.queryParameters['q'] ?? request.url.path);
          return olResponse();
        }),
      ),
      appleBooks: AppleBooksClient(
        httpClient: MockClient((request) {
          appleQueries.add(request.url.queryParameters['term'] ?? '');
          return appleResponse();
        }),
      ),
    );
  }

  setUp(() {
    olQueries = <String>[];
    appleQueries = <String>[];
    olResponse = () async => _json(<String, Object?>{
          'docs': <Object?>[_olDune],
        });
    appleResponse = () async => _json(<String, Object?>{
          'results': <Object?>[_appleDune, _appleOther],
        });
  });

  test('normalise la saisie avant d\'appeler les deux API', () async {
    await build().search('  Le Comte de Monte-Cristo !  ').last;

    expect(olQueries, <String>['le comte de monte cristo']);
    expect(appleQueries, <String>['le comte de monte cristo']);
  });

  test('n\'appelle aucune API en dessous de deux caractères', () async {
    final repository = build();

    expect(await repository.search('d').last, isEmpty);
    expect(await repository.search(' ').last, isEmpty);

    expect(olQueries, isEmpty);
    expect(appleQueries, isEmpty);
  });

  test('fusionne un même livre trouvé des deux côtés', () async {
    final results = await build().search('dune').last;

    expect(results, hasLength(2));
    final dune = results.first;
    // Open Library apporte la clé, les pages et l'année…
    expect(dune.olKey, '/works/OL893415W');
    expect(dune.pageCount, 658);
    expect(dune.firstPublishYear, 1965);
    expect(dune.coverId, 8231856);
    // … Apple Books la couverture rapide et le résumé en français.
    expect(
      dune.coverUrl(),
      'https://is1-ssl.mzstatic.com/image/thumb/x/v4/cover.jpg/200x300bb.jpg',
    );
    expect(
      dune.coverUrl(CoverSize.large),
      'https://is1-ssl.mzstatic.com/image/thumb/x/v4/cover.jpg/600x900bb.jpg',
    );
    expect(dune.description, 'Sur Arrakis,\nla planète des sables.');

    // Un livre qu'Open Library ne connaît pas garde une clé Apple.
    expect(results.last.olKey, 'apple:7');
    expect(results.last.isOpenLibraryWork, isFalse);
  });

  test('affiche la source la plus rapide sans attendre l\'autre', () async {
    final slowOpenLibrary = Completer<http.Response>();
    olResponse = () => slowOpenLibrary.future;

    final emissions = <List<BookSearchResult>>[];
    final done = build().search('dune').forEach(emissions.add);
    await pumpEventQueue();

    expect(emissions, hasLength(1));
    expect(emissions.single.map((r) => r.olKey), <String>['apple:42', 'apple:7']);

    slowOpenLibrary.complete(_json(<String, Object?>{
      'docs': <Object?>[_olDune],
    }));
    await done;

    // L'ordre affiché ne bouge pas : le livre reconnu est complété sur place.
    expect(
      emissions.last.map((r) => r.olKey),
      <String>['/works/OL893415W', 'apple:7'],
    );
    expect(emissions.last.first.title, 'Dune - Tome 1');
  });

  test('se contente d\'Open Library quand Apple Books est en panne', () async {
    appleResponse = () async => _json(<String, Object?>{}, 503);
    final repository = build();

    final results = await repository.search('dune').last;
    expect(results.single.olKey, '/works/OL893415W');

    // Une liste incomplète n'est pas mise en cache.
    await repository.search('dune').last;
    expect(olQueries, hasLength(2));
  });

  test('raconte l\'erreur quand les deux sources sont en panne', () async {
    olResponse = () async => _json(<String, Object?>{}, 500);
    appleResponse = () async => throw http.ClientException('hors ligne');

    await expectLater(
      build().search('dune').last,
      throwsA(isA<ServerException>()),
    );
  });

  test('sert la même requête depuis le cache', () async {
    final repository = build();

    await repository.search('Dune').last;
    await repository.search('dune').last;
    await repository.search('DUNE !').last;

    expect(olQueries, <String>['dune'], reason: 'un seul appel réseau attendu');
    expect(appleQueries, <String>['dune']);
  });

  test('oublie la requête la plus ancienne quand le cache est plein', () async {
    final repository = build(cacheSize: 2);

    await repository.search('aa').last;
    await repository.search('bb').last;
    await repository.search('cc').last; // « aa » sort du cache.
    await repository.search('bb').last; // toujours en cache
    await repository.search('aa').last; // doit repartir sur le réseau

    expect(olQueries, <String>['aa', 'bb', 'cc', 'aa']);
  });

  test('met aussi les résumés en cache', () async {
    olResponse =
        () async => _json(<String, Object?>{'description': 'Un résumé.'});
    final repository = build();

    expect(await repository.loadDescription('/works/OL1W'), 'Un résumé.');
    expect(await repository.loadDescription('/works/OL1W'), 'Un résumé.');

    expect(olQueries, <String>['/works/OL1W.json']);
  });

  test('ne demande pas de résumé à Open Library pour un livre Apple', () async {
    expect(await build().loadDescription('apple:42'), isNull);
    expect(olQueries, isEmpty);
  });

  test('renvoie une liste non modifiable pour éviter les surprises', () async {
    final results = await build().search('dune').last;

    expect(() => results.add(results.first), throwsUnsupportedError);
  });
}
