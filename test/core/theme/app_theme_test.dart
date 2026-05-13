import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:desea_mvp/core/theme/app_theme.dart';

void main() {
  group('AppColorsTheme', () {
    test('dark instance has correct colors', () {
      const theme = AppColorsTheme.dark;

      expect(theme.background.value, 0xFF07000F);
      expect(theme.fuchsiaAccent.value, 0xFFA21CAF);
      expect(theme.surface.value, 0xFF1A1A2E);
      expect(theme.onSurface.value, 0xFFE0E0E0);
      expect(theme.onSurfaceSecondary.value, 0xFF9E9E9E);
    });

    test('copyWith preserves values when no arguments', () {
      const theme = AppColorsTheme.dark;
      final copied = theme.copyWith();

      expect(copied.background, theme.background);
      expect(copied.fuchsiaAccent, theme.fuchsiaAccent);
      expect(copied.surface, theme.surface);
      expect(copied.onSurface, theme.onSurface);
      expect(copied.onSurfaceSecondary, theme.onSurfaceSecondary);
    });

    test('copyWith overrides specified values', () {
      const theme = AppColorsTheme.dark;
      final copied = theme.copyWith(background: Colors.white);

      expect(copied.background, Colors.white);
      expect(copied.fuchsiaAccent, theme.fuchsiaAccent);
      expect(copied.surface, theme.surface);
      expect(copied.onSurface, theme.onSurface);
      expect(copied.onSurfaceSecondary, theme.onSurfaceSecondary);
    });
  });

  group('DESEATheme', () {
    test('darkTheme has correct scaffold background', () {
      final theme = DESEATheme.darkTheme;

      expect(theme.scaffoldBackgroundColor.value, 0xFF07000F);
    });

    test('darkTheme includes AppColorsTheme extension', () {
      final theme = DESEATheme.darkTheme;
      final extension = theme.extension<AppColorsTheme>();

      expect(extension, isNotNull);
      expect(extension!.background.value, 0xFF07000F);
    });
  });
}
