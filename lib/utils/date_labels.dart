import 'package:intl/intl.dart';

const _locale = 'fr_FR';

/// « aujourd'hui », « demain », « hier » ou « ven. 6 nov. ».
String dayLabel(DateTime date, {DateTime? now}) {
  final today = _dateOnly(now ?? DateTime.now());
  final difference = _dateOnly(date).difference(today).inDays;
  return switch (difference) {
    0 => "aujourd'hui",
    1 => 'demain',
    -1 => 'hier',
    _ => DateFormat('EEE d MMM', _locale).format(date),
  };
}

/// « demain · 23:59 ».
String dueLabel(DateTime date, {DateTime? now}) =>
    '${dayLabel(date, now: now)} · ${DateFormat.Hm(_locale).format(date)}';

/// « vendredi 6 novembre 2026 à 17:00 ».
String fullDateLabel(DateTime date) =>
    "${DateFormat('EEEE d MMMM y', _locale).format(date)} à "
    '${DateFormat.Hm(_locale).format(date)}';

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
