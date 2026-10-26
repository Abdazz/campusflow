# campusflow_models

Modèles de données de **CampusFlow** en Dart pur (atelier « Les modèles de CampusFlow en Dart pur », Programmation mobile).

## Démarrer

Prérequis : le SDK Dart (fourni avec Flutter).

```bash
cd campusflow_models
dart pub get                                      # installe les dépendances
dart test                                         # lance tous les tests
dart run example/campusflow_models_example.dart   # démo dans le terminal
```

## Étapes de l'atelier

| Étape | Contenu | Fichiers |
|---|---|---|
| 1. Projet Dart | `dart create -t package campusflow_models`, dépôt Git | `pubspec.yaml` |
| 2. Trois modèles | `Task`, `Course`, `User` : attributs `final`, constructeur `const`, `copyWith` | `lib/src/models/` |
| 3. JSON et Future | `fromJson` (et `toJson`) pour chaque modèle ; dépôt simulé avec `Future.delayed` | `lib/src/repository/campus_repository.dart` |
| 4. Tests | Les 3 tests demandés : `copyWith`, `fromJson`, erreur attendue | `test/campusflow_models_test.dart` |

Tests complémentaires : `test/models_extra_test.dart` (Course, User, toJson, cas d'erreur, `isOverdue`) et `test/campus_repository_test.dart` (chargement asynchrone).

## Organisation

```
lib/
  campusflow_models.dart          point d'entrée du package
  src/models/
    task.dart                     échéance (isOverdue : en retard ?)
    course.dart                   cours
    user.dart                     utilisateur
    json_utils.dart               lecture JSON typée, FormatException claire
  src/repository/
    campus_repository.dart        dépôt simulé (Future.delayed)
example/                          démo en ligne de commande
test/                             tests unitaires
```
