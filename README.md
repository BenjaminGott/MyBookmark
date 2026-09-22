# Biblivre

Suivi de lecture personnel pour Android. Tout reste sur le téléphone : pas de
compte, pas de serveur, pas de synchronisation. Les métadonnées des livres
viennent de l'API publique Open Library et sont recopiées en base au moment de
l'ajout — passé ce point, l'application fonctionne entièrement hors ligne.

## Fonctionnalités

1. Recherche avec autocomplétion (anti-rebond de 250 ms, annulation de la
   requête précédente, cache en mémoire)
2. Ajout d'un livre dans « À lire », « En cours » ou « Lu »
3. Ma bibliothèque : filtrable par étagère, triable par titre, auteur, date
   d'ajout et note
4. Fiche livre : grande couverture, résumé, note en étoiles, avis libre, dates
   de début et de fin, historique des relectures
5. Progression : saisie de la page en cours, pourcentage et barre
6. Saisie manuelle d'un livre, et correction des métadonnées fausses
7. Export et import JSON de toute la base

Thèmes clair et sombre, interface intégralement en français.

## Stack

| Rôle | Paquet |
|---|---|
| Base locale | `drift` + `drift_flutter` (SQLite) |
| État | `flutter_riverpod` |
| Réseau | `http` (Open Library, sans clé) |
| Couvertures | `cached_network_image` (jamais stockées en base) |
| Réglages | `shared_preferences` |
| Fichiers | `file_picker` (export/import) |

`sqlite3_flutter_libs` n'est pas utilisé : il est marqué EOL sur pub.dev,
`drift_flutter` embarque désormais `sqlite3` 3.x.

## Architecture

```
lib/
├─ core/      transverse : thème, erreurs nommées, formats, annulation
├─ domain/    modèles purs, interfaces de dépôts, logique métier
│             (aucun import de drift, http ou Flutter)
├─ data/      drift (tables, DAO), client Open Library, préférences, fichiers
└─ ui/        écrans, widgets, contrôleurs riverpod
```

Un widget ne fait jamais de SQL ni de HTTP : il parle à un contrôleur, qui parle
à une interface de `domain/repositories`. Seul `data/` connaît drift et `http`.

## Schéma de données

- `books` — métadonnées recopiées à l'ajout, plus `isbn` (prévu pour le scan de
  code-barres) et `is_manual`
- `reading_entries` — une par lecture, avec étagère, note, avis, dates et page
  en cours. Une seule porte `is_current` : c'est elle qui décide de l'étagère
  affichée, les précédentes gardent leur note et leur avis
- `tags` + `book_tags` — étagères personnalisées, plusieurs par livre

Prévu pour la suite sans migration douloureuse : statistiques mensuelles
(`finished_at` est indexé), défi de lecture annuel (clé déjà en place dans les
préférences), citations, recherche locale en FTS5, scan ISBN.

## Commandes

```bash
flutter pub get                      # dépendances
dart run build_runner build          # régénère le code drift
flutter analyze                      # doit rester sans avertissement
flutter test                         # 166 tests
```

## Produire l'APK

```bash
flutter build apk --release --split-per-abi
```

Les APK sortent dans `build/app/outputs/flutter-apk/`. Pour un téléphone
Android récent, prendre `app-arm64-v8a-release.apk` (~21 Mo).

`flutter build apk --release` seul produit un APK universel de ~60 Mo qui
contient les trois architectures ; c'est pratique si l'on ne sait pas quel
téléphone recevra le fichier.

## Installer sur un téléphone

Par câble, appareil en mode développeur et débogage USB activé :

```bash
flutter install --release
```

Sinon, copier `app-arm64-v8a-release.apk` sur le téléphone et l'ouvrir depuis le
gestionnaire de fichiers ; Android demandera d'autoriser l'installation
d'applications issues de cette source.

L'APK est signé avec la clé de débogage : il s'installe sans problème, mais ne
peut pas être publié sur le Play Store en l'état.
