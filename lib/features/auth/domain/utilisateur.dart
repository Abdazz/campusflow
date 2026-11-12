import 'package:campusflow/core/json_utils.dart';

/// L'étudiant connecté, tel que renvoyé par `POST /login` (sans mot de
/// passe : le serveur ne le renvoie jamais).
class Utilisateur {
  const Utilisateur({
    required this.id,
    required this.nom,
    required this.initiales,
    required this.email,
    required this.programme,
  });

  final String id;
  final String nom;
  final String initiales;
  final String email;
  final String programme;

  String get prenom => nom.split(' ').first;

  factory Utilisateur.fromJson(Map<String, dynamic> json) => Utilisateur(
    id: readId(json, 'Utilisateur'),
    nom: readField<String>(json, 'nom', 'Utilisateur'),
    initiales: readField<String>(json, 'initiales', 'Utilisateur'),
    email: readField<String>(json, 'email', 'Utilisateur'),
    programme: readField<String>(json, 'programme', 'Utilisateur'),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'initiales': initiales,
    'email': email,
    'programme': programme,
  };

  @override
  bool operator ==(Object other) =>
      other is Utilisateur &&
      other.id == id &&
      other.nom == nom &&
      other.initiales == initiales &&
      other.email == email &&
      other.programme == programme;

  @override
  int get hashCode => Object.hash(id, nom, initiales, email, programme);

  @override
  String toString() => 'Utilisateur($id, $nom)';
}
