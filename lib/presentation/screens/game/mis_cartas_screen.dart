import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/datasources/hive_datasource.dart';
import '../../../data/models/carta_personalizada_model.dart';
import '../../providers/libre_providers.dart';
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
// MisCartasScreen
// ---------------------------------------------------------------------------

/// Pantalla que lista todas las cartas personalizadas creadas por el usuario
/// en el modo libre. Permite filtrar por categoría, editar (navegando a un
/// formulario con los datos pre-cargados) y eliminar con confirmación.
class MisCartasScreen extends ConsumerStatefulWidget {
  const MisCartasScreen({super.key});

  @override
  ConsumerState<MisCartasScreen> createState() => _MisCartasScreenState();
}

class _MisCartasScreenState extends ConsumerState<MisCartasScreen> {
  List<CartaPersonalizadaModel>? _cards;
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
      await ref.read(personalizadasBoxProvider.future);
      final box = ref.read(personalizadasBoxProvider2);
      final cards = box.values.toList()
        ..sort((a, b) => b.creadaEn.compareTo(a.creadaEn));
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

  List<CartaPersonalizadaModel> get _filteredCards {
    if (_activeFilterValue.isEmpty) return _cards ?? [];
    return (_cards ?? [])
        .where((c) => c.categoria == _activeFilterValue)
        .toList();
  }

  // ── Delete action ──────────────────────────────────────────────

  Future<void> _deleteCard(CartaPersonalizadaModel card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.misCartasDeleteTitle),
        content: Text('¿Eliminar "${card.texto}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppStrings.misCartasDeleteConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(personalizadasBoxProvider.future);
      final box = ref.read(personalizadasBoxProvider2);
      await box.delete(card.id);
      await _loadCards();
    }
  }

  // ── Label helpers ──────────────────────────────────────────────

  String _categoriaLabel(String? categoria) {
    switch (categoria) {
      case 'verdad':
        return 'Verdad';
      case 'reto':
        return 'Reto';
      case 'deseo':
        return 'Deseo';
      case 'sinLimites':
        return 'Sin Límites';
      default:
        return categoria ?? 'Personalizada';
    }
  }

  // ── Edit navigation ────────────────────────────────────────────

  Future<void> _editCard(CartaPersonalizadaModel card) async {
    final entity = card.toEntity();
    await context.push('/game/mis-cartas/edit', extra: entity);
    if (mounted) _loadCards();
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.misCartasTitle),
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
            AppStrings.misCartasEmpty,
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
                    return _PersonalCardTile(
                      card: card,
                      categoriaLabel: _categoriaLabel(card.categoria),
                      onTap: () => _editCard(card),
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
// Personal card tile widget
// ---------------------------------------------------------------------------

class _PersonalCardTile extends StatelessWidget {
  final CartaPersonalizadaModel card;
  final String categoriaLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PersonalCardTile({
    required this.card,
    required this.categoriaLabel,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final d = card.creadaEn;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                    tooltip: AppStrings.misCartasDeleteTitle,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Bottom row: categoria label + nivel badge + date
              Row(
                children: [
                  Text(
                    categoriaLabel.toUpperCase(),
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
      ),
    );
  }
}
