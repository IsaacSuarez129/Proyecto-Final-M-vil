import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pvm/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  const AuthRepository();

  // Abre el navegador con el login de Google. Cuando el usuario termina,
  // Supabase regresa a la app por el deep link y se crea la sesión.
  Future<void> signInWithGoogle() async {
    await SupabaseConfig.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : SupabaseConfig.authRedirectUrl,
    );
  }
}