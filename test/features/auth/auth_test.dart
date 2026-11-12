import 'dart:convert';

import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/core/auth_interceptor.dart';
import 'package:campusflow/core/dio_provider.dart';
import 'package:campusflow/core/router.dart';
import 'package:campusflow/core/stockage_securise.dart';
import 'package:campusflow/features/auth/application/auth_provider.dart';
import 'package:campusflow/features/auth/data/api_auth_repository.dart';
import 'package:campusflow/features/auth/data/auth_repository_provider.dart';
import 'package:campusflow/features/auth/data/fake_auth_repository.dart';
import 'package:campusflow/features/auth/domain/utilisateur.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_http.dart';

void main() {
  group('AuthInterceptor', () {
    test('ajoute « Bearer <jeton> » à chaque requête, sauf /login', () async {
      final http = FakeHttpAdapter((_) => (code: 200, json: []));
      final dio = dioDeTest(http)
        ..interceptors.add(
          AuthInterceptor(
            lireJeton: () async => 'abc.def.ghi',
            surNonAuthentifie: () {},
          ),
        );

      await dio.get<void>('/taches');
      await dio.post<void>('/login', data: {});

      expect(http.requetes[0].entetes['Authorization'], 'Bearer abc.def.ghi');
      expect(http.requetes[1].entetes.containsKey('Authorization'), isFalse);
    });

    test('401 : signale la session expirée (mais pas sur /login)', () async {
      var signaux = 0;
      final http = FakeHttpAdapter((_) => (code: 401, json: {}));
      final dio = dioDeTest(http)
        ..interceptors.add(
          AuthInterceptor(
            lireJeton: () async => 'expire',
            surNonAuthentifie: () => signaux++,
          ),
        );

      await expectLater(dio.get<void>('/taches'), throwsA(anything));
      expect(signaux, 1);
      await expectLater(dio.post<void>('/login'), throwsA(anything));
      expect(signaux, 1);
    });
  });

  group('ApiAuthRepository', () {
    test('POST /login : jeton et utilisateur', () async {
      final http = FakeHttpAdapter(
        (_) => (
          code: 200,
          json: {'jeton': 'a.b.c', 'utilisateur': utilisateurDemo.toJson()},
        ),
      );
      final session = await ApiAuthRepository(dioDeTest(http))
          .connecter(email: ' ibrahim.kabore@universite.bf ', motDePasse: 'x');

      expect(http.requetes.single.chemin, '/login');
      expect(http.requetes.single.corps, {
        'email': 'ibrahim.kabore@universite.bf',
        'motDePasse': 'x',
      });
      expect(session.jeton, 'a.b.c');
      expect(session.utilisateur, utilisateurDemo);
    });

    test('401 sur /login : « identifiants incorrects »', () async {
      final http = FakeHttpAdapter((_) => (code: 401, json: {}));
      await expectLater(
        ApiAuthRepository(dioDeTest(http))
            .connecter(email: 'a@b.c', motDePasse: 'faux'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Adresse ou mot de passe incorrect.',
          ),
        ),
      );
    });
  });

  group('AuthNotifier', () {
    late StockageMemoire stockage;

    ProviderContainer conteneur([Map<String, String>? initial]) {
      stockage = StockageMemoire(initial);
      final c = ProviderContainer(
        overrides: [
          stockageSecuriseProvider.overrideWithValue(stockage),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('sans jeton : pas de session', () async {
      final c = conteneur();
      expect(await c.read(authProvider.future), isNull);
    });

    test('session restaurée depuis le stockage chiffré', () async {
      final c = conteneur({
        cleJeton: 'a.b.c',
        cleUtilisateur: jsonEncode(utilisateurDemo.toJson()),
      });
      expect(await c.read(authProvider.future), utilisateurDemo);
    });

    test('connecter range le jeton ; deconnecter l’efface', () async {
      final c = conteneur();
      await c.read(authProvider.future);

      await c
          .read(authProvider.notifier)
          .connecter(
            email: 'ibrahim.kabore@universite.bf',
            motDePasse: 'campus2026',
          );
      expect(c.read(authProvider).value, utilisateurDemo);
      expect(stockage.valeurs[cleJeton], 'jeton-de-test');

      await c.read(authProvider.notifier).deconnecter();
      expect(c.read(authProvider).value, isNull);
      expect(stockage.valeurs, isEmpty);
    });

    test('mauvais mot de passe : erreur, rien n’est stocké', () async {
      final c = conteneur();
      await c.read(authProvider.future);
      await expectLater(
        c
            .read(authProvider.notifier)
            .connecter(email: 'ibrahim.kabore@universite.bf', motDePasse: 'x'),
        throwsA(isA<ApiException>()),
      );
      expect(c.read(authProvider).value, isNull);
      expect(stockage.valeurs, isEmpty);
    });

    test(
      '401 signalé par l’intercepteur : session effacée, avis affiché',
      () async {
        final c = conteneur({
          cleJeton: 'a.b.c',
          cleUtilisateur: jsonEncode(utilisateurDemo.toJson()),
        });
        await c.read(authProvider.future);

        c.read(sessionExpireeProvider.notifier).signaler();
        await pumpEventQueue();

        expect(c.read(authProvider).value, isNull);
        expect(stockage.valeurs, isEmpty);
        expect(
          c.read(avisConnexionProvider),
          'Session expirée : reconnecte-toi.',
        );
      },
    );
  });

  group('redirectionSession', () {
    const connecte = AsyncData<Utilisateur?>(utilisateurDemo);
    const anonyme = AsyncData<Utilisateur?>(null);

    test('sans session : /login en retenant la page demandée', () {
      expect(
        redirectionSession(anonyme, Uri.parse('/taches/t3')),
        '/login?suite=%2Ftaches%2Ft3',
      );
      expect(redirectionSession(anonyme, Uri.parse('/')), isNull);
      expect(redirectionSession(anonyme, Uri.parse('/login')), isNull);
    });

    test('connecté sur /login : la page demandée, sinon les échéances', () {
      expect(
        redirectionSession(connecte, Uri.parse('/login?suite=%2Fcours')),
        '/cours',
      );
      expect(redirectionSession(connecte, Uri.parse('/login')), '/taches');
      // Jamais vers un autre site.
      expect(
        redirectionSession(
          connecte,
          Uri.parse('/login?suite=https://exemple.com'),
        ),
        '/taches',
      );
      expect(redirectionSession(connecte, Uri.parse('/profil')), isNull);
    });

    test('session en cours de lecture : on ne bouge pas', () {
      expect(
        redirectionSession(
          const AsyncLoading<Utilisateur?>(),
          Uri.parse('/taches'),
        ),
        isNull,
      );
    });
  });
}
