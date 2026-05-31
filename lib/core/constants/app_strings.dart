/// Constantes de cadena centralizadas para la aplicación DESEA.
///
/// Provee una fuente única de verdad para todo el texto visible al
/// usuario, facilitando la localización y gestión de strings.
class AppStrings {
  AppStrings._();

  /// Nombre visible de la aplicación.
  static const String appName = 'DESEA';

  /// Tagline mostrado en la pantalla de bienvenida y home.
  static const String tagline = 'Tu noche empieza acá';

  /// Etiqueta del botón para comenzar una sesión de juego.
  static const String startNight = 'Empezar noche';

  /// Texto del enlace para ver las instrucciones del juego.
  static const String howToPlay = 'Cómo se juega';

  /// Etiqueta para el modo de sesión estructurada.
  static const String sesion = 'Sesión';

  /// Etiqueta para el modo de sesión libre.
  static const String libre = 'Libre';

  /// Etiqueta genérica para la acción de guardar.
  static const String save = 'Guardar';

  /// Etiqueta genérica para avanzar al siguiente paso.
  static const String next = 'Siguiente';

  /// Etiqueta para pausar la sesión actual.
  static const String pause = 'Pausar';

  // ─────────────────────────────────────────────────────────────
  // Onboarding
  // ─────────────────────────────────────────────────────────────

  /// Línea de estadísticas mostrada en la pantalla de bienvenida.
  static const String statsLine = '+150 cartas · 3 niveles · 2 modos';

  /// Botón para comenzar el flujo de onboarding.
  static const String comenzar = 'Comenzar';

  /// Título de la pantalla de verificación de edad.
  static const String onboardingAgeTitle = 'Verificación de edad';

  /// Cuerpo de la pantalla de verificación de edad.
  static const String onboardingAgeBody =
      'Debés ser mayor de 18 años para usar DESEA.';

  /// Etiqueta para el campo de edad.
  static const String edad = 'Edad';

  /// Unidad de medida para la edad.
  static const String anyos = 'años';

  /// Botón para confirmar la edad ingresada.
  static const String confirmarEdad = 'Confirmar edad';

  /// Título de la pantalla de selección de modo.
  static const String seleccionaModo = 'Seleccioná tu modo';

  /// Nombre del modo Sesión.
  static const String modoSesion = 'Sesión';

  /// Descripción del modo Sesión.
  static const String modoSesionDesc = '20 cartas con arco progresivo';

  /// Nombre del modo Libre.
  static const String modoLibre = 'Libre';

  /// Descripción del modo Libre.
  static const String modoLibreDesc = 'Elegí las cartas que quieras';

  /// Botón genérico para avanzar al siguiente paso del onboarding.
  static const String siguiente = 'Siguiente';

  /// Título de la pantalla de instrucciones.
  static const String comoSeJuega = 'Cómo se juega';

  /// Instrucción para el gesto de deslizar cartas.
  static const String swipeGesture =
      'Deslizá las cartas para pasar a la siguiente';

  /// Instrucción para guardar cartas favoritas.
  static const String guardarGesture = 'Guardá tus cartas favoritas';

  /// Instrucción para usar comodines.
  static const String comodinGesture =
      'Usá comodines para personalizar la experiencia';

  /// Botón para indicar que se entendieron las instrucciones.
  static const String entendido = 'Entendido';

  /// Título de la pantalla de confirmación final.
  static const String todoListo = '¡Todo listo!';

  /// Título de la sección de resumen de configuración.
  static const String resumenConfig = 'Resumen de tu configuración';

  /// Etiqueta para el modo de juego en el resumen.
  static const String modo = 'Modo';

  /// Botón para comenzar a jugar.
  static const String empezar = 'Empezar';

  // ─────────────────────────────────────────────────────────────
  // GameHub
  // ─────────────────────────────────────────────────────────────

  /// Título de la pantalla GameHub para elegir modo de juego.
  static const String gameHubTitle = 'Elegí cómo jugar';

  /// Descripción de la tarjeta de modo Libre.
  static const String libreCardDescription = 'Armá tu propio mazo';

  /// Texto explicativo sobre los modos de juego.
  static const String modoExplicacion =
      'Sesión: 20 cartas con arco progresivo. Libre: armá tu propio mazo.';

