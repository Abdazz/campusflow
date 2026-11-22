# CampusFlow

Suivi des échéances académiques (persona : Ibrahim Kaboré, M1 Intelligence Artificielle).
Projet fil rouge du cours de Programmation mobile.

## Auto-vérification (section IV du sujet)

Chaque ligne de la liste du sujet, et où en trouver la trace dans ce dépôt. Les captures d'écran de l'application sont dans [`docs/captures/`](docs/captures/).

| Séance | Trace attendue | Où |
|---|---|---|
| 1 | Fiche comparative (14 critères), autopsie sourcée, paragraphe de décision | [`docs/seance1/`](docs/seance1/) (PDF et Word) |
| 2 | Persona, parcours, 5 wireframes avec 3 variantes d'un écran, design system v1 | [`docs/seance2/`](docs/seance2/) (planches exportées de Claude Design) |
| 3 | Package `campusflow_models` : `Task`, `Course`, `User`, `fromJson`, 3 tests qui passent | [`campusflow_models/`](campusflow_models/), `cd campusflow_models && dart test` (21 tests, dont les 3 demandés) |
| 4 | `flutter doctor` sans erreur, application sur l'émulateur, thème centralisé, asset affiché, au moins 3 commits | [`docs/seance4/flutter_doctor.txt`](docs/seance4/flutter_doctor.txt), [capture de l'écran de titre](docs/captures/01_ecran_titre_theme_asset.png), `lib/core/theme.dart`, `assets/images/logo.png` |
| 5 | Écrans Échéances, Détail et Formulaire, version tablette à 840 dp | [liste](docs/captures/03_echeances_liste_connectee.png), [détail](docs/captures/05_detail_tache.png), [formulaire](docs/captures/08_formulaire_validator.png), [tablette](docs/captures/14_tablette_840dp_liste_detail.png) |
| 6 | Navigation par adresses, état partagé entre les trois écrans, trois filtres | `lib/core/router.dart` (tableau des adresses ci-dessous), [tâche cochée dans le détail](docs/captures/06_detail_apres_patch.png) puis [aussitôt dans la liste](docs/captures/07_liste_partagee_apres_patch.png), [filtres](docs/captures/04_filtre_faites.png) |
| 7 | API json-server, couches Repository, liste connectée (création, PATCH, DELETE), connexion avec jeton sécurisé | [`/taches` dans le navigateur](docs/captures/00_json_server_taches_navigateur.png), `lib/features/taches/`, [création](docs/captures/09_creation_post_en_cours.png), [suppression](docs/captures/11_suppression_delete.png), [erreur et « Réessayer »](docs/captures/16_erreur_serveur_reessayer.png), [connexion refusée](docs/captures/02_connexion_erreur_401.png) |

## Séances 1 à 3 : décider, concevoir, modéliser

- **Séance 1** ([`docs/seance1/`](docs/seance1/)) : Android d'abord, iOS ensuite, en cross-platform avec Flutter. La décision s'appuie sur la fiche des 14 critères et sur l'autopsie de BlackBerry.
- **Séance 2** ([`docs/seance2/`](docs/seance2/)) :
  - persona Ibrahim Kaboré et ses deux job stories ;
  - parcours « suivre mes échéances » ;
  - wireframes W1 à W5 ;
  - variantes A, B et C de l'écran Échéances (la A est retenue après la grille du cours) ;
  - design system v1, avec un contraste de 4,5:1 au minimum ;
  - en plus : maquette haute fidélité des écrans H1 à H5 et des trois variantes, avec le choix confirmé.
- **Séance 3** ([`campusflow_models/`](campusflow_models/)) : package Dart créé avec `dart create`. Il contient `Task`, `Course` et `User` (attributs `final`, `copyWith`, `fromJson`), un dépôt simulé basé sur `Future.delayed`, et des tests `dart test`. Il avait d'abord son propre dépôt Git. Il a été intégré ici avec `git subtree`, ce qui garde ses commits d'origine dans l'historique.

## Démarrer

Depuis la séance 7, l'application lit ses tâches sur un serveur simulé (json-server). Il faut deux terminaux :

```bash
# 1. Le serveur (Node.js), sur le port 3000
cd server
npm install
npm run reset        # échéances recalculées à partir d'aujourd'hui
npm start            # compte de démo : ibrahim.kabore@universite.bf / campus2026

# 2. L'application
flutter pub get
flutter run          # émulateur Android : l'API est jointe par 10.0.2.2:3000
flutter test         # tests (aucun serveur nécessaire)
```

- Téléphone réel : `flutter run --dart-define=API_URL=http://<adresse du PC>:3000`.
- Sans serveur : `flutter run --dart-define=FAKE_API=true` (données et connexion en mémoire).
- `npm run brut` lance json-server sans authentification (étape 1 de la séance 7). Ouvrir `http://localhost:3000/taches` dans le navigateur affiche alors le JSON brut. Avec `npm start`, toutes les routes exigent un jeton.
- `npm run reset` régénère `server/db.json` avec des échéances recalculées à partir d'aujourd'hui.
- `JETON_DUREE=30 npm start` : jetons valables 30 s, pour voir le retour à l'écran de connexion.

