import 'json_utils.dart';

/// L'utilisateur connecté (persona : Amina, étudiante en M1).
class User {
  final String id;
  final String name;
  final String email;

  const User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    final email = readField<String>(json, 'email', 'User');
    if (!email.contains('@')) {
      throw FormatException('User : email invalide', email);
    }
    return User(
      id: readField<String>(json, 'id', 'User'),
      name: readField<String>(json, 'name', 'User'),
      email: email,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};

  User copyWith({String? id, String? name, String? email}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is User &&
      other.id == id &&
      other.name == name &&
      other.email == email;

  @override
  int get hashCode => Object.hash(id, name, email);

  @override
  String toString() => 'User($id, "$name", $email)';
}
