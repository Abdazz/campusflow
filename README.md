# CampusFlow

Suivi des échéances académiques (persona : Ibrahim Kaboré, M1 Intelligence Artificielle).
Projet fil rouge du cours de Programmation mobile.

## Démarrer

Depuis la séance 7, l'application lit ses tâches sur un serveur simulé (json-server). Il faut deux terminaux :

```bash
# 1. Le serveur (Node.js), sur le port 3000
cd server
npm install
npm start            # compte de démo : ibrahim.kabore@universite.bf / campus2026

# 2. L'application
flutter pub get
flutter run          # émulateur Android : l'API est jointe par 10.0.2.2:3000
flutter test         # tests (aucun serveur nécessaire)
```

- Téléphone réel : `flutter run --dart-define=API_URL=http://<adresse du PC>:3000`.
- Sans serveur : `flutter run --dart-define=FAKE_API=true` (données et connexion en mémoire).
- `npm run reset` régénère `server/db.json` avec des échéances recalculées à partir d'aujourd'hui.
- `JETON_DUREE=30 npm start` : jetons valables 30 s, pour voir le retour à l'écran de connexion.

## Séance 4 : « CampusFlow s'initialise »

| Étape | Livrable | Où |
|---|---|---|
| 1. Installation | `flutter doctor` au vert | — |
| 2. Projet | `flutter create`, premier commit | — |
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
test/                               Repositories (faux réseau), Notifiers, intercepteur, écrans et parcours complet
```
