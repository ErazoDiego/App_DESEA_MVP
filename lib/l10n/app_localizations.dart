import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
    Locale('pt'),
  ];

  /// App display name
  ///
  /// In es, this message translates to:
  /// **'DESEA'**
  String get appName;

  /// Tagline on welcome/home screen
  ///
  /// In es, this message translates to:
  /// **'Tu noche empieza acá'**
  String get tagline;

  /// Button to start the game
  ///
  /// In es, this message translates to:
  /// **'Empezar noche'**
  String get startNight;

  /// Link to game instructions
  ///
  /// In es, this message translates to:
  /// **'Cómo se juega'**
  String get howToPlay;

  /// Session mode label
  ///
  /// In es, this message translates to:
  /// **'Sesión'**
  String get sesion;

  /// Free play mode label
  ///
  /// In es, this message translates to:
  /// **'Libre'**
  String get libre;

  /// Generic save action
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// Generic next step
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get next;

  /// Pause session
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get pause;

  /// Stats line on welcome/home
  ///
  /// In es, this message translates to:
  /// **'+150 cartas · 3 niveles · 2 modos'**
  String get statsLine;

  /// Button to start onboarding
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get comenzar;

  /// Age verification screen title
  ///
  /// In es, this message translates to:
  /// **'Verificación de edad'**
  String get onboardingAgeTitle;

  /// Age verification body text
  ///
  /// In es, this message translates to:
  /// **'Debés ser mayor de 18 años para usar DESEA.'**
  String get onboardingAgeBody;

  /// Age field label
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get edad;

  /// Years unit
  ///
  /// In es, this message translates to:
  /// **'años'**
  String get anyos;

  /// Confirm age button
  ///
  /// In es, this message translates to:
  /// **'Confirmar edad'**
  String get confirmarEdad;

  /// Mode selection title
  ///
  /// In es, this message translates to:
  /// **'Seleccioná tu modo'**
  String get seleccionaModo;

  /// Session mode name
  ///
  /// In es, this message translates to:
  /// **'Sesión'**
  String get modoSesion;

  /// Session mode description
  ///
  /// In es, this message translates to:
  /// **'20 cartas con arco progresivo'**
  String get modoSesionDesc;

  /// Free mode name
  ///
  /// In es, this message translates to:
  /// **'Libre'**
  String get modoLibre;

  /// Free mode description
  ///
  /// In es, this message translates to:
  /// **'Elegí las cartas que quieras'**
  String get modoLibreDesc;

  /// Generic next button
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get siguiente;

  /// Instructions screen title
  ///
  /// In es, this message translates to:
  /// **'Cómo se juega'**
  String get comoSeJuega;

  /// Swipe gesture instruction
  ///
  /// In es, this message translates to:
  /// **'Deslizá las cartas para pasar a la siguiente'**
  String get swipeGesture;

  /// Save cards gesture instruction
  ///
  /// In es, this message translates to:
  /// **'Guardá tus cartas favoritas'**
  String get guardarGesture;

  /// Wildcard gesture instruction
  ///
  /// In es, this message translates to:
  /// **'Usá comodines para personalizar la experiencia'**
  String get comodinGesture;

  /// I understood button
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get entendido;

  /// Ready screen title
  ///
  /// In es, this message translates to:
  /// **'¡Todo listo!'**
  String get todoListo;

  /// Configuration summary title
  ///
  /// In es, this message translates to:
  /// **'Resumen de tu configuración'**
  String get resumenConfig;

  /// Mode label
  ///
  /// In es, this message translates to:
  /// **'Modo'**
  String get modo;

  /// Start button
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get empezar;

  /// GameHub screen title
  ///
  /// In es, this message translates to:
  /// **'Elegí cómo jugar'**
  String get gameHubTitle;

  /// Libre card description in hub
  ///
  /// In es, this message translates to:
  /// **'Armá tu propio mazo'**
  String get libreCardDescription;

  /// Mode explanation text
  ///
  /// In es, this message translates to:
  /// **'Sesión: 20 cartas con arco progresivo. Libre: armá tu propio mazo.'**
  String get modoExplicacion;

  /// Collection section title
  ///
  /// In es, this message translates to:
  /// **'Tu colección'**
  String get gameHubColeccionSection;

  /// Hero subtitle
  ///
  /// In es, this message translates to:
  /// **'Tu noche empieza acá'**
  String get gameHubImmersionSubtitle;

  /// Spicy mood pill
  ///
  /// In es, this message translates to:
  /// **'Picante'**
  String get moodPicante;

  /// Fun mood pill
  ///
  /// In es, this message translates to:
  /// **'Divertido'**
  String get moodDivertido;

  /// Session duration chip
  ///
  /// In es, this message translates to:
  /// **'~30 min'**
  String get gameHubSesionDuracion;

  /// Session type chip
  ///
  /// In es, this message translates to:
  /// **'Progresivo'**
  String get gameHubSesionTipo;

  /// Recommended badge
  ///
  /// In es, this message translates to:
  /// **'Recomendado'**
  String get gameHubRecomendado;

  /// User cards section title
  ///
  /// In es, this message translates to:
  /// **'Tus cartas'**
  String get gameHubTusCartasSection;

  /// Session loading message
  ///
  /// In es, this message translates to:
  /// **'Preparando sesión...'**
  String get preparandoSesion;

  /// Session completed message
  ///
  /// In es, this message translates to:
  /// **'¡Sesión completada!'**
  String get sesionCompletada;

  /// Session paused message
  ///
  /// In es, this message translates to:
  /// **'Sesión pausada'**
  String get sesionPausada;

  /// Continue button
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continuar;

  /// Restart session button
  ///
  /// In es, this message translates to:
  /// **'Reiniciar sesión'**
  String get reiniciarSesion;

  /// Go back to home button
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get volverInicio;

  /// Wildcard coming soon message
  ///
  /// In es, this message translates to:
  /// **'Comodín: próximamente'**
  String get comodinProximamente;

  /// Already saved label
  ///
  /// In es, this message translates to:
  /// **'Guardada'**
  String get guardada;

  /// Save current card button
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// Finish session button
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get finalizar;

  /// Pause button
  ///
  /// In es, this message translates to:
  /// **'Pausar'**
  String get pausar;

  /// Retry button
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get reintentar;

  /// No active session message
  ///
  /// In es, this message translates to:
  /// **'No hay sesión activa'**
  String get noSesionActiva;

  /// Start session button
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get iniciarSesion;

  /// Chosen mode label
  ///
  /// In es, this message translates to:
  /// **'Modo elegido'**
  String get sesionModoElegido;

  /// Estimated duration badge
  ///
  /// In es, this message translates to:
  /// **'~30 min'**
  String get sesionDuracion;

  /// Timeline title
  ///
  /// In es, this message translates to:
  /// **'Así va la sesión'**
  String get sesionAsiVaLaSesion;

  /// Level 1 title
  ///
  /// In es, this message translates to:
  /// **'Nivel 1 · Suave'**
  String get sesionNivel1;

  /// Level 1 description
  ///
  /// In es, this message translates to:
  /// **'Preguntas para romper el hielo y soltar la lengua.'**
  String get sesionNivel1Desc;

  /// Level 2 title
  ///
  /// In es, this message translates to:
  /// **'Nivel 2 · Íntimo'**
  String get sesionNivel2;

  /// Level 2 description
  ///
  /// In es, this message translates to:
  /// **'Deseos, fantasías y lo que nunca dijiste.'**
  String get sesionNivel2Desc;

  /// Level 3 title
  ///
  /// In es, this message translates to:
  /// **'Nivel 3 · Sin filtro'**
  String get sesionNivel3;

  /// Level 3 description
  ///
  /// In es, this message translates to:
  /// **'Solo para cuando ya no hay vuelta atrás.'**
  String get sesionNivel3Desc;

  /// Primary CTA to start session
  ///
  /// In es, this message translates to:
  /// **'Empezar sesión'**
  String get empezarSesion;

  /// Change mode button
  ///
  /// In es, this message translates to:
  /// **'Cambiar modo'**
  String get cambiarModo;

  /// Session stats: card count
  ///
  /// In es, this message translates to:
  /// **'20 cartas'**
  String get sesionStatsCartas;

  /// Session stats: level count
  ///
  /// In es, this message translates to:
  /// **'3 niveles'**
  String get sesionStatsNiveles;

  /// Session stats: decks (unused)
  ///
  /// In es, this message translates to:
  /// **'2 mazos'**
  String get sesionStatsMazos;

  /// Warm-up phase name
  ///
  /// In es, this message translates to:
  /// **'Calentamiento'**
  String get calentamiento;

  /// Tension phase name
  ///
  /// In es, this message translates to:
  /// **'Tensión'**
  String get tension;

  /// Climax phase name
  ///
  /// In es, this message translates to:
  /// **'Clímax'**
  String get climax;

  /// Closing phase name
  ///
  /// In es, this message translates to:
  /// **'Cierre'**
  String get cierre;

  /// Create deck button
  ///
  /// In es, this message translates to:
  /// **'Crear mazo'**
  String get libreCrearMazo;

  /// Create card button
  ///
  /// In es, this message translates to:
  /// **'Crear carta'**
  String get libreCrearCartaPers;

  /// Card name field label
  ///
  /// In es, this message translates to:
  /// **'Nombre de la carta'**
  String get libreCardNameLabel;

  /// Instruction field label
  ///
  /// In es, this message translates to:
  /// **'Instrucción'**
  String get libreInstruccionLabel;

  /// Category field label
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get libreCategoriaLabel;

  /// Level field label
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get libreNivelLabel;

  /// Time field label
  ///
  /// In es, this message translates to:
  /// **'Tiempo (segundos)'**
  String get libreTiempoLabel;

  /// Directed to field label
  ///
  /// In es, this message translates to:
  /// **'Dirigida a'**
  String get libreDirigidaLabel;

  /// Save card button
  ///
  /// In es, this message translates to:
  /// **'Guardar carta'**
  String get libreGuardarCarta;

  /// Card created snackbar
  ///
  /// In es, this message translates to:
  /// **'¡Carta creada!'**
  String get libreCartaCreada;

  /// Deck name hint
  ///
  /// In es, this message translates to:
  /// **'Nombre del mazo'**
  String get libreDeckNameHint;

  /// Deck completed message
  ///
  /// In es, this message translates to:
  /// **'¡Mazo completado!'**
  String get libreMazoCompletado;

  /// Previous card button
  ///
  /// In es, this message translates to:
  /// **'Anterior'**
  String get anterior;

  /// Required field: name
  ///
  /// In es, this message translates to:
  /// **'El nombre es obligatorio'**
  String get libreNameRequired;

  /// Required field: instruction
  ///
  /// In es, this message translates to:
  /// **'La instrucción es obligatoria'**
  String get libreInstruccionRequired;

  /// Saved cards screen title
  ///
  /// In es, this message translates to:
  /// **'Guardadas'**
  String get savedCardsTitle;

  /// Empty saved cards message
  ///
  /// In es, this message translates to:
  /// **'Todavía no guardaste ninguna carta'**
  String get savedCardsEmpty;

  /// All filter label
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get savedCardsFilterAll;

  /// No matching cards message
  ///
  /// In es, this message translates to:
  /// **'No hay cartas que coincidan'**
  String get savedCardsNoMatch;

  /// Delete confirmation title
  ///
  /// In es, this message translates to:
  /// **'Eliminar carta'**
  String get savedCardsDeleteTitle;

  /// Delete confirmation button
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get savedCardsDeleteConfirm;

  /// Hub access title for saved cards
  ///
  /// In es, this message translates to:
  /// **'Cartas guardadas'**
  String get savedCardsHubTitle;

  /// Custom cards screen title
  ///
  /// In es, this message translates to:
  /// **'Tus cartas'**
  String get misCartasTitle;

  /// Empty custom cards message
  ///
  /// In es, this message translates to:
  /// **'Todavía no creaste ninguna carta personalizada'**
  String get misCartasEmpty;

  /// Edit card dialog title
  ///
  /// In es, this message translates to:
  /// **'Editar carta'**
  String get misCartasEditTitle;

  /// Delete card confirmation title
  ///
  /// In es, this message translates to:
  /// **'Eliminar carta'**
  String get misCartasDeleteTitle;

  /// Delete card confirmation button
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get misCartasDeleteConfirm;

  /// Hub access title for custom cards
  ///
  /// In es, this message translates to:
  /// **'Mis cartas'**
  String get misCartasHubTitle;

  /// Create card form title
  ///
  /// In es, this message translates to:
  /// **'Crear carta'**
  String get misCartasFormCreateTitle;

  /// Edit card form title
  ///
  /// In es, this message translates to:
  /// **'Editar carta personalizada'**
  String get misCartasFormEditTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
