import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/datasources/hive_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and open ALL boxes before runApp. This guarantees
  // every box FutureProvider resolves synchronously on the first frame,
  // so GoRouter's redirect never catches an uninitialized-box error.
  await initHive();
  await openAllBoxes();

  runApp(
    const ProviderScope(
      child: DESEAApp(),
    ),
  );
}
