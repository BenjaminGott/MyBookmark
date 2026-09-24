# Publier MyBookmark (Mon marque-page) sur le Play Store

Tout ce qu'il faut faire, dans l'ordre, pour passer des releases GitHub à une
publication sur Google Play. Les cases déjà faites sont cochées.

Les règles de Google (nombre de testeurs, durée du test, niveau d'API minimal)
changent régulièrement : la Play Console affiche toujours les exigences en
vigueur, c'est elle qui fait foi.

---

## 1. Déjà en place dans le projet

- [x] **Identifiant de l'application** : `com.libergot.mybookmark`. C'est le
      « nom du package » demandé par la Play Console. Définitif une fois
      publié, il ne pourra plus jamais changer. (Les releases GitHub jusqu'à
      la v1.2.2 portaient `com.benjamin.biblivre` : ce sont pour Android une
      autre application, qui ne se met pas à jour vers celle-ci.)
- [x] **Nom de l'application** : « MyBookmark » en anglais, « Mon
      marque-page » en français ; l'interface existe dans les deux langues.
- [x] **Clé de release** commune à toutes les machines, dans les secrets GitHub
      (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
      `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`). Le fichier `.p12` et son mot
      de passe sont sauvegardés hors du dépôt.
- [x] **Icône** de l'application (adaptative, thématique Android 13, et
      classique), générée par `tool/generate_icons.py`.
- [x] **Icône du Play Store** 512 × 512 : `branding/play-store-icon-512.png`.
- [x] **AAB** : le workflow « Release APK » produit `mybookmark-vX.Y.Z.aab` à côté
      de l'APK. C'est ce fichier qu'on envoie au Play Store.

## 2. Avant de commencer

- [ ] **Vérifier le nom.** Chercher « MyBookmark » et « Mon marque-page » sur
      le Play Store et sur le web, pour éviter une confusion avec une app
      existante ; le nom de la fiche peut au besoin différer du nom de l'app.
- [ ] **Préparer 12 testeurs** (amis, famille) avec un compte Google et un
      téléphone Android : ils seront nécessaires à l'étape 6.

## 3. Créer le compte développeur

### Personnel ou organisation ?

Le type de compte se choisit à la création et ne se change pas ensuite.

| | Compte personnel | Compte organisation |
| --- | --- | --- |
| Pour qui | un particulier | une entreprise (micro-entreprise comprise) |
| Pièces demandées | pièce d'identité | numéro D-U-N-S (gratuit, obtenu à partir du SIRET) |
| Nom affiché sous l'app | nom de développeur choisi | nom légal de l'entreprise |
| Test fermé 12 testeurs / 14 jours | **obligatoire** | non exigé |
| Adresse publique | seulement si l'app est payante ou a des achats intégrés | celle de l'entreprise |

Pour un projet personnel et gratuit, le compte **personnel** suffit. Si une
entreprise est créée plus tard, on ouvre un compte organisation et on y
**transfère** les applications (procédure prévue par Google) : elles gardent
leurs utilisateurs, leurs avis et leurs mises à jour.

### Quel compte Google ?

Le compte développeur appartient au compte Google qui le crée ; une seule
inscription (25 $) permet de publier **autant d'applications qu'on veut**.

- Mieux vaut un compte Google **dédié** à la publication plutôt que son compte
  personnel. Un compte Google peut être créé avec une adresse qui n'est pas
  Gmail : si un nom de domaine existe déjà, `contact@mondomaine.fr` peut
  servir d'identifiant.
- L'**e-mail de contact public** affiché sur le Play Store est distinct de
  l'adresse de connexion, et se change à tout moment dans la console : on peut
  commencer avec une adresse Gmail et passer à `contact@mondomaine.fr` plus
  tard.
- D'autres personnes (ou d'autres adresses à soi) peuvent être invitées dans la
  console avec des droits choisis (*Utilisateurs et autorisations*).

### Inscription

1. Aller sur <https://play.google.com/console>, connecté avec le compte Google
   choisi, et choisir le type de compte.
2. Payer les frais d'inscription (25 $, une seule fois).
3. Choisir le **nom de développeur** : c'est lui qui apparaît sous le nom de
   l'app sur le Play Store. Un nom de marque est possible (« Hibou Studio »),
   à condition de ne pas se faire passer pour une autre entreprise.
