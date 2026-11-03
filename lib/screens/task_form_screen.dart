import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/date_labels.dart';

/// Formulaire « Nouvelle tâche » (maquette H4), aussi utilisé pour
/// « Modifier ». Renvoie la [Task] via `Navigator.pop`, ou rien si
/// l'utilisateur ferme l'écran.
///
/// Job story 1 : enregistrer une échéance en moins de 3 appuis, d'où le
/// cours, la date et le rappel pré-remplis.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, this.initialTask});

  final Task? initialTask;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initialTask?.title);
  late final _description = TextEditingController(
    text: widget.initialTask?.description,
  );
  final _dateText = TextEditingController();
  final _timeText = TextEditingController();

  late String _courseId =
      widget.initialTask?.courseId ?? sampleCourses.first.id;
  late Reminder _reminder = widget.initialTask?.reminder ?? Reminder.dayBefore;
  late DateTime _dueDate = widget.initialTask?.dueDate ?? _defaultDueDate();

  bool get _isEditing => widget.initialTask != null;

  /// Par défaut : demain à 23 h 59.
  static DateTime _defaultDueDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1, 23, 59);
  }

  @override
  void initState() {
    super.initState();
    _syncDateFields();
  }

  @override
  void dispose() {
    // Les contrôleurs sont libérés avec l'écran.
    _title.dispose();
    _description.dispose();
    _dateText.dispose();
    _timeText.dispose();
    super.dispose();
  }

  void _syncDateFields() {
    _dateText.text = compactDateLabel(_dueDate);
    _timeText.text = hourLabel(_dueDate);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate.isBefore(today) ? today : _dueDate,
      firstDate: _dueDate.isBefore(today) ? _dueDate : today,
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: "Date de l'échéance",
    );
    if (date == null) return;
    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        _dueDate.hour,
        _dueDate.minute,
      );
      _syncDateFields();
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate),
      helpText: 'Heure limite',
    );
    if (time == null) return;
    setState(() {
      _dueDate = DateTime(
        _dueDate.year,
        _dueDate.month,
        _dueDate.day,
        time.hour,
        time.minute,
      );
      _syncDateFields();
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final description = _description.text.trim();
    final base =
        widget.initialTask ??
        Task(
          id: 't${DateTime.now().microsecondsSinceEpoch}',
          title: '',
          courseId: _courseId,
          dueDate: _dueDate,
        );
    final task = Task(
      id: base.id,
      title: _title.text.trim(),
      courseId: _courseId,
      dueDate: _dueDate,
      description: description.isEmpty ? null : description,
      isDone: base.isDone,
      reminder: _reminder,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? '« ${task.title} » modifiée'
              : '« ${task.title} » ajoutée aux échéances',
        ),
      ),
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Fermer sans enregistrer',
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Text(_isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          // Défilant : le clavier et le paysage réduisent la hauteur.
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Field(
                      label: 'Titre',
                      child: TextFormField(
                        controller: _title,
                        autofocus: !_isEditing,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Ex. : Exposé en binôme',
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'Titre requis';
                          if (text.length < 3) return 'Au moins 3 caractères';
                          return null;
                        },
                      ),
                    ),
                    _Field(
                      label: 'Cours',
                      child: DropdownButtonFormField<String>(
                        initialValue: _courseId,
                        // Sans isExpanded, un nom de cours long déborde
                        // sur un téléphone de 360 dp.
                        isExpanded: true,
                        style: theme.textTheme.bodyLarge,
                        borderRadius: BorderRadius.circular(AppRadius.field),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: [
                          for (final course in sampleCourses)
                            DropdownMenuItem(
                              value: course.id,
                              child: Text(course.name),
                            ),
                        ],
                        onChanged: (value) =>
                            setState(() => _courseId = value ?? _courseId),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _Field(
                            label: 'Date',
                            child: TextFormField(
                              controller: _dateText,
                              readOnly: true,
                              onTap: _pickDate,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.calendar_today_outlined,
                                  size: 20,
                                ),
                              ),
                              validator: (_) =>
                                  !_isEditing &&
                                      _dueDate.isBefore(DateTime.now())
                                  ? 'Date passée'
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Field(
                            label: 'Heure',
                            child: TextFormField(
                              controller: _timeText,
                              readOnly: true,
                              onTap: _pickTime,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.schedule_rounded,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    _Field(
                      label: 'Rappel',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final reminder in Reminder.values)
                            ChoiceChip(
                              label: Text(reminder.label),
                              selected: _reminder == reminder,
                              onSelected: (_) =>
                                  setState(() => _reminder = reminder),
                            ),
                        ],
                      ),
                    ),
                    _Field(
                      label: 'Consigne (facultatif)',
                      child: TextFormField(
                        controller: _description,
                        minLines: 3,
                        maxLines: 6,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Ce qu’il faut rendre, où le déposer…',
                        ),
                      ),
                    ),
                    if (!_isEditing) ...[
                      Text(
                        'Cours, date et rappel sont pré-remplis',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    FilledButton(
                      onPressed: _save,
                      child: const Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Libellé au-dessus du champ, comme dans la maquette.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Semantics(
        label: label,
        container: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}
