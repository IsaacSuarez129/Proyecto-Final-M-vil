import 'package:pvm/features/checkout/domain/entities/cart_item.dart';

class PosTicket {
  const PosTicket({
    required this.id,
    required this.number,
    this.items = const [],
    this.paymentInput = '',
  });

  factory PosTicket.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? []);
    return PosTicket(
      id: json['id'] as String,
      number: (json['number'] as num).toInt(),
      items: rawItems
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentInput: json['payment_input'] as String? ?? '',
    );
  }

  final String id;
  final int number;
  final List<CartItem> items;
  final String paymentInput;

  int get totalCents => items.fold<int>(0, (sum, item) => sum + item.subtotalCents);

  double get total => totalCents / 100;

  int get totalItemsCount =>
      items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get payment {
    final text = paymentInput.endsWith('.')
        ? paymentInput.substring(0, paymentInput.length - 1)
        : paymentInput;
    return double.tryParse(text.isEmpty ? '0' : text) ?? 0;
  }

  int get paymentCents => (payment * 100).round();

  double get change {
    if (totalCents <= 0 || paymentCents < totalCents) return 0;
    return (paymentCents - totalCents) / 100;
  }

  bool get canCharge => totalCents > 0 && paymentCents >= totalCents;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'items': items.map((e) => e.toJson()).toList(),
      'payment_input': paymentInput,
    };
  }

  PosTicket copyWith({
    List<CartItem>? items,
    String? paymentInput,
  }) {
    return PosTicket(
      id: id,
      number: number,
      items: items ?? this.items,
      paymentInput: paymentInput ?? this.paymentInput,
    );
  }
}