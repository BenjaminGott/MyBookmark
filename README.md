# MyBookmark — Mon marque-page

Application de suivi de lecture pour Android (et bientôt iPhone), publiée par
libergot sous le nom **MyBookmark** en anglais et **Mon marque-page** en
français.

- Google Play : <https://play.google.com/store/apps/details?id=com.libergot.mybookmark>
- Site : <https://benjamingott.github.io/mybookmark/>

Tout reste sur le téléphone : pas de compte, pas de serveur, pas de publicité,
pas de pistage. Les informations des livres viennent des API publiques Open
Library et Apple Books ; elles sont recopiées en base au moment de l'ajout,
après quoi l'application fonctionne entièrement hors ligne.

Le dépôt et le paquet Dart s'appellent encore `biblivre`, l'ancien nom de
l'application : c'est interne et invisible pour les utilisateurs.

## Fonctionnalités

- Recherche de livres avec autocomplétion, ou scan du code-barres (ISBN), lu
  sur le téléphone sans service extérieur
- Trois étagères : « À lire », « En cours », « Lu », avec filtres et tris
- Fiche livre : couverture, résumé, note, avis, dates, relectures
- Progression : page en cours, pourcentage et barre
- Saisie manuelle d'un livre et correction des informations
- Carte de progression à partager en image (bloc ou story), avec envoi direct
  en story Instagram et enregistrement dans la galerie
- Widget d'écran d'accueil « Lecture en cours » (Android)
- Import de la bibliothèque Goodreads (CSV), export et import JSON
- Interface en français, anglais, espagnol, allemand, italien et portugais
- Thèmes clair et sombre, grandes polices et tablettes

## Stack

| Rôle | Paquet |
|---|---|
| Base locale | `drift` + `drift_flutter` (SQLite) |
| État | `flutter_riverpod` |
| Réseau | `http` (Open Library, Apple Books, sans clé) |
| Couvertures | `cached_network_image` (jamais stockées en base) |
| Scanner | `flutter_zxing` |
| Widget | `home_widget` |
| Partage | `share_plus`, `palette_generator`, `gal` |
| Fichiers | `file_picker` |
| Avis | `in_app_review` |

## Architecture

```
lib/
├─ core/      transverse : thème, erreurs nommées, liens publics
├─ domain/    modèles purs, interfaces de dépôts, logique métier
│             (aucun import de drift, http ou Flutter)
├─ data/      drift (tables, DAO), clients Open Library et Apple Books,
│             préférences, fichiers, widget
├─ l10n/      textes de l'interface (ARB) et code généré
└─ ui/        écrans, widgets, contrôleurs riverpod
```

Un widget ne fait jamais de SQL ni de HTTP : il parle à un contrôleur, qui parle
à une interface de `domain/repositories`. Seul `data/` connaît drift et `http`.
Les couches `data/` et `domain/` ne produisent jamais de texte affiché : une
erreur porte une raison (`AppErrorReason`), que l'interface traduit.

## Schéma de données

- `books` : informations recopiées à l'ajout, plus `isbn` et `is_manual`
- `reading_entries` : une par lecture, avec étagère, note, avis, dates et page
  en cours. Une seule porte `is_current` : c'est elle qui décide de l'étagère
  affichée, les précédentes gardent leur note et leur avis
- `tags` + `book_tags` : étagères personnalisées, plusieurs par livre

## Traductions

Les textes sont dans `lib/l10n/app_fr.arb` (la référence) et ses traductions
`app_en`, `app_es`, `app_de`, `app_it` et `app_pt.arb`. Après modification,
`flutter gen-l10n` régénère `AppLocalizations`. Un test vérifie que toutes les
langues ont les mêmes clés.

## Commandes

```bash
flutter pub get                      # dépendances
dart run build_runner build          # régénère le code drift
flutter analyze                      # doit rester sans avertissement
flutter test                         # toute la suite
```

## Publication

Les versions sont compilées et envoyées automatiquement par GitHub Actions :

| Branche | Destination |
|---|---|
| `dev` | Google Play, test interne |
| `main` | Google Play, production |

- Android : [docs/PUBLICATION_PLAY_STORE.md](docs/PUBLICATION_PLAY_STORE.md)
- iOS (Codemagic, TestFlight) : [docs/PUBLICATION_APP_STORE.md](docs/PUBLICATION_APP_STORE.md)
- Icônes : `python3 tool/generate_icons.py` les régénère depuis
  `branding/logo-source.jpg`.
- Captures et vidéo de présentation : `tool/screenshots/`.

## Licence

Copyright © 2026 libergot. **Tous droits réservés.**

Ce code est rendu public pour être consulté, à titre de vitrine. Il n'est
**pas** open source : aucune licence n'est accordée. Sans autorisation écrite,
il est interdit de copier, modifier, redistribuer ou publier tout ou partie de
ce code, ainsi que d'en tirer une application.

Le nom « MyBookmark », le nom « Mon marque-page », le logo et les visuels de
l'application sont également réservés.

Les bibliothèques utilisées restent sous leurs propres licences. Pour toute
demande : <libergot.pro@gmail.com>.
