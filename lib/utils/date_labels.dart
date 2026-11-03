import 'package:intl/intl.dart';

import '../models/task.dart';

const _locale = 'fr_FR';

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

int _dayOffset(DateTime date, DateTime now) =>
    _dateOnly(date).difference(_dateOnly(now)).inDays;

String _capitalize(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

/// « 23 h 59 », « 18 h ».
String hourLabel(DateTime date) => date.minute == 0
    ? '${date.hour} h'
    : '${date.hour} h ${date.minute.toString().padLeft(2, '0')}';

/// En-tête de groupe de la liste : « Aujourd'hui », « Demain · jeudi 15 »,
/// « Vendredi 16 », « Lundi 9 nov. » (au-delà de la semaine).
String sectionLabel(DateTime date, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final offset = _dayOffset(date, today);
  final weekday = DateFormat('EEEE d', _locale).format(date);
  return switch (offset) {
    0 => "Aujourd'hui",
    1 => 'Demain · $weekday',
    -1 => 'Hier · $weekday',
    > 1 && < 7 => _capitalize(weekday),
    _ => _capitalize(DateFormat('EEEE d MMM', _locale).format(date)),
  };
}

/// « aujourd'hui », « demain », « hier », « ven. » (dans la semaine) ou
/// « lun. 9 nov. ».
String shortDayLabel(DateTime date, {DateTime? now}) {
  final offset = _dayOffset(date, now ?? DateTime.now());
  return switch (offset) {
    0 => "aujourd'hui",
    1 => 'demain',
    -1 => 'hier',
    > 1 && < 7 => DateFormat('EEEE', _locale).format(date),
    _ => DateFormat('EEE d MMM', _locale).format(date),
  };
}

/// « Vendredi 16 octobre · 17 h ».
String fullDateLabel(DateTime date) =>
    '${_capitalize(DateFormat('EEEE d MMMM', _locale).format(date))} · '
    '${hourLabel(date)}';

/// « Ven. 16 oct. » (bouton Date du formulaire).
String compactDateLabel(DateTime date) =>
    _capitalize(DateFormat('EEE d MMM', _locale).format(date));

/// Sous-titre de l'écran Échéances : « Mar. 3 – dim. 8 novembre ».
String weekRangeLabel({DateTime? now}) {
  final start = _dateOnly(now ?? DateTime.now());
  final end = start.add(Duration(days: DateTime.sunday - start.weekday));
  final first = DateFormat('EEE d', _locale).format(start);
  final last = start.month == end.month
      ? DateFormat('EEE d MMMM', _locale).format(end)
      : DateFormat('EEE d MMM', _locale).format(end);
  return start == end
      ? _capitalize(DateFormat('EEEE d MMMM', _locale).format(start))
      : '${_capitalize(first)} – $last';
}

/// Puce d'état du détail : « Aujourd'hui », « Demain », « Dans 2 jours »,
/// « En retard ».
String relativeDueLabel(DateTime date, {DateTime? now}) {
  final current = now ?? DateTime.now();
  if (date.isBefore(current)) return 'En retard';
  final offset = _dayOffset(date, current);
  return switch (offset) {
    0 => "Aujourd'hui",
    1 => 'Demain',
    _ => 'Dans $offset jours',
  };
}

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
