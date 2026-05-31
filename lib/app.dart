import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/hive_datasource.dart';
import 'l10n/app_localizations.dart';
import 'presentation/routes/app_router.dart';

class DESEAApp extends ConsumerWidget {
  const DESEAApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warm up lazy FutureProviders so their sync counterparts
    // (cartaBoxProvider2, personalizadasBoxProvider2, perfilRepositoryProvider)
    // resolve immediately when first accessed. Since openAllBoxes() already
    // opened all Hive boxes, these futures resolve before the first frame.
    ref.watch(cartaBoxProvider);
    ref.watch(personalizadasBoxProvider);

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'DESEA',
      theme: DESEATheme.darkTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
