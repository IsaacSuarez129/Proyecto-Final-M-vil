import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pvm/core/errors/app_exception.dart';
import 'package:pvm/features/catalog/data/repositories/product_repository.dart';
import 'package:pvm/features/catalog/domain/entities/product.dart';

class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, required this.products, this.product});

  // Productos existentes: sirven para sugerir categorías y subcategorías.
  final List<Product> products;

  // Si viene, el formulario edita ese producto; si no, crea uno nuevo.
  final Product? product;

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _repository = const ProductRepository();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _codeController;
  late final TextEditingController _categoryController;
  late final TextEditingController _subcategoryController;
  late CodeType _codeType;

  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;

    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(
      text: product == null ? '' : product.price.toStringAsFixed(2),
    );
    _codeController = TextEditingController(text: product?.code ?? '');
    _categoryController = TextEditingController(text: product?.category ?? '')
      ..addListener(_refresh);
    _subcategoryController = TextEditingController(text: product?.subcategory ?? '');
    _codeType = product?.codeType ?? CodeType.barcode;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _codeController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<String> get _categorySuggestions {
    return widget.products.map((p) => p.category).toSet().toList()..sort();
  }

  // Subcategorías que ya existen dentro de la categoría escrita.
  List<String> get _subcategorySuggestions {
    final category = _categoryController.text.trim().toLowerCase();
    return widget.products
        .where((p) => p.subcategory != null && p.category.toLowerCase() == category)
        .map((p) => p.subcategory!)
        .toSet()
        .toList()
      ..sort();
  }

  Future<void> _submit() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final subcategory = _subcategoryController.text.trim();
    final data = (
      name: _nameController.text.trim(),
      price: double.parse(_priceController.text),
      code: _codeController.text.trim(),
      codeType: _codeType,
      category: _categoryController.text.trim(),
      subcategory: subcategory.isEmpty ? null : subcategory,
    );

    try {
      final product = widget.product;
      if (product == null) {
        await _repository.createProduct(data);
      } else {
        await _repository.updateProduct(product.id, data);
      }
      if (mounted) Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isSaving = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'No se pudo guardar. Intenta de nuevo.';
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isBarcode = _codeType == CodeType.barcode;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isEditing ? 'Actualizar producto' : 'Agregar producto',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Escribe un nombre'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final price = double.tryParse(value ?? '');
                    return (price == null || price <= 0)
                        ? 'Escribe un precio válido'
                        : null;
                  },
                ),
                const SizedBox(height: 12),
                SegmentedButton<CodeType>(
                  segments: const [
                    ButtonSegment(
                      value: CodeType.barcode,
                      label: Text('Código de barras'),
                    ),
                    ButtonSegment(value: CodeType.pos, label: Text('Código')),
                  ],
                  selected: {_codeType},
                  onSelectionChanged: (selection) =>
                      setState(() => _codeType = selection.first),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: isBarcode
                        ? 'Código de barras (escanéalo o escríbelo)'
                        : 'Código (ej. TS1)',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Escribe un código'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _categoryController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Categoría (ej. Refrescos)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Escribe una categoría'
                      : null,
                ),
                _SuggestionChips(
                  options: _categorySuggestions,
                  onSelected: (value) => _categoryController.text = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _subcategoryController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Subcategoría (opcional, ej. Pepsi)',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _submit(),
                ),
                _SuggestionChips(
                  options: _subcategorySuggestions,
                  onSelected: (value) => _subcategoryController.text = value,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: TextStyle(color: scheme.error)),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: TextButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _isSaving ? null : _submit,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Guardar'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Botones con los valores que ya existen; al tocar uno se llena el campo.
class _SuggestionChips extends StatelessWidget {
  const _SuggestionChips({required this.options, required this.onSelected});

  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final option in options)
            ActionChip(label: Text(option), onPressed: () => onSelected(option)),
        ],
      ),
    );
  }
}