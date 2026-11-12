import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Une requête reçue par [FakeHttpAdapter].
typedef RequeteRecue = ({
  String methode,
  String chemin,
  Object? corps,
  Map<String, dynamic> entetes,
});

/// Réponse préparée : code HTTP et corps JSON (ou `null`).
typedef ReponsePreparee = ({int code, Object? json});

/// Remplace le réseau de Dio : chaque requête est enregistrée et reçoit la
/// réponse rendue par [repondre]. Aucun serveur nécessaire.
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.repondre);

  final ReponsePreparee Function(RequestOptions requete) repondre;

  /// Simule « serveur coupé » : erreur de connexion.
  bool horsLigne = false;

  final requetes = <RequeteRecue>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requetes.add((
      methode: options.method,
      chemin: options.path,
      corps: options.data,
      entetes: Map.of(options.headers),
    ));
    if (horsLigne) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'Connexion refusée',
      );
    }
    final reponse = repondre(options);
    return ResponseBody.fromString(
      reponse.json == null ? '' : jsonEncode(reponse.json),
      reponse.code,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Un client Dio branché sur [adapter].
Dio dioDeTest(FakeHttpAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'http://api.test'))..httpClientAdapter = adapter;
