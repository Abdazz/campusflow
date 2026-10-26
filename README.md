# campusflow_models

Modèles de données de **CampusFlow** en Dart pur (atelier séance 3, Programmation mobile).

| Étape | Contenu | Fichiers |
|---|---|---|
| 1. Projet Dart | `dart create -t package campusflow_models`, dépôt Git | `pubspec.yaml` |
| 2. Trois modèles | `Task`, `Course`, `User` : attributs `final`, constructeur `const`, `copyWith` | `lib/src/models/` |
| 3. JSON et Future | `fromJson` pour chaque modèle ; dépôt simulé avec `Future.delayed` | `lib/src/repository/campus_repository.dart` |
| 4. Tests | `copyWith`, `fromJson`, erreur attendue (`FormatException`) | `test/campusflow_models_test.dart` |

`Task` a aussi une méthode `isOverdue(now)` (échéance dépassée et tâche non faite).

## Lancer

```bash
dart pub get
dart test                                    # 3 tests
dart run example/campusflow_models_example.dart
```
