import 'package:pvm/features/auth/domain/entities/profile.dart';

class Shift {
  const Shift({
    required this.id,
    required this.profile,
    required this.openingAmount,
    required this.openedAt,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as String,
      profile: Profile.fromJson(json['profiles'] as Map<String, dynamic>),
      openingAmount: (json['opening_amount'] as num).toDouble(),
      openedAt: DateTime.parse(json['opened_at'] as String),
    );
  }

  final String id;
  final Profile profile;
  final double openingAmount;
  final DateTime openedAt;
}