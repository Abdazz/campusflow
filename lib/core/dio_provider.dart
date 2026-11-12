import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      // Délai maximal avant d'abandonner un appel.
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType: Headers.jsonContentType,
    ),
  );
  ref.onDispose(dio.close);
  return dio;
});
