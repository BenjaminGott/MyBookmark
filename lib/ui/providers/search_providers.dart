import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/remote/apple_books_client.dart';
import '../../data/remote/open_library_client.dart';
import '../../data/repositories/search_repository_combined.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/services/text_normalizer.dart';

final Provider<TextNormalizer> textNormalizerProvider =
    Provider<TextNormalizer>((ref) => const TextNormalizer());

/// Un seul client HTTP pour toute l'application : les connexions sont
/// réutilisées d'une recherche à l'autre.
final Provider<http.Client> httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final Provider<OpenLibraryClient> openLibraryClientProvider =
    Provider<OpenLibraryClient>((ref) {
  return OpenLibraryClient(httpClient: ref.watch(httpClientProvider));
});

final Provider<AppleBooksClient> appleBooksClientProvider =
    Provider<AppleBooksClient>((ref) {
  return AppleBooksClient(httpClient: ref.watch(httpClientProvider));
});

/// Le cache de recherche vit ici : tant que l'application tourne, revenir sur
/// une requête déjà faite n'appelle pas le réseau.
final Provider<SearchRepository> searchRepositoryProvider =
    Provider<SearchRepository>((ref) {
  return CombinedSearchRepository(
    openLibrary: ref.watch(openLibraryClientProvider),
    appleBooks: ref.watch(appleBooksClientProvider),
    normalizer: ref.watch(textNormalizerProvider),
  );
});
