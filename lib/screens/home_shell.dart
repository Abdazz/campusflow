import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/date_labels.dart';
import 'other_tabs.dart';
import 'task_form_screen.dart';
import 'tasks_screen.dart';

/// Ossature principale : AppBar, onglets et bouton flottant.
///
/// Téléphone (< 600 dp) : barre de navigation inférieure.
/// À partir de 600 dp : rail de navigation à gauche (page de tokens).
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

  static const _destinations = [
    (
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
      label: 'Échéances',
    ),
    (
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: 'Cours',
    ),
    (icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= AppBreakpoints.medium;

    final body = switch (_tabIndex) {
      0 => TasksView(
        tasks: _tasks,
        selectedTaskId: _selectedTaskId,
        onSelect: (task) => setState(() => _selectedTaskId = task.id),
        onChanged: _replaceTask,
      ),
      1 => CoursesView(tasks: _tasks),
      _ => ProfileView(tasks: _tasks),
    };

    final (String title, String subtitle) = switch (_tabIndex) {
      0 => ('Cette semaine', weekRangeLabel()),
      1 => ('Mes cours', 'Semestre 1 · ${sampleCourses.length} modules'),
      _ => ('Profil', currentUser.program),
    };

    return Scaffold(
      appBar: _HeaderBar(
        title: title,
        subtitle: subtitle,
        onAvatarTap: _tabIndex == 2
            ? null
            : () => setState(() => _tabIndex = 2),
      ),
      body: SafeArea(
        bottom: false,
        child: wide
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: _tabIndex,
                    onDestinationSelected: (i) => setState(() => _tabIndex = i),
                    labelType: NavigationRailLabelType.all,
                    // Avec le rail, le bouton d'ajout se place en tête du
                    // rail (Material 3) : il ne masque plus le détail.
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: FloatingActionButton(
                        onPressed: _addTask,
                        tooltip: 'Nouvelle tâche',
                        elevation: 0,
                        child: const Icon(Icons.add_rounded),
                      ),
                    ),
                    destinations: [
                      for (final d in _destinations)
                        NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selectedIcon),
                          label: Text(d.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: body),
                ],
              )
            : body,
      ),
      floatingActionButton: !wide && _tabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _addTask,
              icon: const Icon(Icons.add_rounded, size: 24),
              label: const Text('Nouvelle tâche'),
            )
          : null,
      bottomNavigationBar: wide
          ? null
          : DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.outlineVariant),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _tabIndex,
                onDestinationSelected: (i) => setState(() => _tabIndex = i),
                destinations: [
                  for (final d in _destinations)
                    NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: d.label,
                    ),
                ],
              ),
            ),
    );
  }
}

/// En-tête des onglets : grand titre, sous-titre et avatar.
class _HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const _HeaderBar({
    required this.title,
    required this.subtitle,
    required this.onAvatarTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onAvatarTap;

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppBar(
      toolbarHeight: 88,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w400,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        if (onAvatarTap != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Tooltip(
              message: 'Profil de ${currentUser.name}',
              child: Material(
                color: colors.primaryContainer,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onAvatarTap,
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: Center(
                      child: Text(
                        currentUser.initials,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
