class CartItem {
  const CartItem({
    required this.productId,
    required this.name,
    required this.barcode,
    required this.price,
    this.quantity = 1,
  });

  // Máximo de piezas por línea (evita errores de dedo y desbordes en pantalla).
  static const int maxQuantity = 99;

  final String productId;
  final String name;
  final String barcode;
  final double price;
  final int quantity;

  // El dinero se calcula en centavos (enteros) para evitar los errores de
  // redondeo de double (0.1 + 0.2 != 0.3).
  int get subtotalCents => (price * 100).round() * quantity;

  double get subtotal => subtotalCents / 100;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      barcode: barcode,
      price: price,
      quantity: (quantity ?? this.quantity).clamp(1, maxQuantity).toInt(),
    );
  }
}