## Séance 4 : « CampusFlow s'initialise »

| Étape | Livrable | Où |
|---|---|---|
| 1. Installation | `flutter doctor` au vert (« No issues found! ») | `docs/seance4/flutter_doctor.txt` |
| 2. Projet | `flutter create`, premier commit, lancement sur l'émulateur | commit `e4a06b3`, `docs/captures/01_ecran_titre_theme_asset.png` |
| 3. Thème du design system | Tokens du dossier de conception : bleu campus `#2E3A8C`, couleurs urgent / succès (`ThemeExtension`), police Figtree, échelle typographique, espacements et arrondis ; écran de titre | `lib/theme/app_theme.dart`, `lib/screens/title_screen.dart` |
| 4. Package et asset | `intl` (dates en français) et `flutter_localizations` ; logo « C-coche » et police Figtree déclarés dans `pubspec.yaml` | `assets/images/`, `assets/fonts/` |

## Séance 5 : « Trois écrans de CampusFlow »

| Étape | Widgets | Où |
|---|---|---|
| 1. Écran Échéances (variante A « Liste par jour ») | `Scaffold`, `AppBar`, `ListView.builder` de `ListTile`, `FloatingActionButton`, `NavigationBar` | `lib/screens/home_shell.dart`, `lib/screens/tasks_screen.dart`, `lib/widgets/task_tile.dart` |
| 2. Écran Détail | `Column`, `Card`, `FilledButton` « Marquer comme fait » | `lib/screens/task_detail_screen.dart` |
| 3. Formulaire | `Form`, `TextFormField`, `validator`, `SnackBar`, défilant | `lib/screens/task_form_screen.dart` |
| 4. Tablette | `LayoutBuilder` à 840 dp : liste et détail côte à côte ; rail de navigation dès 600 dp | `lib/screens/tasks_screen.dart`, `lib/screens/home_shell.dart` |

## Séance 6 : « CampusFlow devient une application »

| Étape | Livrable | Où |
|---|---|---|
| 1. Dépendances | `flutter pub add flutter_riverpod go_router`, `ProviderScope` dans `main` | `pubspec.yaml`, `lib/main.dart` |
| 2. Routes | `GoRouter`, `ShellRoute` avec `NavigationBar` (rail dès 600 dp), paramètre `:id` | `lib/router.dart`, `lib/screens/home_shell.dart` |
| 3. État partagé | `TachesNotifier` (ajouter, modifier, basculer par id) ; liste, détail et formulaire branchés dessus | `lib/state/taches_provider.dart` |
| 4. Filtres | Fournisseur dérivé `tachesFiltreesProvider` : à faire, faites, en retard | `lib/state/filtres_provider.dart` |

Les adresses de l'application :

| Chemin | Écran | Niveau |
|---|---|---|
| `/` | Écran de titre | Hors barre de navigation |
| `/login` | Connexion (séance 7 : toute autre adresse y renvoie sans session) | Hors barre de navigation |
| `/taches` | Échéances (liste) | Destination 1 |
| `/taches/nouvelle` | Formulaire de création | Écran secondaire |
| `/taches/:id` | Détail d'une tâche (en tablette : liste et détail côte à côte) | Écran secondaire |
| `/taches/:id/modifier` | Formulaire de modification | Écran secondaire |
| `/cours` | Liste des cours | Destination 2 |
| `/profil` | Compte | Destination 3 |

`/taches/nouvelle` est déclarée avant `/taches/:id`, sinon « nouvelle » serait lu comme un identifiant.

> Les chemins des séances 4 à 6 sont ceux d'origine : à la séance 7, les fichiers ont été rangés par couche et par fonctionnalité (voir « Organisation »).

## Séance 7 : « CampusFlow se connecte au serveur »

| Étape | Livrable | Où |
|---|---|---|
| 1. Serveur simulé | `db.json` avec tâches, cours et utilisateurs ; json-server lancé (`GET`, `POST`, `PATCH`, `DELETE` sur `/taches`) | `server/db.json`, `server/seed.js` |
| 2. Couches | Dio configuré une fois dans `core` (adresse, délais) ; contrat `TaskRepository` et ses implémentations `ApiTaskRepository` (Dio) et `FakeTaskRepository` (mémoire) ; dossiers `core/` et `features/` | `lib/core/dio_provider.dart`, `lib/features/taches/domain/`, `lib/features/taches/data/` |
| 3. CRUD asynchrone | `TachesNotifier` devient un `AsyncNotifier` ; trois états à l'écran (chargement, erreur avec « Réessayer », donnée) ; création `POST`, coche `PATCH`, suppression `DELETE`, tirer pour rafraîchir | `lib/features/taches/application/taches_provider.dart`, `lib/core/widgets/async_vue.dart` |
| 4. Connexion | Faux `POST /login` qui renvoie un JWT signé avec expiration ; jeton rangé dans `flutter_secure_storage` ; intercepteur Dio (`Bearer <jeton>`, 401 → session effacée) ; redirection vers `/login` | `server/server.js`, `lib/core/auth_interceptor.dart`, `lib/core/stockage_securise.dart`, `lib/features/auth/`, `lib/core/router.dart` |

