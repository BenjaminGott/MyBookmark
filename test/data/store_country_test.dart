import 'package:biblivre/data/remote/apple_books_client.dart';
import 'package:biblivre/ui/providers/search_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('storeCountry', () {
    test('prend la région du téléphone', () {
      expect(storeCountry(deviceCountry: 'BE', language: 'fr'), 'BE');
      expect(storeCountry(deviceCountry: 'de', language: 'de'), 'DE');
      expect(storeCountry(deviceCountry: 'US', language: 'es'), 'US');
    });

    test('retombe sur la langue sans région exploitable', () {
      expect(storeCountry(deviceCountry: null, language: 'fr'), 'FR');
      expect(storeCountry(deviceCountry: null, language: 'it'), 'IT');
      expect(storeCountry(deviceCountry: null, language: 'pt'), 'BR');
      // « 419 » : l'Amérique latine, région numérique sans boutique.
      expect(storeCountry(deviceCountry: '419', language: 'es'), 'ES');
      expect(storeCountry(deviceCountry: null, language: 'ja'), 'US');
    });
  });

  test('AppleBooksClient interroge la boutique de son pays', () async {
    Uri? asked;
    final client = AppleBooksClient(
      country: 'DE',
      httpClient: MockClient((request) async {
        asked = request.url;
        return http.Response('{"results": []}', 200);
      }),
    );

    await client.search('faust');

    expect(asked!.queryParameters['country'], 'DE');
    // L'API n'accepte que l'anglais et le japonais : rien n'est envoyé.
    expect(asked!.queryParameters.containsKey('lang'), isFalse);
  });
}
