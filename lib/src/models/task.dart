import 'json_utils.dart';

/// Une échéance à rendre (TP, projet, examen…) rattachée à un cours.
class Task {
  final String id;
  final String title;
  final String courseId;
  final DateTime dueDate;
  final String? description;
  final bool isDone;

  const Task({
    required this.id,
    required this.title,
    required this.courseId,
    required this.dueDate,
    this.description,
    this.isDone = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: readField<String>(json, 'id', 'Task'),
      title: readField<String>(json, 'title', 'Task'),
      courseId: readField<String>(json, 'courseId', 'Task'),
      dueDate: readDate(json, 'dueDate', 'Task'),
      description: readOptionalField<String>(json, 'description', 'Task'),
      isDone: readOptionalField<bool>(json, 'isDone', 'Task') ?? false,
    );
  }

  /// Les objets sont immuables : on crée une copie modifiée.
  Task copyWith({
    String? id,
    String? title,
    String? courseId,
    DateTime? dueDate,
    String? description,
    bool? isDone,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
    );
  }

  /// Vrai si l'échéance est dépassée et que la tâche n'est pas faite.
  bool isOverdue(DateTime now) => !isDone && dueDate.isBefore(now);

  @override
  String toString() =>
      'Task($id, "$title", cours: $courseId, échéance: $dueDate, '
      'fait: $isDone)';
}
