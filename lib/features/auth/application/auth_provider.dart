import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusflow/core/dio_provider.dart';
import 'package:campusflow/core/stockage_securise.dart';
import 'package:campusflow/features/auth/data/auth_repository_provider.dart';
import 'package:campusflow/features/auth/domain/utilisateur.dart';

/// Clé du profil de l'utilisateur connecté (pour l'afficher sans réseau au
/// démarrage). Le jeton, lui, est sous `cleJeton`.
const cleUtilisateur = 'campusflow.utilisateur';

/// La session : l'utilisateur connecté, ou `null`.
///
/// 1. Connexion : `POST /login` avec l'adresse et le mot de passe.
/// 2. Le serveur renvoie un jeton signé (JWT) avec une expiration.
/// 3. Le jeton est rangé dans le stockage chiffré.
/// 4. L'intercepteur Dio l'ajoute à chaque requête.
/// 5. Erreur 401 : la session est effacée, le routeur ramène à `/login`.
class AuthNotifier extends AsyncNotifier<Utilisateur?> {
  StockageSecurise get _stockage => ref.read(stockageSecuriseProvider);

  /// Au démarrage : session restaurée depuis le stockage chiffré.
  @override
  Future<Utilisateur?> build() async {
    // Étape 5 : l'intercepteur a reçu un 401.
    ref.listen(sessionExpireeProvider, (_, _) => _expirer());

    final stockage = ref.watch(stockageSecuriseProvider);
    final jeton = await stockage.lire(cleJeton);
    final profil = await stockage.lire(cleUtilisateur);
    if (jeton == null || profil == null) return null;
    try {
      return Utilisateur.fromJson(jsonDecode(profil) as Map<String, dynamic>);
    } catch (_) {
      // Profil illisible : on repart d'une session vide.
      await _effacer();
      return null;
    }
  }

  /// Lève une `ApiException` si les identifiants sont refusés ; l'écran de
  /// connexion l'affiche.
  Future<void> connecter({
    required String email,
    required String motDePasse,
  }) async {
    final session = await ref
        .read(authRepositoryProvider)
        .connecter(email: email, motDePasse: motDePasse);
    await _stockage.ecrire(cleJeton, session.jeton);
    await _stockage.ecrire(
      cleUtilisateur,
      jsonEncode(session.utilisateur.toJson()),
    );
    if (!ref.mounted) return;
    ref.read(avisConnexionProvider.notifier).effacer();
    state = AsyncData(session.utilisateur);
  }

  Future<void> deconnecter() async {
    await _effacer();
    if (ref.mounted) state = const AsyncData(null);
  }

  Future<void> _expirer() async {
    if (state.value == null) return;
    await _effacer();
    if (!ref.mounted) return;
    ref
        .read(avisConnexionProvider.notifier)
        .afficher('Session expirée : reconnecte-toi.');
    state = const AsyncData(null);
  }

  Future<void> _effacer() async {
    await _stockage.effacer(cleJeton);
    await _stockage.effacer(cleUtilisateur);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, Utilisateur?>(
  AuthNotifier.new,
);

/// Message à afficher sur l'écran de connexion (ex. : session expirée).
class AvisConnexion extends Notifier<String?> {
  @override
  String? build() => null;

  void afficher(String message) => state = message;

  void effacer() => state = null;
}

final avisConnexionProvider = NotifierProvider<AvisConnexion, String?>(
  AvisConnexion.new,
);
