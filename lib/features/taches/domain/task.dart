import 'package:campusflow/core/json_utils.dart';

/// Moment du rappel avant l'échéance (formulaire « Nouvelle tâche »).
enum Reminder {
  dayBefore('La veille'),
  sameDay('Le jour J'),
  none('Aucun');

  const Reminder(this.label);

  final String label;

  static Reminder fromName(String? name) => Reminder.values.firstWhere(
    (r) => r.name == name,
    orElse: () => Reminder.dayBefore,
  );
}

/// Une échéance à rendre (TP, projet, examen...) rattachée à un cours.
class Task {
  final String id;
  final String title;
  final String courseId;
  final DateTime dueDate;
  final String? description;
  final bool isDone;
  final Reminder reminder;

  const Task({
    required this.id,
    required this.title,
    required this.courseId,
    required this.dueDate,
    this.description,
    this.isDone = false,
    this.reminder = Reminder.dayBefore,
  });

  /// Clés JSON du serveur (`/taches`), comme dans le cours :
  /// `id`, `titre`, `coursId`, `echeance` (ISO 8601), `terminee`,
  /// `description` (facultative), `rappel`.
  factory Task.fromJson(Map<String, dynamic> json) {
    final title = readField<String>(json, 'titre', 'Task');
    if (title.trim().isEmpty) {
      throw const FormatException('Task : le titre ne peut pas être vide');
    }
    return Task(
      id: readId(json, 'Task'),
      title: title,
      courseId: readField<String>(json, 'coursId', 'Task'),
      dueDate: readDate(json, 'echeance', 'Task'),
      description: readOptionalField<String>(json, 'description', 'Task'),
      isDone: readOptionalField<bool>(json, 'terminee', 'Task') ?? false,
      reminder: Reminder.fromName(
        readOptionalField<String>(json, 'rappel', 'Task'),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'titre': title,
    'coursId': courseId,
    'echeance': dueDate.toIso8601String(),
    'description': description,
    'terminee': isDone,
    'rappel': reminder.name,
  };

  /// Les objets sont immuables : on crée une copie modifiée.
  Task copyWith({
    String? id,
    String? title,
    String? courseId,
    DateTime? dueDate,
    String? description,
    bool? isDone,
    Reminder? reminder,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      courseId: courseId ?? this.courseId,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      reminder: reminder ?? this.reminder,
    );
  }

  /// En retard : l'échéance est dépassée et la tâche n'est pas faite.
  bool isOverdue(DateTime now) => !isDone && dueDate.isBefore(now);

  @override
  bool operator ==(Object other) =>
      other is Task &&
      other.id == id &&
      other.title == title &&
      other.courseId == courseId &&
      other.dueDate == dueDate &&
      other.description == description &&
      other.isDone == isDone &&
      other.reminder == reminder;

  @override
  int get hashCode =>
      Object.hash(id, title, courseId, dueDate, description, isDone, reminder);

  @override
  String toString() =>
      'Task($id, "$title", cours: $courseId, échéance: $dueDate, '
      'fait: $isDone)';
}
