import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/datasources/hive_datasource.dart';
import '../../../data/models/carta_guardada_model.dart';
import '../../providers/sesion_providers.dart';
import '../../widgets/session/level_badge.dart';

// ---------------------------------------------------------------------------
// Filter option descriptor
// ---------------------------------------------------------------------------

class _FilterOption {
  final String label;
  final String value; // empty string means "show all" (Todas)

  const _FilterOption(this.label, this.value);
}

const _filterOptions = [
  _FilterOption('Todas', ''),
  _FilterOption('Verdad', 'verdad'),
  _FilterOption('Reto', 'reto'),
  _FilterOption('Deseo', 'deseo'),
  _FilterOption('Sin Límites', 'sinLimites'),
];

// ---------------------------------------------------------------------------
// SavedCardsScreen
// ---------------------------------------------------------------------------

/// Pantalla que lista todas las cartas guardadas por el usuario durante las
/// sesiones de juego. Permite filtrar por tipo (Verdad/Reto/Deseo/Sin Límites)
/// y eliminar cartas individuales con confirmación.
class SavedCardsScreen extends ConsumerStatefulWidget {
  const SavedCardsScreen({super.key});

  @override
  ConsumerState<SavedCardsScreen> createState() => _SavedCardsScreenState();
}

class _SavedCardsScreenState extends ConsumerState<SavedCardsScreen> {
  List<CartaGuardadaModel>? _cards;
  bool _isLoading = true;
  String? _error;
  String _activeFilterValue = '';

  // ── Lifecycle ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  // ── Data loading ───────────────────────────────────────────────

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(guardadasBoxProvider.future);
      final box = ref.read(guardadasBoxProvider2);
      final cards = box.values.toList()
        ..sort((a, b) => b.guardadaEn.compareTo(a.guardadaEn));
      if (mounted) {
        setState(() {
          _cards = cards;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  // ── Filtered cards ─────────────────────────────────────────────

  List<CartaGuardadaModel> get _filteredCards {
    if (_activeFilterValue.isEmpty) return _cards ?? [];
    return (_cards ?? [])
        .where((c) => c.tipo == _activeFilterValue)
        .toList();
  }

  // ── Delete action ──────────────────────────────────────────────

  Future<void> _deleteCard(CartaGuardadaModel card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.savedCardsDeleteTitle),
        content: Text('¿Eliminar "${card.texto}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppStrings.savedCardsDeleteConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(guardadasBoxProvider.future);
      final box = ref.read(guardadasBoxProvider2);
      await box.delete(card.id);
      await _loadCards();
    }
  }

  // ── Label helpers ──────────────────────────────────────────────

  String _tipoLabel(String tipo) {
    switch (tipo) {
      case 'verdad':
        return 'Verdad';
      case 'reto':
        return 'Reto';
      case 'deseo':
        return 'Deseo';
      case 'sinLimites':
        return 'Sin Límites';
      default:
        return tipo;
    }
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.savedCardsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/game-hub'),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCards,
              child: const Text(AppStrings.reintentar),
            ),
          ],
        ),
      );
    }

    final cards = _cards ?? [];

    if (cards.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            AppStrings.savedCardsEmpty,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      children: [
        // ── Filter chips ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((option) {
                // Use AppStrings for "Todas", otherwise use the label directly
                final displayLabel = option.value.isEmpty
                    ? AppStrings.savedCardsFilterAll
                    : option.label;
                final isSelected = _activeFilterValue == option.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(displayLabel),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _activeFilterValue = option.value);
                    },
                    selectedColor:
                        AppColors.fuchsiaAccent.withValues(alpha: 0.2),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // ── Card list ────────────────────────────────────
        Expanded(
          child: _filteredCards.isEmpty
              ? Center(
                  child: Text(
                    AppStrings.savedCardsNoMatch,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceSecondary,
                        ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredCards.length,
                  itemBuilder: (context, index) {
                    final card = _filteredCards[index];
                    return _SavedCardTile(
                      card: card,
                      tipoLabel: _tipoLabel(card.tipo),
                      onDelete: () => _deleteCard(card),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Saved card tile widget
// ---------------------------------------------------------------------------

class _SavedCardTile extends StatelessWidget {
  final CartaGuardadaModel card;
  final String tipoLabel;
  final VoidCallback onDelete;

  const _SavedCardTile({
    required this.card,
    required this.tipoLabel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final d = card.guardadaEn;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: texto + delete button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    card.texto,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: AppColors.onSurfaceSecondary,
                  onPressed: onDelete,
                  visualDensity: VisualDensity.compact,
                  tooltip: AppStrings.savedCardsDeleteTitle,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Bottom row: tipo label + nivel badge + date
            Row(
              children: [
                Text(
                  tipoLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.fuchsiaAccent,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(width: 12),
                LevelBadge(nivel: card.nivel),
                const Spacer(),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceSecondary,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