  /// Título de la sección "Tu colección" en el hub.
  static const String gameHubColeccionSection = 'Tu colección';

  /// Subtítulo de inmersión mostrado en la sección hero del hub.
  static const String gameHubImmersionSubtitle = 'Tu noche empieza acá';


  /// Mood cards para la sección hero.
  static const String moodPicante = 'Picante';
  static const String moodDivertido = 'Divertido';

  /// Chips informativos de la card de Sesión.
  static const String gameHubSesionDuracion = '~30 min';
  static const String gameHubSesionTipo = 'Progresivo';

  /// Badge de recomendación para Sesión.
  static const String gameHubRecomendado = 'Recomendado';

  /// Título de la sección de cartas del usuario.
  static const String gameHubTusCartasSection = 'Tus cartas';

  // ─────────────────────────────────────────────────────────────
  // Session Mode
  // ─────────────────────────────────────────────────────────────

  /// Mensaje mostrado mientras se prepara la sesión.
  static const String preparandoSesion = 'Preparando sesión...';

  /// Mensaje cuando la sesión se completa.
  static const String sesionCompletada = '¡Sesión completada!';

  /// Mensaje cuando la sesión está en pausa.
  static const String sesionPausada = 'Sesión pausada';

  /// Botón para continuar después de una pausa.
  static const String continuar = 'Continuar';

  /// Botón para reiniciar la sesión.
  static const String reiniciarSesion = 'Reiniciar sesión';

  /// Botón para volver a la pantalla de inicio.
  static const String volverInicio = 'Volver al inicio';

  /// Mensaje para el comodín (próximamente).
  static const String comodinProximamente = 'Comodín: próximamente';

  /// Etiqueta cuando una carta ya fue guardada.
  static const String guardada = 'Guardada';

  /// Botón para guardar la carta actual.
  static const String guardar = 'Guardar';

  /// Botón para finalizar la sesión en la última carta.
  static const String finalizar = 'Finalizar';

  /// Botón para pausar la sesión.
  static const String pausar = 'Pausar';

  /// Botón para reintentar después de un error.
  static const String reintentar = 'Reintentar';

  /// Mensaje cuando no hay sesión activa.
  static const String noSesionActiva = 'No hay sesión activa';

  /// Botón para iniciar una nueva sesión.
  static const String iniciarSesion = 'Iniciar sesión';

  /// Etiqueta "Modo elegido" sobre el título en confirmación.
  static const String sesionModoElegido = 'Modo elegido';

  /// Badge de duración estimada de la sesión.
  static const String sesionDuracion = '~30 min';

  /// Título del carrusel de niveles en confirmación.
  static const String sesionAsiVaLaSesion = 'Así va la sesión';

  /// Nivel 1 — Suave.
  static const String sesionNivel1 = 'Nivel 1 · Suave';

  /// Descripción del Nivel 1.
  static const String sesionNivel1Desc =
      'Preguntas para romper el hielo y soltar la lengua.';

  /// Nivel 2 — Íntimo.
  static const String sesionNivel2 = 'Nivel 2 · Íntimo';

  /// Descripción del Nivel 2.
  static const String sesionNivel2Desc =
      'Deseos, fantasías y lo que nunca dijiste.';

  /// Nivel 3 — Sin filtro.
  static const String sesionNivel3 = 'Nivel 3 · Sin filtro';

  /// Descripción del Nivel 3.
  static const String sesionNivel3Desc =
      'Solo para cuando ya no hay vuelta atrás.';

  /// Botón primario para empezar la sesión.
  static const String empezarSesion = 'Empezar sesión';

  /// Botón secundario para cambiar de modo.
  static const String cambiarModo = 'Cambiar modo';

  /// Stats de la sesión: cantidad de cartas.
  static const String sesionStatsCartas = '20 cartas';

  /// Stats de la sesión: cantidad de niveles.
  static const String sesionStatsNiveles = '3 niveles';

  /// Stats de la sesión: cantidad de mazos.
  static const String sesionStatsMazos = '2 mazos';

  // ─────────────────────────────────────────────────────────────
  // Phases
  // ─────────────────────────────────────────────────────────────

  /// Nombre de la fase de calentamiento.
  static const String calentamiento = 'Calentamiento';

