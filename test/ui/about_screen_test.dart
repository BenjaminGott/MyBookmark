import 'package:biblivre/domain/repositories/external_links.dart';
import 'package:biblivre/l10n/app_localizations.dart';
import 'package:biblivre/ui/providers/settings_providers.dart';
import 'package:biblivre/ui/settings/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Note les liens ouverts ; refuse ceux dont le schéma est dans [refused].
class _FakeLinks implements ExternalLinks {
  _FakeLinks({this.refused = const <String>{}});

  final Set<String> refused;
  final List<Uri> opened = <Uri>[];

  @override
  Future<bool> open(Uri uri) async {
    if (refused.contains(uri.scheme)) {
      return false;
    }
    opened.add(uri);
    return true;
  }
}

void main() {
  Future<void> pumpAbout(WidgetTester tester, _FakeLinks links) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [externalLinksProvider.overrideWithValue(links)],
        child: const MaterialApp(
          locale: Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AboutScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('présente l\'application et son esprit', (tester) async {
    await pumpAbout(tester, _FakeLinks());

    expect(find.text('Qui je suis'), findsOne);
    expect(find.text('Gratuite et sans publicité'), findsOne);
    expect(find.text('Vos livres restent sur votre téléphone'), findsOne);
  });

  testWidgets('ouvre la messagerie avec un objet', (tester) async {
    final links = _FakeLinks();
    await pumpAbout(tester, links);

    await tester.tap(find.text("M'écrire"));
    await tester.pump();

    final mail = links.opened.single;
    expect(mail.scheme, 'mailto');
    expect(mail.path, 'libergot.pro@gmail.com');
    expect(mail.query, 'subject=Mon%20marque-page%20%3A%20une%20suggestion');
  });

  testWidgets('sans messagerie, copie l\'adresse et le dit', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await pumpAbout(tester, _FakeLinks(refused: <String>{'mailto'}));
    await tester.tap(find.text("M'écrire"));
    await tester.pump();

    expect(copied, 'libergot.pro@gmail.com');
    expect(find.textContaining('Mon adresse est copiée'), findsOne);
  });

  testWidgets('note sur le Play Store, ou sur le site sinon', (tester) async {
    final links = _FakeLinks();
    await pumpAbout(tester, links);
    await tester.tap(find.text('Noter sur Google Play'));
    await tester.pump();
    expect(
      links.opened.single.toString(),
      'market://details?id=com.libergot.mybookmark',
    );

    final noStore = _FakeLinks(refused: <String>{'market'});
    await pumpAbout(tester, noStore);
    await tester.tap(find.text('Noter sur Google Play'));
    await tester.pump();
    expect(
      noStore.opened.single.toString(),
      'https://play.google.com/store/apps/details?id=com.libergot.mybookmark',
    );
  });

  testWidgets('ouvre la confidentialité dans la langue de l\'app', (
    tester,
  ) async {
    final links = _FakeLinks();
    await pumpAbout(tester, links);
    await tester.tap(find.text('Politique de confidentialité'));
    await tester.pump();
    expect(
      links.opened.single.toString(),
      'https://benjamingott.github.io/mybookmark/fr/privacy/',
    );
  });
}