Le flux « cocher une tâche » traverse toutes les couches :

| Action | Notifier | Repository | Serveur | Conversion | Affichage |
|---|---|---|---|---|---|
| `ref.read(...).basculer(id)` | `AsyncLoading` (la liste reste affichée) | `PATCH /taches/:id` `{"terminee": true}` via Dio | 200 + JSON | `Task.fromJson` | `AsyncData`, widgets reconstruits |

Contrat JSON du serveur (clés du cours) :

```json
{ "id": "t3", "titre": "Projet Flutter — maquette", "coursId": "dm",
  "echeance": "2026-11-14T17:00:00", "terminee": false, "description": null, "rappel": "dayBefore" }
```

Choix et remarques :

- Seul le Repository connaît Dio : il traduit chaque `DioException` en `ApiException` avec un message lisible. Un écran n'appelle jamais l'API lui-même.
- En test, `taskRepositoryProvider` est remplacé par `FakeTaskRepository` : aucun réseau nécessaire. Un test de bout en bout garde le vrai Dio et son intercepteur et ne simule que le réseau (`test/support/fake_http.dart`).
- Une action qui échoue (serveur coupé) laisse la liste en place et l'explique dans une SnackBar ; le formulaire reste ouvert sans perdre la saisie.
- Riverpod 3 relance seul un fournisseur en erreur : c'est désactivé pour les erreurs réseau, l'utilisateur décide avec « Réessayer » (et un 401 n'est jamais répété).
- Le jeton ne quitte jamais le stockage chiffré (Keystore Android). Le profil de l'utilisateur y est rangé aussi, pour l'afficher au démarrage sans réseau. Le mot de passe n'est stocké nulle part.
- Après connexion, le routeur ouvre la page demandée au départ (`/login?suite=/taches/t3`), jamais une adresse externe.
- Android bloque le HTTP non chiffré : `network_security_config.xml` ne l'autorise que vers `10.0.2.2` et `localhost` (serveur de TP). En production : HTTPS uniquement.
- Les cours restent un catalogue local identique à `db.json` : ils changent une fois par semestre et servent à afficher les noms sans attendre le réseau.

## Design

Les écrans reprennent le dossier de conception v1 réalisé avec Claude Design : page de tokens, logo « C-coche », maquettes haute fidélité H1 à H5 et variante A retenue pour l'écran Échéances. La police Figtree (licence OFL, `assets/fonts/OFL.txt`) est embarquée pour fonctionner hors ligne.

L'état partagé (tâches, session, filtre actif) est géré avec Riverpod : `ref.watch` pour afficher, `ref.read` pour agir. `setState` reste pour l'état local d'un écran (champs du formulaire, bouton en cours d'envoi).
Les modèles `Task` et `Course` viennent du TP de la séance 3 ; leurs clés JSON suivent le contrat du serveur depuis la séance 7.

## Organisation

Cinq couches, une direction : UI → État → Logique métier → Repository → Sources.

```
lib/
  main.dart                         ProviderScope, MaterialApp.router, locale fr_FR
  core/                             partagé
    dio_provider.dart               client Dio (adresse, délais, intercepteur)
    auth_interceptor.dart           Bearer <jeton>, 401 → session expirée
    stockage_securise.dart          flutter_secure_storage (jeton)
    api_exception.dart              erreurs réseau traduites en messages
    router.dart                     routes go_router, redirection /login
    theme.dart                      tokens du design system → ThemeData
    date_labels.dart                « demain · 23:59 » avec intl
    widgets/                        en-tête, ossature (barre / rail), trois états, marque
  features/
    taches/
      domain/                       Task, règles (en retard, état), filtres, contrat TaskRepository
      data/                         ApiTaskRepository (Dio), FakeTaskRepository, données de démo
      application/                  TachesNotifier (AsyncNotifier), filtres dérivés
      presentation/                 liste, détail, formulaire, ligne de tâche, actions
    auth/
      domain/                       Utilisateur, contrat AuthRepository
      data/                         ApiAuthRepository (POST /login), FakeAuthRepository
      application/                  AuthNotifier (session)
      presentation/                 écran de connexion
    cours/                          Course, catalogue, onglet Cours
    profil/                         onglet Profil (déconnexion)
    accueil/                        écran de titre
server/                             json-server : db.json, server.js (/login, jeton), seed.js
campusflow_models/                  séance 3 : package Dart des modèles et ses tests
docs/                               séances 1 et 2, flutter doctor, captures d'écran
test/                               Repositories (faux réseau), Notifiers, intercepteur, écrans et parcours complet
```
