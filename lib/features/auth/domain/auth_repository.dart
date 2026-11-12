import 'package:campusflow/features/auth/domain/utilisateur.dart';

/// Ce que renvoie une connexion réussie : le jeton signé (JWT) et
/// l'utilisateur.
typedef Session = ({String jeton, Utilisateur utilisateur});

/// Le contrat d'authentification. Le mot de passe n'est envoyé qu'ici, une
/// seule fois : ensuite, le jeton le remplace.
abstract interface class AuthRepository {
  /// `POST /login` ; lève une `ApiException` 401 si les identifiants sont
  /// incorrects.
  Future<Session> connecter({
    required String email,
    required String motDePasse,
  });
}
