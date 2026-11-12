import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:campusflow/core/theme.dart';

/// Ossature commune aux trois destinations, construite par la `ShellRoute`.
///
/// Téléphone (< 600 dp) : barre de navigation inférieure.
/// À partir de 600 dp : rail de navigation à gauche (page de tokens).
///
/// L'onglet actif se déduit de l'adresse : aucun état local.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.location, required this.child});

  /// Adresse courante, par exemple `/taches/t3`.
  final String location;

  /// L'écran de la route active, affiché dans l'ossature.
  final Widget child;

  static const _destinations = [
    (
      path: '/taches',
      icon: Icons.calendar_today_outlined,
      selectedIcon: Icons.calendar_today,
      label: 'Échéances',
    ),
    (
      path: '/cours',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: 'Cours',
    ),
    (
      path: '/profil',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profil',
    ),
  ];

  int get _index {
    final index = _destinations.indexWhere((d) => location.startsWith(d.path));
    return index == -1 ? 0 : index;
  }

  void _goTo(BuildContext context, int index) =>
      context.go(_destinations[index].path);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= AppBreakpoints.medium;
    void addTask() => context.push('/taches/nouvelle');

    return Scaffold(
      body: wide
          ? Row(
              children: [
                SafeArea(
                  right: false,
                  // Le rail descend jusqu'en bas, sous la barre de gestes.
                  bottom: false,
                  child: NavigationRail(
                    selectedIndex: _index,
                    onDestinationSelected: (i) => _goTo(context, i),
                    labelType: NavigationRailLabelType.all,
                    // Avec le rail, le bouton d'ajout se place en tête du
                    // rail (Material 3) : il ne masque plus le détail.
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 16),
                      child: FloatingActionButton(
                        onPressed: addTask,
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
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            )
          : child,
      // Le bouton flottant n'apparaît que sur la liste des échéances.
      floatingActionButton: !wide && location == '/taches'
          ? FloatingActionButton.extended(
              onPressed: addTask,
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
                selectedIndex: _index,
                onDestinationSelected: (i) => _goTo(context, i),
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
