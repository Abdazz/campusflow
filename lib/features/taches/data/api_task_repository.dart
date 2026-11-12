import 'package:dio/dio.dart';

import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/features/taches/domain/task.dart';
import 'package:campusflow/features/taches/domain/task_repository.dart';

/// Implémentation REST du [TaskRepository] : une adresse par ressource,
/// une méthode HTTP par action.
///
/// | Action    | Requête              | Réponse     |
/// |-----------|----------------------|-------------|
/// | lister    | `GET /taches`        | 200 + liste |
/// | ajouter   | `POST /taches`       | 201 + tâche |
/// | modifier  | `PATCH /taches/:id`  | 200 + tâche |
/// | cocher    | `PATCH /taches/:id`  | 200 + tâche |
/// | supprimer | `DELETE /taches/:id` | 200 ou 204  |
class ApiTaskRepository implements TaskRepository {
  ApiTaskRepository(this._dio);

  final Dio _dio;

  static const _chemin = '/taches';

  String _adresse(String id) => '$_chemin/${Uri.encodeComponent(id)}';

  /// Exécute un appel et traduit ses erreurs en [ApiException].
  Future<T> _appel<T>(Future<T> Function() requete) async {
    try {
      return await requete();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } on FormatException catch (e) {
      // JSON reçu mais incomplet ou mal typé (voir Task.fromJson).
      throw ApiException('Réponse du serveur illisible : ${e.message}');
    }
  }

  Task _tache(Response<Map<String, dynamic>> reponse) =>
      Task.fromJson(reponse.data!);

  /// Corps envoyé : l'identifiant est dans l'adresse, pas dans le JSON.
  Map<String, dynamic> _corps(Task tache) => tache.toJson()..remove('id');

  @override
  Future<List<Task>> lister() => _appel(() async {
    final reponse = await _dio.get<List<dynamic>>(_chemin);
    return [
      for (final json in reponse.data!)
        Task.fromJson(json as Map<String, dynamic>),
    ];
  });

  @override
  Future<Task> ajouter(Task tache) =>
      _appel(() async => _tache(await _dio.post(_chemin, data: _corps(tache))));

  @override
  Future<Task> modifier(Task tache) => _appel(
    () async =>
        _tache(await _dio.patch(_adresse(tache.id), data: _corps(tache))),
  );

  @override
  Future<Task> cocher(String id, {required bool terminee}) => _appel(
    () async =>
        _tache(await _dio.patch(_adresse(id), data: {'terminee': terminee})),
  );

  @override
  Future<void> supprimer(String id) =>
      _appel(() => _dio.delete<void>(_adresse(id)));
}
