import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Dates en français avec le package intl (« ven. 6 nov. »).
  Intl.defaultLocale = 'fr_FR';
  await initializeDateFormatting('fr_FR');
  // ProviderScope stocke l'état de tous les fournisseurs Riverpod.
  runApp(const ProviderScope(child: CampusFlowApp()));
}

class CampusFlowApp extends ConsumerWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'CampusFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
