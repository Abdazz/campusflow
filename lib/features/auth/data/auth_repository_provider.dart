import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow/core/dio_provider.dart';
import 'package:campusflow/features/auth/data/api_auth_repository.dart';
import 'package:campusflow/features/auth/data/fake_auth_repository.dart';
import 'package:campusflow/features/auth/domain/auth_repository.dart';
import 'package:campusflow/features/taches/data/task_repository_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => utiliserFauxServeur
      ? FakeAuthRepository()
      : ApiAuthRepository(ref.watch(dioProvider)),
);
