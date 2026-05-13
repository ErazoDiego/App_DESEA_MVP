import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/hive_datasource.dart';
import '../../data/repositories/perfil_repository_impl.dart';
import '../../domain/repositories/perfil_repository.dart';

final perfilRepositoryProvider = Provider<PerfilRepository>((ref) {
  final box = ref.watch(perfilBoxProvider).asData?.value;
  if (box == null) throw Exception('Perfil box not initialized');
  return PerfilRepositoryImpl(box);
});
