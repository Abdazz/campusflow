import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow/core/auth_interceptor.dart';
import 'package:campusflow/core/stockage_securise.dart';

/// Adresse de l'API (json-server, voir `server/`).
///
/// Sur l'émulateur Android, `localhost` désigne l'émulateur lui-même :
/// l'ordinateur hôte se joint par `10.0.2.2`. Sur un téléphone réel,
/// passer l'adresse du PC sur le réseau local :
///
/// ```sh
/// flutter run --dart-define=API_URL=http://192.168.1.20:3000
/// ```
String get apiBaseUrl {
  const depuisLigneDeCommande = String.fromEnvironment('API_URL');
  if (depuisLigneDeCommande.isNotEmpty) return depuisLigneDeCommande;
  final emulateurAndroid =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  return emulateurAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
}

/// Le client HTTP, configuré une seule fois pour toute l'application.
final dioProvider = Provider<Dio>((ref) {
  final dio = creerDio(ref);
  ref.onDispose(dio.close);
  return dio;
});

/// Configuration du client : adresse, délais, intercepteur du jeton.
/// Les tests la réutilisent en remplaçant seulement le réseau
/// (`httpClientAdapter`).
Dio creerDio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      // Délai maximal avant d'abandonner un appel.
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: Headers.jsonContentType,
    ),
  );
  dio.interceptors.add(
    AuthInterceptor(
      lireJeton: () => ref.read(stockageSecuriseProvider).lire(cleJeton),
      surNonAuthentifie: () =>
          ref.read(sessionExpireeProvider.notifier).signaler(),
    ),
  );
  return dio;
}

/// Signal émis par l'intercepteur à chaque réponse 401. La fonctionnalité
/// d'authentification l'écoute : elle efface la session, et la redirection
/// du routeur ramène à l'écran de connexion.
class SessionExpiree extends Notifier<int> {
  @override
  int build() => 0;

  void signaler() => state++;
}

final sessionExpireeProvider = NotifierProvider<SessionExpiree, int>(
  SessionExpiree.new,
);
