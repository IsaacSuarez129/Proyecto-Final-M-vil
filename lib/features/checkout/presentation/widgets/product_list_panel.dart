import 'package:flutter/material.dart';
import 'package:pvm/features/checkout/domain/entities/cart_item.dart';
import 'package:pvm/features/checkout/presentation/widgets/product_list_item.dart';

class ProductListPanel extends StatelessWidget {
  const ProductListPanel({
    super.key,
    required this.items,
    required this.onIncrementItem,
    required this.onDecrementItem,
    required this.onRemoveItem,
  });

  final List<CartItem> items;
  final ValueChanged<CartItem> onIncrementItem;
  final ValueChanged<CartItem> onDecrementItem;
  final ValueChanged<CartItem> onRemoveItem;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(16);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: radius,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: items.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ProductListItem(
                    item: item,
                    onIncrement: () => onIncrementItem(item),
                    onDecrement: () => onDecrementItem(item),
                    onRemove: () => onRemoveItem(item),
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 64, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              'Escanea un producto para comenzar',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}