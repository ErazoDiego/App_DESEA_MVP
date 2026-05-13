import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/datasources/hive_datasource.dart';
import '../../../domain/entities/mazo.dart';
import '../../../domain/repositories/mazo_repository.dart';
import '../../providers/mazo_providers.dart';
import '../../providers/sesion_providers.dart';
import '../../providers/libre_providers.dart';
import '../../widgets/card_form_widget.dart';
import '../../widgets/deck_card_grid.dart';

// ---------------------------------------------------------------------------
// View enum
// ---------------------------------------------------------------------------

/// Enum que controla qué sub-vista se muestra en el [IndexedStack].
enum LibreView { deckList, cardBuilder, createCard }

// ---------------------------------------------------------------------------
// Lightweight item model for card builder list
// ---------------------------------------------------------------------------

class _CardSourceItem {
  final String id;
  final String texto;
  final String tipoLabel;
  final String source; // 'original' | 'guardada' | 'creada'
  bool isSelected;

  _CardSourceItem({
    required this.id,
    required this.texto,
    required this.tipoLabel,
    required this.source,
    this.isSelected = false,
  });
}

// ---------------------------------------------------------------------------
// LibreScreen
// ---------------------------------------------------------------------------

/// Pantalla principal del modo libre con tres sub-vistas manejadas por
/// [LibreView] e [IndexedStack]:
///   1. Lista de mazos guardados (deck list)
///   2. Constructor de mazo con selección de cartas (card builder)
///   3. Formulario para crear carta personalizada (create card form via
///      [CardFormWidget])
class LibreScreen extends ConsumerStatefulWidget {
  const LibreScreen({super.key});

  @override
  ConsumerState<LibreScreen> createState() => _LibreScreenState();
}

class _LibreScreenState extends ConsumerState<LibreScreen> {
  LibreView _currentView = LibreView.deckList;

  // ── Deck list state ────────────────────────────────────────────
  List<Mazo>? _mazos;
  bool _isLoadingMazos = true;
  String? _mazosError;

  // ── Card builder state ─────────────────────────────────────────
  final _deckNameController = TextEditingController();
  String _cardFilter = 'Todas';
  final Set<String> _selectedCardIds = {};
  List<_CardSourceItem> _allCardItems = [];
  bool _isLoadingCards = false;

