import 'json_utils.dart';

/// Un cours suivi par l'étudiant (ex. : Programmation mobile).
class Course {
  final String id;
  final String name;
  final String teacher;

  const Course({required this.id, required this.name, required this.teacher});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: readField<String>(json, 'id', 'Course'),
      name: readField<String>(json, 'name', 'Course'),
      teacher: readField<String>(json, 'teacher', 'Course'),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'teacher': teacher};

  Course copyWith({String? id, String? name, String? teacher}) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
    );
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
