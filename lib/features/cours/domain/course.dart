import 'package:campusflow/core/json_utils.dart';

/// Un cours suivi par l'étudiant (ex. : Programmation mobile).
///
/// Clés JSON du serveur (`/cours`) : `id`, `nom`, `enseignant`.
class Course {
  final String id;
  final String name;
  final String teacher;

  const Course({required this.id, required this.name, required this.teacher});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: readId(json, 'Course'),
      name: readField<String>(json, 'nom', 'Course'),
      teacher: readField<String>(json, 'enseignant', 'Course'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': name,
    'enseignant': teacher,
  };

  Course copyWith({String? id, String? name, String? teacher}) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
    );
  }

  /// « Développement mobile » → « DM », « Fouille de données » → « FD »,
  /// « Statistiques » → « ST ».
  String get initials {
    const minor = {'de', 'des', 'du', 'la', 'le', 'les', 'et', 'en'};
    final words = name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty && !minor.contains(w.toLowerCase()))
        .toList();
    if (words.length == 1) {
      // « Statistiques » → « ST ».
      return words.first.substring(0, 2).toUpperCase();
    }
    return words.take(2).map((w) => w[0].toUpperCase()).join();
  }

  @override
  bool operator ==(Object other) =>
      other is Course &&
      other.id == id &&
      other.name == name &&
      other.teacher == teacher;

  @override
  int get hashCode => Object.hash(id, name, teacher);

  @override
  String toString() => 'Course($id, "$name", $teacher)';
}