  // ── Lifecycle ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadMazos();
  }

  @override
  void dispose() {
    _deckNameController.dispose();
    super.dispose();
  }

  // ── Data loading ───────────────────────────────────────────────

  Future<void> _loadMazos() async {
    setState(() {
      _isLoadingMazos = true;
      _mazosError = null;
    });
    try {
      MazoRepository repo;
      try {
        repo = ref.read(mazoRepositoryProvider);
      } catch (_) {
        // Box not yet initialized — wait and retry
        await ref.read(mazoBoxProvider.future);
        repo = ref.read(mazoRepositoryProvider);
      }
      final mazos = await repo.getMazos();
      if (mounted) {
        setState(() {
          _mazos = mazos;
          _isLoadingMazos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMazos = false;
          _mazosError = e.toString();
        });
      }
    }
  }

  Future<void> _loadCardItems() async {
    setState(() => _isLoadingCards = true);

    final items = <_CardSourceItem>[];

    // 1) Originales (seed cartas)
    try {
      final cartaBox = ref.read(cartaBoxProvider2);
      for (final model in cartaBox.values) {
        final carta = model.toEntity();
        items.add(_CardSourceItem(
          id: carta.id,
          texto: carta.texto,
          tipoLabel: carta.tipo.name,
          source: 'original',
          isSelected: _selectedCardIds.contains(carta.id),
        ));
      }
    } catch (_) {}

    // 2) Guardadas
    try {
      final guardadasBox = ref.read(guardadasBoxProvider2);
      for (final model in guardadasBox.values) {
        final carta = model.toCarta();
        items.add(_CardSourceItem(
          id: model.cartaId,
          texto: carta.texto,
          tipoLabel: carta.tipo.name,
          source: 'guardada',
          isSelected: _selectedCardIds.contains(model.cartaId),
        ));
      }
    } catch (_) {}

    // 3) Creadas (personalizadas)
    try {
      final persBox = ref.read(personalizadasBoxProvider2);
      for (final model in persBox.values) {
        final entity = model.toEntity();
        items.add(_CardSourceItem(
          id: entity.id,
          texto: entity.texto,
          tipoLabel: entity.categoria ?? 'personalizada',
          source: 'creada',
          isSelected: _selectedCardIds.contains(entity.id),
        ));
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _allCardItems = items;
        _isLoadingCards = false;
      });
    }
  }

  Future<void> _deleteMazo(Mazo mazo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar mazo'),
        content: Text('¿Eliminar "${mazo.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final repo = ref.read(mazoRepositoryProvider);
      await repo.eliminarMazo(mazo.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${mazo.nombre}" eliminado')),
        );
        await _loadMazos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  // ── Actions ────────────────────────────────────────────────────

  Future<void> _saveDeck() async {
    final name = _deckNameController.text.trim();
    if (name.isEmpty) return;
    if (_selectedCardIds.isEmpty) return;

    final repo = ref.read(mazoRepositoryProvider);

    // Prevent duplicate names (case-insensitive).
    final existing = await repo.getMazos();
    final duplicate = existing.any(
      (m) => m.nombre.toLowerCase() == name.toLowerCase(),
    );
    if (duplicate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya existe un mazo con ese nombre')),
        );
      }
      return;
    }

    final mazo = Mazo(
      id: 'mazo_${DateTime.now().millisecondsSinceEpoch}',
      nombre: name,
      nivel: Nivel.suave,
      cartaIds: _selectedCardIds.toList(),
    );

    await repo.crearMazo(mazo);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Mazo guardado!')),
      );
      // Reset builder state and go back to deck list
      _deckNameController.clear();
      _selectedCardIds.clear();
      _cardFilter = 'Todas';
      setState(() => _currentView = LibreView.deckList);
      await _loadMazos();
    }
  }

  // ── Filtered items ─────────────────────────────────────────────

  static const _filterSourceMap = <String, String>{
    'Originales': 'original',
    'Guardadas': 'guardada',
    'Creadas': 'creada',
  };

  List<_CardSourceItem> get _filteredItems {
    if (_cardFilter == 'Todas') return _allCardItems;
    final targetSource = _filterSourceMap[_cardFilter];
    if (targetSource == null) return _allCardItems;
    return _allCardItems.where((i) => i.source == targetSource).toList();
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentView != LibreView.deckList) {
              setState(() => _currentView = LibreView.deckList);
            } else {
              context.go('/game-hub');
            }
          },
        ),
      ),
      body: IndexedStack(
        index: _currentView.index,
        children: [
          _buildDeckListView(),
          _buildCardBuilderView(),
          CardFormWidget(
            onSaved: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.libreCartaCreada)),
              );
              setState(() => _currentView = LibreView.deckList);
              _loadMazos();
            },
          ),
        ],
      ),
      floatingActionButton: _currentView == LibreView.deckList
          ? ExpandableDeckFab(
              onCrearMazo: () {
                setState(() => _currentView = LibreView.cardBuilder);
                _loadCardItems();
              },
              onCrearCarta: () {
                setState(() => _currentView = LibreView.createCard);
              },
            )
          : null,
    );
  }

  String get _appBarTitle {
    switch (_currentView) {
      case LibreView.deckList:
        return AppStrings.libre;
      case LibreView.cardBuilder:
        return 'Crear Mazo';
      case LibreView.createCard:
        return AppStrings.misCartasFormCreateTitle;
    }
  }

  // ── View 1: Deck List ──────────────────────────────────────────

  Widget _buildDeckListView() {
    if (_isLoadingMazos) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mazosError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_mazosError'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMazos,
              child: const Text(AppStrings.reintentar),
            ),
          ],
        ),
      );
    }

    final mazos = _mazos ?? [];

    if (mazos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_mosaic,
              size: 64,
              color: AppColors.onSurfaceSecondary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Todavía no tenés mazos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.onSurfaceSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tocá + para crear tu primer mazo',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onSurfaceSecondary.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return DeckCardGrid(
      mazos: mazos,
      onTap: (mazo) => context.go(
        '/game/libre/play',
        extra: mazo,
      ),
      onDelete: _deleteMazo,
    );
  }

  // ── View 2: Card Builder ───────────────────────────────────────

  Widget _buildCardBuilderView() {
    return Column(
      children: [
        // Deck name field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _deckNameController,
            decoration: InputDecoration(
              hintText: AppStrings.libreDeckNameHint,
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: AppColors.surface,
            ),
          ),
        ),

        // Filter chips (replaces TabBar to avoid Column overflow in
        // IndexedStack)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Todas', 'Originales', 'Guardadas', 'Creadas']
                  .map((label) {
                final isSelected = _cardFilter == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _cardFilter = label);
                    },
                    selectedColor:
                        AppColors.fuchsiaAccent.withValues(alpha: 0.2),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Card list
        Expanded(
          child: _isLoadingCards
              ? const Center(child: CircularProgressIndicator())
              : _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        'No hay cartas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceSecondary,
                            ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return CheckboxListTile(
                          value: item.isSelected,
                          title: Text(item.texto, maxLines: 2),
                          subtitle: Text(item.tipoLabel.toUpperCase()),
                          onChanged: (value) {
                            setState(() {
                              item.isSelected = value ?? false;
                              if (value == true) {
                                _selectedCardIds.add(item.id);
                              } else {
                                _selectedCardIds.remove(item.id);
                              }
                            });
                          },
                        );
                      },
                    ),
        ),

        // Añadir button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedCardIds.isEmpty ? null : _saveDeck,
              child: Text('Añadir ${_selectedCardIds.length} cartas al mazo'),
            ),
          ),
        ),
      ],
    );
  }
}

