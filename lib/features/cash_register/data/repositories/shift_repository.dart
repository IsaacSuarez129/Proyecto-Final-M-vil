import 'package:pvm/core/config/supabase_config.dart';
import 'package:pvm/features/cash_register/domain/entities/shift.dart';

class ShiftRepository {
  const ShiftRepository();

  static const String _table = 'shifts';
  static const String _columns =
      'id, opening_amount, opened_at, profiles(id, name, role, avatar_url)';

  // Devuelve el turno que no se ha cerrado, o null si no hay ninguno.
  Future<Shift?> fetchOpenShift() async {
    final rows = await SupabaseConfig.client
        .from(_table)
        .select(_columns)
        .isFilter('closed_at', null)
        .limit(1);
    return rows.isEmpty ? null : Shift.fromJson(rows.first);
  }

  Future<Shift> openShift({
    required String profileId,
    required double openingAmount,
  }) async {
    final row = await SupabaseConfig.client
        .from(_table)
        .insert({'profile_id': profileId, 'opening_amount': openingAmount})
        .select(_columns)
        .single();
    return Shift.fromJson(row);
  }
}