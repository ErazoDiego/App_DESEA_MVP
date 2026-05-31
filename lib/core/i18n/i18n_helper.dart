import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// Extension on [BuildContext] para acceso rápido a traducciones.
///
/// Uso:
/// ```dart
/// context.l10n.appName        // → "DESEA"
/// context.l10n.siguiente       // → "Siguiente"
/// context.l10n.statsLine       // → "+150 cartas · 3 niveles · 2 modos"
/// ```
extension I18nHelper on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
