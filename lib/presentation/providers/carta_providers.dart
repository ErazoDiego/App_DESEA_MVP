import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/hive_datasource.dart';
import '../../data/repositories/carta_repository_impl.dart';
import '../../domain/repositories/carta_repository.dart';

final cartaRepositoryProvider = Provider<CartaRepository>((ref) {
  final box = ref.watch(cartaBoxProvider).asData?.value;
  if (box == null) throw Exception('Cartas box not initialized');
  return CartaRepositoryImpl(box);
});
