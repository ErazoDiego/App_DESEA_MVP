import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Extensión de [ThemeExtension] que define la paleta de colores DESEA.
///
/// Extiende [ThemeExtension] para proveer acceso tipado a colores
/// específicos de la app a través del sistema de temas, garantizando
/// consistencia visual en toda la aplicación.
class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  final Color background;
  final Color fuchsiaAccent;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceSecondary;

  const AppColorsTheme({
    required this.background,
    required this.fuchsiaAccent,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceSecondary,
  });

  /// Variante oscura del tema de colores DESEA.
  static const AppColorsTheme dark = AppColorsTheme(
    background: AppColors.background,
    fuchsiaAccent: AppColors.fuchsiaAccent,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    onSurfaceSecondary: AppColors.onSurfaceSecondary,
  );

  @override
  AppColorsTheme copyWith({
    Color? background,
    Color? fuchsiaAccent,
    Color? surface,
    Color? onSurface,
    Color? onSurfaceSecondary,
  }) {
    return AppColorsTheme(
      background: background ?? this.background,
      fuchsiaAccent: fuchsiaAccent ?? this.fuchsiaAccent,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceSecondary: onSurfaceSecondary ?? this.onSurfaceSecondary,
    );
  }

  @override
  ThemeExtension<AppColorsTheme> lerp(
    covariant ThemeExtension<AppColorsTheme>? other,
    double t,
  ) {
    if (other is! AppColorsTheme) return this;
    return AppColorsTheme(
      background: Color.lerp(background, other.background, t)!,
      fuchsiaAccent: Color.lerp(fuchsiaAccent, other.fuchsiaAccent, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceSecondary:
          Color.lerp(onSurfaceSecondary, other.onSurfaceSecondary, t)!,
    );
  }
}

/// Configuración central del tema para la aplicación DESEA.
///
/// Provee el [darkTheme] usado como tema único de la app,
/// integrando colores personalizados y el tema estándar de Material.
class DESEATheme {
  DESEATheme._();

  /// Configuración del tema oscuro de la aplicación.
  ///
  /// Usa un esquema de colores oscuro con acentos fucsia y colores
  /// de superficie personalizados definidos en [AppColorsTheme].
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.fuchsiaAccent,
        secondary: AppColors.fuchsiaAccent,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      extensions: const [AppColorsTheme.dark],
    );
  }
}
