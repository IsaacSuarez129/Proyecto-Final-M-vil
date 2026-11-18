enum ProfileRole { admin, cashier }

class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.role,
    this.avatarUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] == 'admin' ? ProfileRole.admin : ProfileRole.cashier,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  final String id;
  final String name;
  final ProfileRole role;
  final String? avatarUrl;

  bool get isAdmin => role == ProfileRole.admin;
}