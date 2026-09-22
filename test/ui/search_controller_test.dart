import 'package:biblivre/core/cancellation.dart';
import 'package:biblivre/core/failure.dart';
import 'package:biblivre/domain/models/book_search_result.dart';
import 'package:biblivre/domain/repositories/search_repository.dart';
import 'package:biblivre/ui/providers/search_providers.dart';
import 'package:biblivre/ui/search/search_controller.dart';
import 'package:biblivre/ui/search/search_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Un dépôt de recherche sous contrôle : il note ce qu'on lui demande, met le
/// temps qu'on veut à répondre, et sait échouer sur commande.
class _FakeSearchRepository implements SearchRepository {
  _FakeSearchRepository({this.delay = Duration.zero});

  final Duration delay;
  final List<String> queries = <String>[];
  AppException? failWith;

  @override
  Future<List<BookSearchResult>> search(
    String rawQuery, {
    CancellationToken? token,
  }) async {
    queries.add(rawQuery);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    final error = failWith;
    if (error != null) {
      throw error;
    }
    if (token != null && token.isCancelled) {
      throw const RequestCancelledException();
    }
    return <BookSearchResult>[
      BookSearchResult(olKey: '/works/OL1W', title: 'Résultat de "$rawQuery"'),
    ];
  }

  @override
  Future<String?> loadDescription(String olKey, {CancellationToken? token}) async =>
      null;
}

void main() {
  late _FakeSearchRepository repository;
  late ProviderContainer container;

  ProviderContainer buildContainer(_FakeSearchRepository fake) {
    final created = ProviderContainer(
      overrides: [searchRepositoryProvider.overrideWithValue(fake)],
    );
    addTearDown(created.dispose);
    return created;
  }

  setUp(() {
    repository = _FakeSearchRepository();
    container = buildContainer(repository);
  });

  BookSearchController controller() =>
      container.read(searchControllerProvider.notifier);

  SearchState state() => container.read(searchControllerProvider);

  /// Laisse passer l'anti-rebond, puis la réponse.
  Future<void> settle([Duration extra = Duration.zero]) async {
    await Future<void>.delayed(kSearchDebounce + extra + const Duration(milliseconds: 60));
  }

  test('ne cherche rien en dessous de deux caractères', () async {
    controller().onQueryChanged('d');
    await settle();

    expect(repository.queries, isEmpty);
    expect(state().status, SearchStatus.idle);
    expect(state().query, 'd');
  });

  test('ne compte que les caractères significatifs', () async {
    // Après normalisation, « d' » ne pèse qu'une lettre.
    controller().onQueryChanged("d'");
    await settle();

    expect(repository.queries, isEmpty);
    expect(state().status, SearchStatus.idle);
  });

  test('cherche après l\'anti-rebond', () async {
    controller().onQueryChanged('dune');

    // Rien n'est encore parti : on est dans la fenêtre d'anti-rebond.
    expect(repository.queries, isEmpty);
    expect(state().isLoading, isTrue);

    await settle();

    expect(repository.queries, <String>['dune']);
    expect(state().status, SearchStatus.success);
    expect(state().results.single.title, 'Résultat de "dune"');
  });

  test('une frappe rapide ne déclenche qu\'une seule requête', () async {
    final controllerRef = controller();
    controllerRef.onQueryChanged('du');
    controllerRef.onQueryChanged('dun');
    controllerRef.onQueryChanged('dune');

    await settle();

    expect(repository.queries, <String>['dune']);
  });

  test('une requête lente est abandonnée quand la frappe reprend', () async {
    repository = _FakeSearchRepository(
      delay: const Duration(milliseconds: 200),
    );
    container = buildContainer(repository);

    controller().onQueryChanged('dune');
    await Future<void>.delayed(
      kSearchDebounce + const Duration(milliseconds: 50),
    );

    // La première requête est encore en vol quand l'utilisateur continue.
    controller().onQueryChanged('dune messie');
    await settle(const Duration(milliseconds: 250));

    expect(repository.queries, <String>['dune', 'dune messie']);
    // Seule la réponse la plus récente s'affiche.
    expect(state().results.single.title, 'Résultat de "dune messie"');
  });

  test('affiche une erreur réseau nommée', () async {
    repository.failWith = const NetworkException();

    controller().onQueryChanged('dune');
    await settle();

    expect(state().status, SearchStatus.failure);
    expect(state().error, isA<NetworkException>());
    expect(state().results, isEmpty);
  });

  test('retente la dernière recherche après une erreur', () async {
    repository.failWith = const NetworkException();
    controller().onQueryChanged('dune');
    await settle();
    expect(state().status, SearchStatus.failure);

    repository.failWith = null;
    await controller().retry();

    expect(state().status, SearchStatus.success);
    expect(repository.queries, <String>['dune', 'dune']);
  });

  test('effacer le champ remet l\'écran à zéro', () async {
    controller().onQueryChanged('dune');
    await settle();
    expect(state().results, isNotEmpty);

    controller().clear();

    expect(state().query, isEmpty);
    expect(state().results, isEmpty);
    expect(state().status, SearchStatus.idle);
  });
}
