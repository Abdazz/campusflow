import 'package:campusflow/features/taches/domain/task.dart';

// Règles métier d’une tâche (logique pure, aucune dépendance à Flutter) :
// état de la carte, en retard, moment du rappel.

/// Moment du rappel : la veille à 18 h, le jour même à 8 h.
DateTime? reminderDate(Task task) => switch (task.reminder) {
  Reminder.dayBefore => DateTime(
    task.dueDate.year,
    task.dueDate.month,
    task.dueDate.day - 1,
    18,
  ),
  Reminder.sameDay => DateTime(
    task.dueDate.year,
    task.dueDate.month,
    task.dueDate.day,
    8,
  ),
  Reminder.none => null,
};

/// États de la carte de tâche (page de tokens).
enum TaskState { overdue, urgent, todo, done }

extension TaskStateX on Task {
  TaskState stateAt(DateTime now) {
    if (isDone) return TaskState.done;
    if (dueDate.isBefore(now)) return TaskState.overdue;
    if (dueDate.difference(now) < const Duration(hours: 24)) {
      return TaskState.urgent;
    }
    return TaskState.todo;
  }
}
