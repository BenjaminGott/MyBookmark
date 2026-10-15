# Publier sur l'App Store (iOS)

Les compilations iOS se font sur Codemagic, qui fournit les Mac
(`codemagic.yaml`, à la racine). Elles se lancent à la main depuis codemagic.io.

| Workflow | Ce qu'il fait | Compte Apple |
| --- | --- | --- |
| *iOS – vérification* | tests + compilation sans signature | non |
| *iOS – TestFlight* | tests + IPA signée, envoyée sur TestFlight | oui |

## Une fois pour toutes

1. **Apple Developer Program** (99 $/an) : developer.apple.com/programs.
2. **Identifiant** : *Certificates, Identifiers & Profiles → Identifiers → +* →
   App IDs → `com.libergot.mybookmark`.
3. **App Store Connect → Apps → +** : nom « MyBookmark », identifiant
   ci-dessus, SKU au choix (`mybookmark`).
4. **Clé d'API** : *App Store Connect → Utilisateurs et accès → Intégrations →
   API App Store Connect → +*, rôle **App Manager**. Noter l'Issuer ID et le
   Key ID, télécharger le `.p8` (une seule fois possible).
5. **Codemagic** : *Teams → Integrations → Developer Portal → Connect*, avec
   ces trois éléments, sous le nom **`mybookmark_asc`**.
6. **Lien « Noter l'application »** : une fois l'app créée, copier son
   *Apple ID* (un nombre, dans *Informations sur l'app*) dans
   `AppLinks.appStoreId` (`lib/core/app_links.dart`). Tant qu'il est vide,
   le bouton est masqué sur iPhone.

## Différences avec Android

- **Widget** : pas sur iOS (il demande une extension WidgetKit à part).
- **Story Instagram** : même bouton, passé par le presse-papiers et le lien
  `instagram-stories://` (`ios/Runner/AppDelegate.swift`).
- **Noter l'application** : page d'avis de l'App Store au lieu de Google Play.
- **iPhone seulement** : pas d'iPad pour l'instant, ce qui évite les captures
  iPad exigées par Apple.
- Les textes des autorisations (caméra, photos) et le nom sous l'icône sont
  traduits dans `ios/Runner/<langue>.lproj/InfoPlist.strings`.

## Icônes

`python3 tool/generate_icons.py` régénère aussi les icônes iOS
(`ios/Runner/Assets.xcassets/AppIcon.appiconset`).
