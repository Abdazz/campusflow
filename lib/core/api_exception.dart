import 'package:dio/dio.dart';

/// Erreur d'accès aux données, traduite en message lisible.
///
/// Seul le Repository connaît Dio : il convertit chaque [DioException] en
/// [ApiException]. Les Notifiers et les écrans ne voient jamais Dio.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  /// Message prêt à afficher à l'utilisateur.
  final String message;

  /// Code HTTP de la réponse, `null` s'il n'y a pas eu de réponse.
  final int? statusCode;

  /// 401 : jeton absent ou expiré.
  bool get nonAuthentifie => statusCode == 401;

  factory ApiException.fromDio(DioException e) {
    final code = e.response?.statusCode;
    final message = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Le serveur ne répond pas. Réessaie dans un instant.',
      DioExceptionType.connectionError =>
        'Impossible de joindre le serveur. Vérifie ta connexion.',
      DioExceptionType.badResponse => switch (code) {
        401 => 'Session expirée : reconnecte-toi.',
        404 => 'Cette ressource n’existe pas ou plus.',
        final c? when c >= 500 => 'Le serveur rencontre une panne.',
        _ => 'Requête refusée par le serveur ($code).',
      },
      DioExceptionType.cancel => 'Requête annulée.',
      _ => 'Erreur réseau inattendue.',
    };
    return ApiException(message, statusCode: code);
  }

  @override
  String toString() => 'ApiException($statusCode) : $message';
}
