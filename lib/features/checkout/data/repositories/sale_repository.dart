import 'package:pvm/core/config/supabase_config.dart';
import 'package:pvm/features/cash_register/domain/entities/shift.dart';
import 'package:pvm/features/checkout/domain/entities/cart_item.dart';
import 'package:pvm/features/checkout/domain/entities/sale.dart';

class SaleRepository {
  const SaleRepository();

  // Registra la venta y sus artículos en una sola transacción (create_sale).
  // [ticketId] evita duplicados: si se reintenta, devuelve la venta ya guardada.
  Future<Sale> registerSale({
    required String ticketId,
    required Shift shift,
    required List<CartItem> items,
    required double total,
    required double payment,
    required double change,
  }) async {
    final result = await SupabaseConfig.client.rpc(
      'create_sale',
      params: {
        'p_ticket_id': ticketId,
        'p_shift_id': shift.id,
        'p_profile_id': shift.profile.id,
        'p_total': total,
        'p_payment': payment,
        'p_change': change,
        'p_items': [
          for (final item in items)
            {
              'product_id': item.productId,
              'product_name': item.name,
              'barcode': item.barcode,
              'unit_price': item.price,
              'quantity': item.quantity,
              'subtotal': item.subtotal,
            },
        ],
      },
    );

    final row = result as Map<String, dynamic>;
    return Sale(
      id: row['id'] as String,
      folio: (row['folio'] as num).toInt(),
      shiftId: shift.id,
      cashierName: shift.profile.name,
      items: List.unmodifiable(items),
      total: total,
      payment: payment,
      change: change,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}