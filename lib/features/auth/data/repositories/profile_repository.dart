import 'package:image_picker/image_picker.dart';
import 'package:pvm/core/config/supabase_config.dart';
import 'package:pvm/core/utils/pin_hasher.dart';
import 'package:pvm/features/auth/domain/entities/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ProfileRepository {
  const ProfileRepository();

  static const String _table = 'profiles';
  static const String _bucket = 'avatars';
  static const String _columns = 'id, name, role, avatar_url';

  Future<bool> hasAdminProfile() async {
    final rows = await SupabaseConfig.client
        .from(_table)
        .select('id')
        .eq('role', 'admin')
        .limit(1);
    return rows.isNotEmpty;
  }

  // Todos los perfiles (el administrador aparece primero).
  Future<List<Profile>> fetchAllProfiles() async {
    final rows = await SupabaseConfig.client
        .from(_table)
        .select(_columns)
        .order('role')
        .order('name');
    return rows.map(Profile.fromJson).toList();
  }

  Future<List<Profile>> fetchCashiers() async {
    final rows = await SupabaseConfig.client
        .from(_table)
        .select(_columns)
        .eq('role', 'cashier')
        .order('name');
    return rows.map(Profile.fromJson).toList();
  }

  // Compara el PIN escrito con el hash guardado; el hash nunca sale de aquí.
  Future<bool> verifyPin({required String profileId, required String pin}) async {
    final row = await SupabaseConfig.client
        .from(_table)
        .select('pin_hash, pin_salt')
        .eq('id', profileId)
        .single();

    final hash = PinHasher.hash(pin, row['pin_salt'] as String);
    return hash == row['pin_hash'] as String;
  }

  Future<void> createProfile({
    required String name,
    required String pin,
    required ProfileRole role,
    XFile? photo,
  }) async {
    final avatarUrl = photo == null ? null : await _uploadAvatar(photo);
    final salt = PinHasher.generateSalt();

    await SupabaseConfig.client.from(_table).insert({
      'name': name,
      'role': role.name,
      'avatar_url': avatarUrl,
      'pin_salt': salt,
      'pin_hash': PinHasher.hash(pin, salt),
    });
  }

  // Sube la foto a avatars/<id de la cuenta>/<uuid>.<ext> y devuelve su URL.
  Future<String> _uploadAvatar(XFile photo) async {
    final ownerId = SupabaseConfig.client.auth.currentUser!.id;
    final extension =
        photo.name.contains('.') ? photo.name.split('.').last.toLowerCase() : 'jpg';
    final path = '$ownerId/${const Uuid().v4()}.$extension';
    final storage = SupabaseConfig.client.storage.from(_bucket);

    await storage.uploadBinary(
      path,
      await photo.readAsBytes(),
      fileOptions: FileOptions(contentType: photo.mimeType),
    );
    return storage.getPublicUrl(path);
  }
}