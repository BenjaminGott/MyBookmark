import 'package:flutter/widgets.dart';
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

/// La boutique Apple Books à interroger : celle de la région du téléphone,
/// ou à défaut celle qui correspond à sa langue.
///
/// La langue choisie dans l'app n'entre pas en compte : on peut lire en
/// français en Belgique, et c'est la boutique belge qui a les bonnes éditions.
final Provider<String> bookStoreCountryProvider = Provider<String>((ref) {
  final device = WidgetsBinding.instance.platformDispatcher.locale;
  return storeCountry(
    deviceCountry: device.countryCode,
    language: device.languageCode,
  );
});

/// Le pays de boutique à partir de la région du téléphone et de la langue.
String storeCountry({required String? deviceCountry, required String language}) {
  final region = deviceCountry?.toUpperCase();
  if (region != null && RegExp(r'^[A-Z]{2}$').hasMatch(region)) {
    return region;
  }
  return switch (language) {
    'fr' => 'FR',
    'es' => 'ES',
    'de' => 'DE',
    'it' => 'IT',
    'pt' => 'BR',
    _ => 'US',
  };
}

final Provider<AppleBooksClient> appleBooksClientProvider =
    Provider<AppleBooksClient>((ref) {
  return AppleBooksClient(
    httpClient: ref.watch(httpClientProvider),
    country: ref.watch(bookStoreCountryProvider),
  );
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
