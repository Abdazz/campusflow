import 'package:campusflow/core/api_exception.dart';
import 'package:campusflow/features/auth/domain/auth_repository.dart';
import 'package:campusflow/features/auth/domain/utilisateur.dart';

/// Le compte de démonstration (le même que dans `server/db.json`).
const utilisateurDemo = Utilisateur(
  id: 'u1',
  nom: 'Ibrahim Kaboré',
  initiales: 'IK',
  email: 'ibrahim.kabore@universite.bf',
  programme: 'Master 1 Intelligence Artificielle',
);

/// Connexion sans serveur : tests et `--dart-define=FAKE_API=true`.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.motDePasse = 'campus2026'});

  final String motDePasse;

  @override
  Future<Session> connecter({
    required String email,
    required String motDePasse,
  }) async {
    final bonCompte =
        email.trim().toLowerCase() == utilisateurDemo.email &&
        motDePasse == this.motDePasse;
    if (!bonCompte) {
      throw const ApiException(
        'Adresse ou mot de passe incorrect.',
        statusCode: 401,
      );
    }
    return (jeton: 'jeton-de-test', utilisateur: utilisateurDemo);
  }
}
