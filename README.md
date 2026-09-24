# MyBookmark — Mon marque-page

Suivi de lecture personnel pour Android, publié par libergot sous le nom
**MyBookmark** en anglais et **Mon marque-page** en français (identifiant
`com.libergot.mybookmark`). Tout reste sur le téléphone : pas de compte, pas de
serveur, pas de synchronisation. Les métadonnées des livres viennent des API
publiques Open Library et Apple Books et sont recopiées en base au moment de
l'ajout — passé ce point, l'application fonctionne entièrement hors ligne.

Le dépôt et le paquet Dart s'appellent encore `biblivre`, l'ancien nom de
l'application : c'est interne et invisible pour les utilisateurs.

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
8. Partage de sa progression en carte image, en deux formats — bloc
   (1080 × 636, par défaut) et story 9:16 (1080 × 1920) — sur un dégradé tiré
   de la couverture, avec variantes claire, sombre et vive, et composition
   manuelle du dégradé ; envoi direct en story Instagram, le bloc posé en
   sticker sur son dégradé pour garder ses coins arrondis transparents ;
   enregistrement de la carte dans la galerie, album « MyBookmark »
9. Interface en français et en anglais : la langue se choisit au premier
   lancement (celle du téléphone est proposée d'office), puis dans les
   réglages

Thèmes clair et sombre.

## Traductions

Les textes de l'interface sont dans `lib/l10n/app_fr.arb` (la référence) et
`lib/l10n/app_en.arb`. Pour ajouter ou modifier un texte : l'écrire dans les
deux fichiers, puis `flutter gen-l10n` (ou simplement `flutter pub get`)
régénère `AppLocalizations`. Un test vérifie que les deux fichiers ont les
mêmes clés.

Les couches `data/` et `domain/` ne produisent jamais de texte affiché : une
erreur porte une raison (`AppErrorReason`), que l'interface traduit dans
`ui/l10n/error_text.dart`.

Le nom sous l'icône suit la langue du téléphone :
`android/app/src/main/res/values/strings.xml` (anglais) et `values-fr/`.

## Stack

| Rôle | Paquet |
|---|---|
| Base locale | `drift` + `drift_flutter` (SQLite) |
| État | `flutter_riverpod` |
| Réseau | `http` (Open Library, sans clé) |
| Couvertures | `cached_network_image` (jamais stockées en base) |
| Réglages | `shared_preferences` |
| Fichiers | `file_picker` (export/import) |
| Partage | `share_plus`, `path_provider`, `palette_generator`, `gal` |

`sqlite3_flutter_libs` n'est pas utilisé : il est marqué EOL sur pub.dev,
`drift_flutter` embarque désormais `sqlite3` 3.x.

## Architecture

```
lib/
├─ core/      transverse : thème, erreurs nommées, annulation
├─ domain/    modèles purs, interfaces de dépôts, logique métier
│             (aucun import de drift, http ou Flutter)
├─ data/      drift (tables, DAO), clients Open Library et Apple Books,
│             préférences, fichiers
├─ l10n/      textes de l'interface (ARB) et code généré
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
flutter test                         # toute la suite
```

## Produire l'APK

```bash
flutter build apk --release --split-per-abi
```

Les APK sortent dans `build/app/outputs/flutter-apk/`. Pour un téléphone
Android récent, prendre `app-arm64-v8a-release.apk` (~21 Mo).

`flutter build apk --release` seul produit un APK universel de ~60 Mo qui
contient les trois architectures ; c'est pratique si l'on ne sait pas quel
téléphone recevra le fichier. Pour un seul appareil connu :

```bash
flutter build apk --release --target-platform android-arm64
```

**Attention en changeant de commande** : `--split-per-abi` décale le code de
version (+1000 pour armeabi-v7a, +2000 pour arm64-v8a, +4000 pour x86_64). Un
APK issu de `--split-per-abi` porte donc le code 2001 là où les autres portent
1, et réinstaller par-dessus échoue avec `INSTALL_FAILED_VERSION_DOWNGRADE`. Il
faut alors désinstaller d'abord, ou s'en tenir à une seule des deux commandes.

## Installer sur un téléphone

Par câble, appareil en mode développeur et débogage USB activé :

```bash
flutter install --release
```

Sinon, copier `app-arm64-v8a-release.apk` sur le téléphone et l'ouvrir depuis le
gestionnaire de fichiers ; Android demandera d'autoriser l'installation
d'applications issues de cette source.

Compilé sur un poste sans `android/key.properties`, l'APK est signé avec la clé
de débogage : il s'installe, mais ne met pas à jour une version publiée. Les
releases GitHub, elles, sont signées avec la clé de release (APK et AAB).

## Publier

- Release GitHub : onglet Actions → « Release APK » → tag `vX.Y.Z`.
- Play Store : voir [docs/PUBLICATION_PLAY_STORE.md](docs/PUBLICATION_PLAY_STORE.md).
- Icônes : `python3 tool/generate_icons.py` les régénère depuis
  `branding/logo-source.jpg`.
