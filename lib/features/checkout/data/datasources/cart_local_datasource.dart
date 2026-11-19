import 'dart:convert';

import 'package:pvm/features/checkout/domain/entities/pos_ticket.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartLocalDatasource {
  const CartLocalDatasource();

  // Los tickets abiertos se guardan por turno: otro turno u otro cajero
  // nunca ve los tickets pendientes de un turno anterior.
  static String _ticketsKey(String shiftId) => 'pos_open_tickets_v1_$shiftId';

  static String _activeIndexKey(String shiftId) =>
      'pos_active_ticket_index_v1_$shiftId';

  Future<({List<PosTicket> tickets, int activeIndex})?> loadTickets(
    String shiftId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ticketsKey(shiftId));
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final tickets = decoded
          .map((e) => PosTicket.fromJson(e as Map<String, dynamic>))
          .toList();
      if (tickets.isEmpty) return null;

      final savedIndex = prefs.getInt(_activeIndexKey(shiftId)) ?? 0;
      final safeIndex = savedIndex.clamp(0, tickets.length - 1);
      return (tickets: tickets, activeIndex: safeIndex);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTickets({
    required String shiftId,
    required List<PosTicket> tickets,
    required int activeIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tickets.map((t) => t.toJson()).toList());
    await prefs.setString(_ticketsKey(shiftId), encoded);
    await prefs.setInt(_activeIndexKey(shiftId), activeIndex);
  }
}