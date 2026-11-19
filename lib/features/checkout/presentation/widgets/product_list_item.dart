import 'package:flutter/material.dart';
import 'package:pvm/core/theme/app_theme.dart';
import 'package:pvm/core/utils/formatters.dart';
import 'package:pvm/features/checkout/domain/entities/cart_item.dart';
import 'package:pvm/features/checkout/presentation/widgets/barcode_label.dart';

class ProductListItem extends StatelessWidget {
  const ProductListItem({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  // Con menos ancho que esto, el producto se muestra en dos filas.
  static const double _singleRowMinWidth = 560;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final singleRow = constraints.maxWidth >= _singleRowMinWidth;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
          child: singleRow ? _buildSingleRow(context) : _buildTwoRows(context),
        );
      },
    );
  }

  // Panel ancho: código, nombre, cantidad, subtotal y eliminar en una fila.
  Widget _buildSingleRow(BuildContext context) {
    return Row(
      children: [
        BarcodeLabel(barcode: item.barcode),
        const SizedBox(width: 12),
        Expanded(child: _name(context)),
        const SizedBox(width: 12),
        _QuantityStepper(
          quantity: item.quantity,
          onIncrement: onIncrement,
          onDecrement: onDecrement,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 88,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: _subtotal(context),
          ),
        ),
        const SizedBox(width: 4),
        _removeButton(context),
      ],
    );
  }

  // Panel angosto: arriba código, nombre y eliminar; abajo cantidad y subtotal.
  Widget _buildTwoRows(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            BarcodeLabel(barcode: item.barcode),
            const SizedBox(width: 12),
            Expanded(child: _name(context)),
            _removeButton(context),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _QuantityStepper(
              quantity: item.quantity,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _subtotal(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }

  Widget _name(BuildContext context) {
    return Text(
      item.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
    );
  }

  Widget _subtotal(BuildContext context) {
    return Text(
      Formatters.currency(item.subtotal),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }

  Widget _removeButton(BuildContext context) {
    return IconButton(
      onPressed: onRemove,
      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
      tooltip: 'Eliminar producto',
      visualDensity: VisualDensity.compact,
    );
  }
}

// Selector -[cantidad]+ con botones de 44 dp para tocar con el dedo.
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PosColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: PosColors.keyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: onDecrement,
            radius: const BorderRadius.horizontal(left: Radius.circular(9)),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 32),
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: onIncrement,
            radius: const BorderRadius.horizontal(right: Radius.circular(9)),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    required this.radius,
  });

  final IconData icon;
  final VoidCallback onTap;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(child: Icon(icon, size: 20)),
      ),
    );
  }
}