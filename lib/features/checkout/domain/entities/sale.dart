import 'package:pvm/features/checkout/domain/entities/cart_item.dart';

class Sale {
  const Sale({
    required this.id,
    required this.folio,
    required this.shiftId,
    required this.cashierName,
    required this.items,
    required this.total,
    required this.payment,
    required this.change,
    required this.createdAt,
  });

  final String id;
  final int folio;
  final String shiftId;
  final String cashierName;
  final List<CartItem> items;
  final double total;
  final double payment;
  final double change;
  final DateTime createdAt;
}