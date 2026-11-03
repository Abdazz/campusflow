import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/date_labels.dart';

/// Formulaire « Nouvelle tâche ». Renvoie la [Task] créée via
/// `Navigator.pop`, ou rien si l'utilisateur ferme l'écran.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _dueDateText = TextEditingController();

  String? _courseId;
  DateTime? _dueDate;

  @override
  void dispose() {
    // Les contrôleurs sont libérés avec l'écran.
    _title.dispose();
    _description.dispose();
    _dueDateText.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final initial = _dueDate ?? now.add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: "Date d'échéance",
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _dueDate != null
          ? TimeOfDay.fromDateTime(_dueDate!)
          : const TimeOfDay(hour: 23, minute: 59),
      helpText: 'Heure limite',
    );
    if (time == null) return;

    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _dueDateText.text = fullDateLabel(_dueDate!);
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final description = _description.text.trim();
    final task = Task(
      id: 't${DateTime.now().microsecondsSinceEpoch}',
      title: _title.text.trim(),
      courseId: _courseId!,
      dueDate: _dueDate!,
      description: description.isEmpty ? null : description,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('« ${task.title} » ajoutée aux échéances')),
    );
    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Fermer',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Nouvelle tâche'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          // Défilant : le clavier et le paysage réduisent la hauteur.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _title,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Titre',
                        hintText: 'Ex. : Rendu TP Flutter',
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Titre requis';
                        if (text.length < 3) return 'Au moins 3 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _courseId,
                      // Sans isExpanded, un nom de cours long déborde
                      // sur un téléphone de 360 dp.
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Cours'),
                      items: [
                        for (final course in sampleCourses)
                          DropdownMenuItem(
                            value: course.id,
                            child: Text(course.name),
                          ),
                      ],
                      onChanged: (value) => setState(() => _courseId = value),
                      validator: (value) =>
                          value == null ? 'Choisis un cours' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _dueDateText,
                      readOnly: true,
                      onTap: _pickDueDate,
                      decoration: const InputDecoration(
                        labelText: 'Échéance',
                        hintText: 'Choisir une date',
                        suffixIcon: Icon(Icons.event),
                      ),
                      validator: (_) =>
                          _dueDate == null ? 'Date requise' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _description,
                      minLines: 3,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Description (facultatif)',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
