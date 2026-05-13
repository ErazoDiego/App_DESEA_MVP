/// Representa el perfil de usuario con preferencias y estado del onboarding.
///
/// [Perfil] almacena la edad del usuario, el estado de finalización del
/// flujo de onboarding y configuraciones personalizadas. Se persiste
/// localmente a través de Hive.
class Perfil {
  final String id;
  final int edad;
  final bool onboardingCompletado;
  final Map<String, dynamic> settings;
  final DateTime creadoEn;

  const Perfil({
    required this.id,
    required this.edad,
    this.onboardingCompletado = false,
    this.settings = const {},
    required this.creadoEn,
  });

  Perfil copyWith({
    String? id,
    int? edad,
    bool? onboardingCompletado,
    Map<String, dynamic>? settings,
    DateTime? creadoEn,
  }) {
    return Perfil(
      id: id ?? this.id,
      edad: edad ?? this.edad,
      onboardingCompletado: onboardingCompletado ?? this.onboardingCompletado,
      settings: settings ?? this.settings,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Perfil &&
        other.id == id &&
        other.edad == edad &&
        other.onboardingCompletado == onboardingCompletado &&
        _mapEquals(other.settings, settings) &&
        other.creadoEn == creadoEn;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      edad,
      onboardingCompletado,
      Object.hashAll(settings.keys),
      Object.hashAll(settings.values),
      creadoEn,
    );
  }

  @override
  String toString() {
    return 'Perfil(id: $id, edad: $edad, '
        'onboardingCompletado: $onboardingCompletado, '
        'settings: $settings, creadoEn: $creadoEn)';
  }

  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) return false;
    }
    return true;
  }
}