4. Vérifier son identité (pièce d'identité) et valider un téléphone Android
   depuis l'application Play Console.

## 4. Préparer ce que Google demande

### Politique de confidentialité

Une URL publique est obligatoire, même si l'application ne collecte rien.

**En ligne :** <https://benjamingott.github.io/mybookmark/confidentialite/>,
publiée depuis le dépôt public `BenjaminGott/BenjaminGott.github.io` (le site
des applications, avec la page <https://benjamingott.github.io/mybookmark/>).
Les anciennes adresses `/biblivre/…` y redirigent.
La mettre à jour si l'app change sa façon de traiter les données. Elle dit, en
substance :

- les livres, lectures et avis sont stockés **uniquement sur le téléphone** ;
- l'application envoie les termes de recherche à **Open Library** et à
  **Apple Books** (API de recherche iTunes), et télécharge les couvertures
  depuis ces deux services ; aucune autre donnée ne quitte l'appareil ;
- une couverture choisie dans la galerie est copiée dans l'application, et
  n'est envoyée nulle part ;
- le partage (feuille de partage, story Instagram) n'a lieu qu'à la demande de
  l'utilisateur ;
- pas de compte, pas de publicité, pas de statistiques ;
- une adresse de contact.

La même URL sert à passer l'app Meta (ID `2201363724596999`) en mode **Live**
sur <https://developers.facebook.com>, ce qui garantit que le partage en story
fonctionne pour tout le monde. Son nom peut y devenir « MyBookmark » : seul
l'identifiant compte pour le partage.

### Fiche du Play Store

| Élément | Format | État |
| --- | --- | --- |
| Nom de l'application | 30 caractères max | « Mon marque-page » (fr), « MyBookmark » (en) |
| Description courte | 80 caractères max | à écrire, en français et en anglais |
| Description complète | 4000 caractères max | à écrire, en français et en anglais (le README est une bonne base) |
| Icône | PNG 512 × 512 | `branding/play-store-icon-512.png` |
| Image de présentation | PNG ou JPEG 1024 × 500 | à créer |
| Captures d'écran téléphone | au moins 2, format 9:16 conseillé | à faire sur le téléphone |
| E-mail de contact | public | `libergot.pro@gmail.com` |

La fiche se traduit dans la console (*Présence sur le Play Store → Fiche
principale → Gérer les traductions*) : choisir le français comme langue par
défaut, puis ajouter l'anglais. Les captures d'écran peuvent aussi être faites
dans chaque langue (Réglages → Langue).

### Questionnaires de la console

- **Sécurité des données** : aucune donnée collectée ni partagée par
  l'application. Les recherches vers Open Library et Apple Books ne sont liées
  à aucune identité, et aucune donnée n'est conservée par l'application hors
  du téléphone.
- **Classification du contenu** : questionnaire IARC, application de catalogue
  sans contenu sensible, la note sera « Tout public » (PEGI 3).
- **Public cible** : 13 ans et plus, pour ne pas relever des règles
  spécifiques aux enfants.
- **Publicités** : non.
- **Accès à l'application** : aucune connexion requise.

## 5. Signature : choisir la bonne option

Au premier envoi, la console propose **Play App Signing** : Google conserve la
clé qui signe l'application distribuée, et on ne lui envoie que des fichiers
signés avec une « clé d'importation ».

- **Option recommandée : donner notre clé à Google.** Dans *Configuration →
  Intégrité de l'application → Signature*, choisir d'utiliser une clé
  existante et suivre la procédure (outil PEPK fourni par Google) avec le
  fichier `.p12`. L'application du Play Store et les APK des releases GitHub
  portent alors la même signature : un utilisateur peut passer de l'un à
  l'autre sans désinstaller.
- **Option par défaut : laisser Google générer la clé.** Plus simple, mais les
  APK GitHub et la version Play Store deviennent incompatibles : passer de
  l'un à l'autre imposera de désinstaller, donc de perdre sa bibliothèque.

Ce choix est **définitif** : le faire avant le premier envoi.

## 6. Test fermé (obligatoire pour un compte personnel)

1. *Tester → Test fermé → Créer un canal*.
2. Envoyer l'AAB de la dernière release GitHub (`mybookmark-vX.Y.Z.aab`).
3. Ajouter les adresses des testeurs, leur envoyer le lien d'inscription.
4. Garder **au moins 12 testeurs inscrits pendant 14 jours d'affilée**.
5. Corriger ce qui remonte ; chaque nouvel envoi repasse par une release
   GitHub (voir étape 8).

## 7. Passer en production

Une fois le test fermé terminé, *Tableau de bord → Demander l'accès à la
production*. Google pose quelques questions sur le test, puis examine
l'application (de quelques heures à quelques jours). Ensuite : *Production →
Créer une version*, envoyer l'AAB, choisir les pays, publier.

## 8. À chaque nouvelle version

1. Dans `pubspec.yaml`, augmenter `version:`. Le nombre après le `+` doit
   **toujours augmenter** (le Play Store refuse un numéro déjà utilisé) :
   `1.3.0+6` → `1.4.0+7`.
2. Merger dans `main`, puis lancer *Actions → Release APK* avec le tag
   `v1.4.0`.
3. Télécharger `mybookmark-v1.4.0.aab` depuis la release et l'envoyer dans la
   console (test fermé ou production).

### Plus tard : envoi automatique

Le workflow peut envoyer l'AAB directement au Play Store. Il faudra :

1. créer un compte de service dans Google Cloud et l'inviter dans la Play
   Console avec le droit de publier ;
2. mettre sa clé JSON dans un secret GitHub `PLAY_SERVICE_ACCOUNT_JSON` ;
3. ajouter une étape d'envoi au workflow.

Google impose que le **tout premier** AAB soit envoyé à la main : l'envoi
automatique ne peut servir qu'à partir de la deuxième version.

## Récapitulatif

- [ ] Nom vérifié
- [ ] 12 testeurs prêts (compte personnel)
- [ ] Compte Google dédié, type de compte et nom de développeur choisis
- [ ] Compte Play Console créé et vérifié
- [x] Politique de confidentialité en ligne
- [ ] App Meta passée en mode Live
- [ ] Fiche remplie (textes, image 1024 × 500, captures)
- [ ] Questionnaires remplis
- [ ] Signature : clé existante fournie à Google
- [ ] Test fermé : 12 testeurs, 14 jours
- [ ] Accès à la production obtenu
- [ ] Première version publiée
