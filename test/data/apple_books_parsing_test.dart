import 'package:biblivre/data/remote/apple_books_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('écarte les documents sans identifiant ou sans titre', () {
    final results = AppleBooksParser.parseSearchResponse(<String, Object?>{
      'results': <Object?>[
        <String, Object?>{'trackId': 1, 'trackName': 'Dune'},
        <String, Object?>{'trackName': 'Sans identifiant'},
        <String, Object?>{'trackId': 2, 'trackName': '  '},
        'pas un objet',
      ],
    });

    expect(results.map((r) => r.olKey), <String>['apple:1']);
  });

  test('ne plante pas sur une réponse inattendue', () {
    expect(AppleBooksParser.parseSearchResponse(null), isEmpty);
    expect(AppleBooksParser.parseSearchResponse(<Object?>[]), isEmpty);
    expect(
      AppleBooksParser.parseSearchResponse(<String, Object?>{'results': 3}),
      isEmpty,
    );
  });

  test('redimensionne la couverture en gardant son adresse', () {
    expect(
      AppleBooksParser.resizeArtwork(
        'https://is1.mzstatic.com/image/thumb/a/b.jpg/100x100bb.jpg',
        600,
        900,
      ),
      'https://is1.mzstatic.com/image/thumb/a/b.jpg/600x900bb.jpg',
    );
  });

  test('lit l\'année dans la date de sortie', () {
    final result = AppleBooksParser.parseDoc(<String, Object?>{
      'trackId': 1,
      'trackName': 'Dune',
      'releaseDate': '2012-03-01T08:00:00Z',
    });

    expect(result!.firstPublishYear, 2012);
  });

  test('transforme le résumé HTML en texte', () {
    expect(
      AppleBooksParser.cleanDescription(
        '<p>L&#39;<i>épice</i> &amp; le désert.</p><p>Arrakis.</p>',
      ),
      'L\'épice & le désert.\nArrakis.',
    );
    expect(AppleBooksParser.cleanDescription('<br/>'), isNull);
    expect(AppleBooksParser.cleanDescription(12), isNull);
  });
}