  /// Nombre de la fase de tensión.
  static const String tension = 'Tensión';

  /// Nombre de la fase de clímax.
  static const String climax = 'Clímax';

  /// Nombre de la fase de cierre.
  static const String cierre = 'Cierre';

  // ─────────────────────────────────────────────────────────────
  // Modo Libre
  // ─────────────────────────────────────────────────────────────

  /// Botón para crear un mazo nuevo en modo libre.
  static const String libreCrearMazo = 'Crear mazo';

  /// Botón para crear carta personalizada en modo libre.
  static const String libreCrearCartaPers = 'Crear carta';

  /// Etiqueta del campo nombre de carta personalizada.
  static const String libreCardNameLabel = 'Nombre de la carta';

  /// Etiqueta del campo instrucción.
  static const String libreInstruccionLabel = 'Instrucción';

  /// Etiqueta del campo categoría.
  static const String libreCategoriaLabel = 'Categoría';

  /// Etiqueta del campo nivel.
  static const String libreNivelLabel = 'Nivel';

  /// Etiqueta del campo tiempo en segundos.
  static const String libreTiempoLabel = 'Tiempo (segundos)';

  /// Etiqueta del campo dirigida a.
  static const String libreDirigidaLabel = 'Dirigida a';

  /// Botón para guardar una carta personalizada.
  static const String libreGuardarCarta = 'Guardar carta';

  /// Snackbar al crear una carta personalizada exitosamente.
  static const String libreCartaCreada = '¡Carta creada!';

  /// Hint del campo nombre del mazo.
  static const String libreDeckNameHint = 'Nombre del mazo';

  /// Mensaje cuando se completa un mazo en modo libre.
  static const String libreMazoCompletado = '¡Mazo completado!';

  /// Botón para ir a la carta anterior.
  static const String anterior = 'Anterior';

  /// Validación: nombre de carta personalizada obligatorio.
  static const String libreNameRequired = 'El nombre es obligatorio';

  /// Validación: instrucción de carta personalizada obligatoria.
  static const String libreInstruccionRequired = 'La instrucción es obligatoria';

  // ─────────────────────────────────────────────────────────────
  // Saved Cards (Guardadas)
  // ─────────────────────────────────────────────────────────────

  /// Título de la pantalla de cartas guardadas.
  static const String savedCardsTitle = 'Guardadas';

  /// Mensaje cuando no hay cartas guardadas.
  static const String savedCardsEmpty = 'Todavía no guardaste ninguna carta';

  /// Etiqueta del filtro "Todas" en la pantalla de guardadas.
  static const String savedCardsFilterAll = 'Todas';

  /// Mensaje cuando ningún filtro tiene coincidencias.
  static const String savedCardsNoMatch = 'No hay cartas que coincidan';

  /// Título del diálogo de confirmación de borrado.
  static const String savedCardsDeleteTitle = 'Eliminar carta';

  /// Texto del botón de confirmación de borrado.
  static const String savedCardsDeleteConfirm = 'Eliminar';

  /// Título del hub para el acceso a cartas guardadas.
  static const String savedCardsHubTitle = 'Cartas guardadas';

  // ─────────────────────────────────────────────────────────────
  // Mis Cartas (Personalizadas)
  // ─────────────────────────────────────────────────────────────

  /// Título de la pantalla de cartas personalizadas.
  static const String misCartasTitle = 'Tus cartas';

  /// Mensaje cuando no hay cartas personalizadas.
  static const String misCartasEmpty =
      'Todavía no creaste ninguna carta personalizada';

  /// Título del diálogo de edición de carta.
  static const String misCartasEditTitle = 'Editar carta';

  /// Título del diálogo de confirmación de borrado.
  static const String misCartasDeleteTitle = 'Eliminar carta';

  /// Texto del botón de confirmación de borrado.
  static const String misCartasDeleteConfirm = 'Eliminar';

  /// Título del hub para el acceso a cartas personalizadas.
  static const String misCartasHubTitle = 'Mis cartas';

  /// Título de la pantalla de creación de carta personalizada.
  static const String misCartasFormCreateTitle = 'Crear carta';

  /// Título de la pantalla de edición de carta personalizada.
  static const String misCartasFormEditTitle = 'Editar carta personalizada';
}
