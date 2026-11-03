import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/task.dart';
import 'other_tabs.dart';
import 'task_form_screen.dart';
import 'tasks_screen.dart';

/// Ossature principale : AppBar, onglets (NavigationBar) et bouton flottant.
///
/// L'état (liste des tâches, sélection) vit ici et est géré avec
/// `setState` ; Riverpod prendra le relais à la séance 6.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialTasks});

  /// Pour les tests : remplace les données d'exemple.
  final List<Task>? initialTasks;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late final List<Task> _tasks = [...(widget.initialTasks ?? sampleTasks())];
  int _tabIndex = 0;
  String? _selectedTaskId;

  /// Les tâches à faire d'abord, chacune triée par échéance.
  List<Task> get _sortedTasks => [..._tasks]
    ..sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      return a.dueDate.compareTo(b.dueDate);
    });

  void _replaceTask(Task updated) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == updated.id);
      if (index != -1) _tasks[index] = updated;
    });
  }

  Future<void> _addTask() async {
    final task = await Navigator.of(context).push<Task>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const TaskFormScreen(),
      ),
    );
    if (task == null) return;
    setState(() {
      _tasks.add(task);
      _selectedTaskId = task.id;
    });
  }

  static const _titles = ['Échéances', 'Cours', 'Profil'];

  @override
  Widget build(BuildContext context) {
    final tasks = _sortedTasks;

    final body = switch (_tabIndex) {
      0 => TasksView(
        tasks: tasks,
        selectedTaskId: _selectedTaskId,
        onSelect: (task) => setState(() => _selectedTaskId = task.id),
        onToggleDone: _replaceTask,
      ),
      1 => CoursesView(tasks: tasks),
      _ => const ProfileView(),
    };

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tabIndex])),
      body: SafeArea(child: body),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _addTask,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle tâche'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Échéances',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Cours',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
