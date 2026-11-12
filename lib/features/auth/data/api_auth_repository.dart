import 'package:dio/dio.dart';

import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/features/auth/domain/auth_repository.dart';
import 'package:campusflow/features/auth/domain/utilisateur.dart';

/// `POST /login` sur le serveur simulé (`server/server.js`).
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio);

  final Dio _dio;

  @override
  Future<Session> connecter({
    required String email,
    required String motDePasse,
  }) async {
    try {
      final reponse = await _dio.post<Map<String, dynamic>>(
        '/login',
        data: {'email': email.trim(), 'motDePasse': motDePasse},
      );
      final json = reponse.data!;
      return (
        jeton: json['jeton'] as String,
        utilisateur: Utilisateur.fromJson(
          json['utilisateur'] as Map<String, dynamic>,
        ),
      );
    } on DioException catch (e) {
      // Ici, 401 veut dire « identifiants incorrects », pas « session
      // expirée ».
      if (e.response?.statusCode == 401) {
        throw const ApiException(
          'Adresse ou mot de passe incorrect.',
          statusCode: 401,
        );
      }
      throw ApiException.fromDio(e);
    } on FormatException catch (e) {
      throw ApiException('Réponse du serveur illisible : ${e.message}');
    }
  }
}
