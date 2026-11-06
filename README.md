# CampusFlow

Suivi des échéances académiques (persona : Ibrahim Kaboré, M1 Intelligence Artificielle).
Projet fil rouge du cours de Programmation mobile.

## Démarrer

```bash
flutter pub get
flutter run          # sur l'émulateur Android ou Chrome
flutter test         # tests de widgets
```

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

## Design

Les écrans reprennent le dossier de conception v1 réalisé avec Claude Design : page de tokens, logo « C-coche », maquettes haute fidélité H1 à H5 et variante A retenue pour l'écran Échéances. La police Figtree (licence OFL, `assets/fonts/OFL.txt`) est embarquée pour fonctionner hors ligne.

L'état partagé (tâches, filtre actif) est géré avec Riverpod : `ref.watch` pour afficher, `ref.read` pour agir. `setState` reste pour l'état local d'un écran (champs du formulaire).
Les modèles `Task` et `Course` viennent du package `campusflow_models` (TP de la séance 3).

## Organisation

```
lib/
  main.dart                 ProviderScope, MaterialApp.router, locale fr_FR
  router.dart               routes go_router (ShellRoute, :id)
  state/                    TachesNotifier, filtres (fournisseurs Riverpod)
  theme/app_theme.dart      tokens du design system → ThemeData
  models/                   Task, Course (repris de la séance 3)
  data/sample_data.dart     données statiques (avant l'API)
  utils/date_labels.dart    « demain · 23:59 » avec intl
  widgets/task_tile.dart    ligne de tâche
  screens/                  titre, onglets, liste, détail, formulaire
test/                       tests des fournisseurs et des écrans (routes, filtres, tablette)
```
