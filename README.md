# CampusFlow

Suivi des échéances académiques (persona : Amina, M1 Informatique).
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
| 3. Thème du design system | Couleur graine `#EC3013`, échelle typographique Material, espacements et arrondis centralisés ; écran de titre | `lib/theme/app_theme.dart`, `lib/screens/title_screen.dart` |
| 4. Package et asset | `intl` (dates en français) et `flutter_localizations` ; logo déclaré dans `pubspec.yaml` | `assets/images/logo.png` |

## Séance 5 : « Trois écrans de CampusFlow »

| Étape | Widgets | Où |
|---|---|---|
| 1. Écran Échéances | `Scaffold`, `AppBar`, `ListView.builder` de `ListTile`, `FloatingActionButton`, `NavigationBar` | `lib/screens/home_shell.dart`, `lib/screens/tasks_screen.dart`, `lib/widgets/task_tile.dart` |
| 2. Écran Détail | `Column`, `Card`, `FilledButton` « Marquer comme fait » | `lib/screens/task_detail_screen.dart` |
| 3. Formulaire | `Form`, `TextFormField`, `validator`, `SnackBar`, défilant | `lib/screens/task_form_screen.dart` |
| 4. Tablette | `LayoutBuilder` à 840 dp : liste et détail côte à côte | `lib/screens/tasks_screen.dart` |

L'état est géré avec `setState` dans `HomeShell` (Riverpod à la séance 6).
Les modèles `Task` et `Course` viennent du package `campusflow_models` (TP de la séance 3).

## Organisation

```
lib/
  main.dart                 thème, locale fr_FR, écran de titre
  theme/app_theme.dart      tokens du design system → ThemeData
  models/                   Task, Course (repris de la séance 3)
  data/sample_data.dart     données statiques (avant l'API)
  utils/date_labels.dart    « demain · 23:59 » avec intl
  widgets/task_tile.dart    ligne de tâche
  screens/                  titre, onglets, liste, détail, formulaire
test/                       tests de widgets (liste, détail, formulaire, tablette)
```
