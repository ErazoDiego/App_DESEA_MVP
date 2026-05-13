import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/hive_datasource.dart';
import '../../data/repositories/mazo_repository_impl.dart';
import '../../domain/repositories/mazo_repository.dart';

final mazoRepositoryProvider = Provider<MazoRepository>((ref) {
  final box = ref.watch(mazoBoxProvider).asData?.value;
  if (box == null) throw Exception('Mazos box not initialized');
  return MazoRepositoryImpl(box);
});
