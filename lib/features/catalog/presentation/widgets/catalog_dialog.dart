import 'package:flutter/material.dart';
import 'package:pvm/core/constants/app_constants.dart';
import 'package:pvm/core/theme/app_theme.dart';
import 'package:pvm/core/utils/formatters.dart';
import 'package:pvm/features/catalog/data/repositories/product_repository.dart';
import 'package:pvm/features/catalog/domain/entities/product.dart';
import 'package:pvm/features/catalog/presentation/widgets/product_form_dialog.dart';
import 'package:pvm/features/checkout/presentation/widgets/action_buttons_panel.dart';
import 'package:pvm/features/checkout/presentation/widgets/barcode_label.dart';

typedef _Filter = ({String? category, String? subcategory, bool posOnly});

class CatalogDialog extends StatefulWidget {
  const CatalogDialog({
    super.key,
    required this.canManage,
    required this.onAddProduct,
  });

  // Solo quien puede administrar ve los botones de agregar, eliminar y actualizar.
  final bool canManage;
  final ValueChanged<Product> onAddProduct;

  @override
  State<CatalogDialog> createState() => _CatalogDialogState();
}

class _CatalogDialogState extends State<CatalogDialog> {
  final _repository = const ProductRepository();
  final _searchController = TextEditingController();

  List<Product> _products = [];
  bool _isLoading = true;
  bool _loadFailed = false;
  String? _errorMessage;

