import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/carta_personalizada_model.dart';
import '../../domain/entities/carta_personalizada.dart';
import '../providers/libre_providers.dart';
import 'card_editor/card_preview_widget.dart';
import 'card_editor/category_selector_widget.dart';
import 'card_editor/cta_button_widget.dart';
import 'card_editor/level_selector_widget.dart';
import 'card_editor/texto_field_widget.dart';
import 'card_editor/time_selector_widget.dart';

// ---------------------------------------------------------------------------
// CardFormWidget
// ---------------------------------------------------------------------------

/// Formulario reutilizable para crear o editar cartas personalizadas, con
/// estilo gaming inmersivo (vista previa en vivo, selectores visuales, glow).
///
/// En create mode (cuando [existingCard] es `null`) genera un nuevo ID.
/// En edit mode pre-popula los campos desde [existingCard].
/// Al guardar persiste a [personalizadasBoxProvider2] y llama a [onSaved].
///
/// Compone 6 sub-widgets bajo `card_editor/`:
/// - CardPreviewWidget, CategorySelector, LevelSelector, TimeSelector,
///   GamingTextField (x2), CtaButtonWidget
class CardFormWidget extends ConsumerStatefulWidget {
  /// Si se provee, el formulario arranca en edit mode con los datos
  /// pre-cargados. Si es `null`, arranca en create mode vacío.
  final CartaPersonalizada? existingCard;

  /// Callback invocado después de persistir exitosamente la carta.
  final VoidCallback? onSaved;

  const CardFormWidget({super.key, this.existingCard, this.onSaved});

  @override
  ConsumerState<CardFormWidget> createState() => _CardFormWidgetState();
}

class _CardFormWidgetState extends ConsumerState<CardFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _textoController = TextEditingController();
  final _dirigidaController = TextEditingController();
  String? _categoria;
  String _nivel = 'suave';
  int? _tiempoSegundos;
  bool _isSaving = false;

  // ── Lifecycle ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _textoController.addListener(_onFieldChanged);
    _dirigidaController.addListener(_onFieldChanged);
    if (widget.existingCard != null) {
      _populateFromExisting(widget.existingCard!);
    }
  }

  @override
  void dispose() {
    _textoController.removeListener(_onFieldChanged);
    _dirigidaController.removeListener(_onFieldChanged);
    _textoController.dispose();
    _dirigidaController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {});
  }

  void _populateFromExisting(CartaPersonalizada c) {
    _textoController.text = c.texto;
    _categoria = c.categoria;
    _nivel = c.nivel;
    _tiempoSegundos = c.tiempoSegundos?.inSeconds;
    _dirigidaController.text = c.dirigida ?? '';
  }

  // ── Save action ────────────────────────────────────────────────

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final existing = widget.existingCard;

      final carta = CartaPersonalizada(
        id: existing?.id ?? 'pers_${now.millisecondsSinceEpoch}',
        texto: _textoController.text.trim(),
        categoria: _categoria,
        nivel: _nivel,
        tiempoSegundos: _tiempoSegundos != null && _tiempoSegundos! > 5
            ? Duration(seconds: _tiempoSegundos!)
            : null,
        dirigida: _dirigidaController.text.trim().isEmpty
            ? null
            : _dirigidaController.text.trim(),
        creadaEn: existing?.creadaEn ?? now,
      );

      final box = ref.read(personalizadasBoxProvider2);
      final model = CartaPersonalizadaModel.fromEntity(carta);
      await box.put(carta.id, model);

      if (mounted) {
        setState(() => _isSaving = false);
        widget.onSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingCard != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Preview ──────────────────────────────────────────
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CardPreviewWidget(
                texto: _textoController.text,
                categoria: _categoria,
                nivel: _nivel,
                tiempoSegundos: _tiempoSegundos,
                dirigida: _dirigidaController.text,
              ),
            ),
            const SizedBox(height: 16),

            // ── Instrucción ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GamingTextField(
                controller: _textoController,
                label: AppStrings.libreInstruccionLabel,
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? AppStrings.libreInstruccionRequired
                    : null,
              ),
            ),
            const SizedBox(height: 16),

            // ── Categoría ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CategorySelector(
                selected: _categoria,
                onChanged: (v) => setState(() => _categoria = v),
              ),
            ),
            const SizedBox(height: 16),

            // ── Nivel ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LevelSelector(
                selected: _nivel,
                onChanged: (v) => setState(() => _nivel = v),
              ),
            ),
            const SizedBox(height: 16),

            // ── Tiempo ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TimeSelector(
                seconds: _tiempoSegundos,
                onChanged: (v) => setState(() => _tiempoSegundos = v),
              ),
            ),
            const SizedBox(height: 16),

            // ── Dirigida a ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GamingTextField(
                controller: _dirigidaController,
                label: AppStrings.libreDirigidaLabel,
              ),
            ),
            const SizedBox(height: 24),

            // ── CTA ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CtaButtonWidget(
                label: isEdit
                    ? AppStrings.libreGuardarCarta
                    : AppStrings.libreGuardarCarta,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _save,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
