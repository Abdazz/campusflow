import 'package:dio/dio.dart';

/// Code exécuté sur chaque appel Dio :
/// - avant l'envoi, ajoute `Authorization: Bearer <jeton>` ;
/// - si le serveur répond 401 (jeton absent ou expiré), prévient
///   l'application, qui renvoie vers l'écran de connexion.
///
/// La requête `/login` elle-même n'a pas de jeton, et son 401 veut dire
/// « identifiants incorrects » : ce n'est pas une session expirée.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.lireJeton, required this.surNonAuthentifie});

  final Future<String?> Function() lireJeton;
  final void Function() surNonAuthentifie;

  static const cheminConnexion = '/login';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path != cheminConnexion) {
      final jeton = await lireJeton();
      if (jeton != null) options.headers['Authorization'] = 'Bearer $jeton';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.path != cheminConnexion) {
      surNonAuthentifie();
    }
    handler.next(err);
  }
}
