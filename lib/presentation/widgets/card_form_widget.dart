import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/carta_personalizada_model.dart';
import '../../domain/entities/carta_personalizada.dart';
import '../providers/libre_providers.dart';

// ---------------------------------------------------------------------------
// CardFormWidget
// ---------------------------------------------------------------------------

/// Formulario reutilizable para crear o editar cartas personalizadas.
///
/// En create mode (cuando [existingCard] es `null`) genera un nuevo ID.
/// En edit mode pre-popula los campos desde [existingCard].
/// Al guardar persiste a [personalizadasBoxProvider2] y llama a [onSaved].
///
/// Campos:
/// - **texto** (instrucción) — TextFormField obligatorio
/// - **categoria** — DropdownButtonFormField (Verdad/Reto/Deseo/Sin Límites)
/// - **nivel** — DropdownButtonFormField (Suave/Picante/Intenso)
/// - **tiempoSegundos** — TextFormField numérico opcional
/// - **dirigida** — TextFormField opcional
class CardFormWidget extends ConsumerStatefulWidget {
  /// Si se provee, el formulario arranca en edit mode con los datos
  /// pre-cargados. Si es `null`, arranca en create mode vacío.
  final CartaPersonalizada? existingCard;

  /// Callback invocado después de persistir exitosamente la carta.
  /// En create mode el padre podría cerrar la pantalla, en edit mode
  /// podría hacer pop de la ruta.
  final VoidCallback? onSaved;

  const CardFormWidget({super.key, this.existingCard, this.onSaved});

  @override
  ConsumerState<CardFormWidget> createState() => _CardFormWidgetState();
}

class _CardFormWidgetState extends ConsumerState<CardFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _textoController = TextEditingController();
  String? _categoria;
  String _nivel = 'suave';
  final _tiempoController = TextEditingController();
  final _dirigidaController = TextEditingController();
  bool _isSaving = false;

  // ── Lifecycle ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (widget.existingCard != null) {
      final c = widget.existingCard!;
      _textoController.text = c.texto;
      _categoria = c.categoria;
      _nivel = c.nivel;
      _tiempoController.text = c.tiempoSegundos?.inSeconds.toString() ?? '';
      _dirigidaController.text = c.dirigida ?? '';
    }
  }

  @override
  void dispose() {
    _textoController.dispose();
    _tiempoController.dispose();
    _dirigidaController.dispose();
    super.dispose();
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
        tiempoSegundos: int.tryParse(_tiempoController.text.trim()) != null
            ? Duration(seconds: int.parse(_tiempoController.text.trim()))
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
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Texto / Instrucción ──────────────────────────
            TextFormField(
              controller: _textoController,
              decoration: InputDecoration(
                labelText: AppStrings.libreInstruccionLabel,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.surface,
              ),
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.libreInstruccionRequired
                  : null,
            ),
            const SizedBox(height: 16),

            // ── Categoría ────────────────────────────────────
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: InputDecoration(
                labelText: AppStrings.libreCategoriaLabel,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: const [
                DropdownMenuItem(value: 'verdad', child: Text('Verdad')),
                DropdownMenuItem(value: 'reto', child: Text('Reto')),
                DropdownMenuItem(value: 'deseo', child: Text('Deseo')),
                DropdownMenuItem(
                    value: 'sinLimites', child: Text('Sin Límites')),
              ],
              onChanged: (v) => setState(() => _categoria = v),
            ),
            const SizedBox(height: 16),

            // ── Nivel ────────────────────────────────────────
            DropdownButtonFormField<String>(
              initialValue: _nivel,
              decoration: InputDecoration(
                labelText: AppStrings.libreNivelLabel,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items: const [
                DropdownMenuItem(value: 'suave', child: Text('Suave')),
                DropdownMenuItem(value: 'picante', child: Text('Picante')),
                DropdownMenuItem(value: 'intenso', child: Text('Intenso')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _nivel = v);
              },
            ),
            const SizedBox(height: 16),

            // ── Tiempo (segundos) ────────────────────────────
            TextFormField(
              controller: _tiempoController,
              decoration: InputDecoration(
                labelText: AppStrings.libreTiempoLabel,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.surface,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // ── Dirigida a ───────────────────────────────────
            TextFormField(
              controller: _dirigidaController,
              decoration: InputDecoration(
                labelText: AppStrings.libreDirigidaLabel,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.surface,
              ),
            ),
            const SizedBox(height: 24),

            // ── Save button ──────────────────────────────────
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isEdit
                          ? AppStrings.libreGuardarCarta
                          : AppStrings.libreGuardarCarta,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