  String? _selectedId;
  String? _category;
  String? _subcategory;
  bool _posOnly = false;
  final Set<String> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
      _errorMessage = null;
    });

    try {
      final products = await _repository.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        if (!products.any((p) => p.id == _selectedId)) _selectedId = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  Product? get _selected {
    return _products.where((p) => p.id == _selectedId).firstOrNull;
  }

  bool get _isWideSearch {
    return _searchController.text.trim().startsWith(AppConstants.catalogSearchSymbol);
  }

  // Búsqueda normal: respeta el filtro elegido.
  // Búsqueda con el símbolo (#): ignora el filtro y busca en todo el catálogo,
  // solo por nombre y código del producto.
  List<Product> get _visibleProducts {
    final raw = _searchController.text.trim();
    final wide = _isWideSearch;
    final query = wide
        ? raw.substring(AppConstants.catalogSearchSymbol.length)
        : raw;

    return _products.where((p) {
      if (!wide) {
        if (_posOnly && p.codeType != CodeType.pos) return false;
        if (_category != null && p.category != _category) return false;
        if (_subcategory != null && p.subcategory != _subcategory) return false;
      }
      return p.matchesSearch(query);
    }).toList();
  }

  // Categorías con sus subcategorías, tomadas de los productos existentes.
  Map<String, Set<String>> get _categoryTree {
    final tree = <String, Set<String>>{};
    for (final product in _products) {
      final subs = tree.putIfAbsent(product.category, () => <String>{});
      final sub = product.subcategory;
      if (sub != null) subs.add(sub);
    }
    return tree;
  }

  String? get _filterLabel {
    if (_posOnly) return 'Productos con código';
    final category = _category;
    if (category == null) return null;
    final sub = _subcategory;
    return sub == null ? category : '$category › $sub';
  }

  void _applyFilter(_Filter filter) {
    setState(() {
      _category = filter.category;
      _subcategory = filter.subcategory;
      _posOnly = filter.posOnly;
    });
  }

  Future<void> _addProduct() async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => ProductFormDialog(products: _products),
    );
    if (saved == true) await _load();
  }

  Future<void> _editSelected() async {
    final product = _selected;
    if (product == null) return;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => ProductFormDialog(products: _products, product: product),
    );
    if (saved == true) await _load();
  }

  Future<void> _deleteSelected() async {
    final product = _selected;
    if (product == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${product.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _repository.deleteProduct(product.id);
      await _load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'No se pudo eliminar el producto.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = _visibleProducts;
    final selected = _selected;
    final filterLabel = _filterLabel;
    // Con el teclado abierto se ocultan los botones para que todo quepa.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Dialog(
      backgroundColor: PosColors.background,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'Productos',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildSearchField()),
                  const SizedBox(width: 12),
                  _buildFilterButton(),
                ],
              ),
              if (filterLabel != null && !_isWideSearch)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(filterLabel),
                      onDeleted: () => _applyFilter(
                        (category: null, subcategory: null, posOnly: false),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildList(visible, selected),
                  ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_errorMessage!, style: TextStyle(color: scheme.error)),
                ),
              if (widget.canManage && !keyboardOpen) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  child: ActionButtonsPanel(
                    actions: [
                      PosAction(label: 'Agregar Producto', onPressed: _addProduct),
                      PosAction(
                        label: 'Eliminar Producto',
                        onPressed: selected == null ? null : _deleteSelected,
                      ),
                      PosAction(
                        label: 'Actualizar Producto',
                        onPressed: selected == null ? null : _editSelected,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    final symbol = AppConstants.catalogSearchSymbol;

    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Buscar por nombre o código',
        helperText: _isWideSearch
            ? 'Búsqueda en todo el catálogo'
            : 'Escribe $symbol antes para buscar en todo el catálogo (ej. ${symbol}pepsi)',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
              ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildFilterButton() {
    final scheme = Theme.of(context).colorScheme;
    final isActive = _filterLabel != null;

    return PopupMenuButton<_Filter>(
      tooltip: 'Filtros',
      onSelected: _applyFilter,
      itemBuilder: (context) {
        final tree = _categoryTree;
        final categories = tree.keys.toList()..sort();

        return [
          const PopupMenuItem<_Filter>(
            value: (category: null, subcategory: null, posOnly: false),
            child: Text('Todos los productos'),
          ),
          for (final category in categories) ...[
            if (tree[category]!.isEmpty)
              PopupMenuItem<_Filter>(
                value: (category: category, subcategory: null, posOnly: false),
                child: Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              )
            else
              _CategoryMenuEntry(
                category: category,
                subcategories: tree[category]!.toList()..sort(),
                initiallyExpanded:
                    _expandedCategories.contains(category) || _category == category,
                onToggleExpanded: (expanded) {
                  if (expanded) {
                    _expandedCategories.add(category);
                  } else {
                    _expandedCategories.remove(category);
                  }
                },
              ),
          ],
          const PopupMenuDivider(),
          const PopupMenuItem<_Filter>(
            value: (category: null, subcategory: null, posOnly: true),
            child: Text('Productos con código'),
          ),
        ];
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? scheme.primaryContainer : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outline),
        ),
        child: const Icon(Icons.filter_list),
      ),
    );
  }

  Widget _buildList(List<Product> visible, Product? selected) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadFailed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se pudo cargar el catálogo.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Reintentar')),
          ],
        ),
      );
    }

    if (visible.isEmpty) {
      final message = _products.isEmpty
          ? (widget.canManage
              ? 'Aún no hay productos.\nUsa "Agregar Producto" para crear el primero.'
              : 'Aún no hay productos.')
          : 'No hay productos que coincidan.';

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: visible.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final product = visible[index];
        final isSelected = product.id == selected?.id;

        return _ProductRow(
          product: product,
          selected: isSelected,
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() => _selectedId = isSelected ? null : product.id);
          },
          onAdd: () {
            widget.onAddProduct(product);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.selected,
    required this.onTap,
    required this.onAdd,
  });

  final Product product;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final path = [
      product.category,
      if (product.subcategory != null) product.subcategory!,
    ].join(' › ');
    final detail = product.codeType == CodeType.pos ? '$path · Código POS' : path;

    return Material(
      color: selected ? scheme.primaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              BarcodeLabel(barcode: product.code),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: PosColors.fieldLabel,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 96,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    Formatters.currency(product.price),
                    style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: onAdd,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Agregar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryMenuEntry extends PopupMenuEntry<_Filter> {
  const _CategoryMenuEntry({
    required this.category,
    required this.subcategories,
    required this.initiallyExpanded,
    required this.onToggleExpanded,
  });

  final String category;
  final List<String> subcategories;
  final bool initiallyExpanded;
  final ValueChanged<bool> onToggleExpanded;

  @override
  double get height => kMinInteractiveDimension;

  @override
  bool represents(_Filter? value) => value?.category == category;

  @override
  State<_CategoryMenuEntry> createState() => _CategoryMenuEntryState();
}

class _CategoryMenuEntryState extends State<_CategoryMenuEntry> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => Navigator.of(context).pop(
                  (category: widget.category, subcategory: null, posOnly: false),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                  child: Text(
                    widget.category,
                    style: textStyle?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() => _expanded = !_expanded);
                widget.onToggleExpanded(_expanded);
              },
              icon: Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
              ),
              visualDensity: VisualDensity.compact,
              tooltip: _expanded ? 'Ocultar subcategorías' : 'Ver subcategorías',
            ),
          ],
        ),
        if (_expanded)
          for (final sub in widget.subcategories)
            InkWell(
              onTap: () => Navigator.of(context).pop(
                (category: widget.category, subcategory: sub, posOnly: false),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 12, 12, 12),
                child: Text(sub, style: textStyle),
              ),
            ),
      ],
    );
  }
}