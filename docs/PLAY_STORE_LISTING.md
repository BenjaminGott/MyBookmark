# Fiche Play Store — textes prêts à coller

Anglais (langue par défaut de la fiche) puis français (traduction ajoutée dans
*Présence sur le Play Store → Fiche principale → Gérer les traductions*).
Limites de Google : nom 30 caractères, description courte 80, description
complète 4000.

Visuels : `python3 tool/screenshots/compose.py <dossier> --lang en --store`
(et `--lang fr`) produit les 5 captures 1080 × 1920 (la 5ᵉ : la carte publiée
en story Instagram) et l'image de présentation
1024 × 500. Icône : `branding/play-store-icon-512.png`.

Vidéo : `python3 tool/screenshots/video.py` (après les captures) produit
`build/screenshots/video/mybookmark-en.mp4` et `-fr.mp4`, 1920 × 1080, 35 s.
Le Play Store n'accepte qu'un **lien YouTube** : mettre la vidéo sur YouTube
(publique ou non répertoriée, publicités désactivées), puis coller le lien dans
*Fiche principale → Vidéo*. Une vidéo par langue de fiche.

---

## English (en-US)

**App name** (30 characters max — the keyword after the dash helps search)

```
MyBookmark – Reading Tracker
```

**Short description**

```
Reading tracker & book journal: scan, rate, share your progress. No account.
```

**Full description**

```
MyBookmark is a simple reading tracker and book journal: what you're reading, where you're at, and what you thought of it.

FIND ANY BOOK IN A SECOND
Scan the barcode on the back of a book, or search Open Library and Apple Books at the same time, and add it in one tap, cover and all. Can't find it? Add it by hand, and pick a cover from your gallery.

THREE SHELVES
To read, Reading, Read: your reading list and your book log in one place. Filter your library by shelf and sort it by title, author, date added or rating.

TRACK EVERY PAGE
Enter the page you're on and see your reading progress in percent. Start and finish dates, re-reads with their own history: everything is kept. A home screen widget shows the book you're reading.

RATE AND REVIEW
Give each book a star rating and a review, to remember what you thought.

SHARE YOUR PROGRESS ON INSTAGRAM
Turn your progress into a beautiful card in the colours of the book cover. Post it straight to your Instagram story for your bookstagram, send it to any app, or save it to your gallery.

COMING FROM GOODREADS?
Import your Goodreads library in one tap: shelves, ratings, reviews and dates.

YOUR DATA STAYS YOURS
No account, no ads, no tracking. Your library lives on your phone only. Export it to a single file whenever you like, and import it on another device.

Light and dark themes. Available in English, French, Spanish, German, Italian and Portuguese.
```

---

## Français (fr-FR)

**Nom de l'application** (30 caractères au plus — le mot-clé après le tiret aide la recherche)

```
Mon marque-page – Lecture
```

**Description courte**

```
Carnet et suivi de lecture : scannez, notez, partagez votre progression.
```

**Description complète**

```
Mon marque-page est un carnet de lecture et un suivi de lecture tout simple : ce que vous lisez, où vous en êtes, ce que vous en avez pensé.

TROUVEZ UN LIVRE EN UNE SECONDE
Scannez le code-barres au dos du livre, ou cherchez dans Open Library et Apple Books en même temps, et ajoutez-le en un geste, couverture comprise. Introuvable ? Saisissez-le vous-même, et choisissez sa couverture dans votre galerie.

TROIS ÉTAGÈRES
À lire, En cours, Lu : votre pile à lire et votre journal de lecture au même endroit. Filtrez votre bibliothèque par étagère, triez-la par titre, auteur, date d'ajout ou note.

SUIVEZ CHAQUE PAGE
Indiquez la page où vous en êtes et voyez votre progression en pourcentage. Dates de début et de fin, relectures avec leur propre historique : tout est gardé. Un widget d'écran d'accueil montre le livre en cours.

NOTEZ ET COMMENTEZ
Donnez une note en étoiles et un avis à chaque livre, pour vous souvenir de ce que vous en avez pensé.

PARTAGEZ VOTRE PROGRESSION SUR INSTAGRAM
Transformez votre avancée en une jolie carte aux couleurs de la couverture. Publiez-la directement en story Instagram pour votre bookstagram, envoyez-la dans n'importe quelle application ou enregistrez-la dans votre galerie.

VOUS VENEZ DE GOODREADS ?
Importez votre bibliothèque Goodreads en un geste : étagères, notes, avis et dates.

VOS DONNÉES RESTENT À VOUS
Pas de compte, pas de publicité, pas de pistage. Votre bibliothèque reste sur votre téléphone. Exportez-la dans un fichier quand vous voulez, et importez-la sur un autre appareil.

Thèmes clair et sombre. Disponible en français, anglais, espagnol, allemand, italien et portugais.
```

---

## Mots-clés visés

Le Play Store n'a pas de champ « mots-clés » : il lit le nom, la description
courte et la description complète. Les termes que les lecteurs tapent y
figurent naturellement, sans répétition forcée (Google pénalise le
bourrage) :

- EN : reading tracker, book journal, reading list, book log, reading
  progress, bookstagram, Goodreads, barcode scanner.
- FR : suivi de lecture, carnet de lecture, journal de lecture, pile à lire,
  bookstagram, Goodreads, code-barres.

## Informations générales

| Champ | Valeur |
| --- | --- |
| Catégorie | Livres et références (Books & Reference) |
| Tags | Lecture, Livres |
| E-mail | `libergot.pro@gmail.com` |
| Site web | <https://benjamingott.github.io/mybookmark/> |
| Politique de confidentialité | <https://benjamingott.github.io/mybookmark/privacy/> |
