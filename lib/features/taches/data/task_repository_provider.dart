import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow/core/dio_provider.dart';
import 'package:campusflow/features/taches/data/api_task_repository.dart';
import 'package:campusflow/features/taches/data/fake_task_repository.dart';
import 'package:campusflow/features/taches/domain/task_repository.dart';

/// `flutter run --dart-define=FAKE_API=true` : démo sans serveur.
const utiliserFauxServeur = bool.fromEnvironment('FAKE_API');

/// Le point d'accès unique aux tâches. Les tests le remplacent par un
/// [FakeTaskRepository] (`overrideWithValue`) : aucun réseau nécessaire.
final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => utiliserFauxServeur
      ? FakeTaskRepository()
      : ApiTaskRepository(ref.watch(dioProvider)),
);
