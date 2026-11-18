import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  // Se leen de env.json mediante --dart-define-from-file.
  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Deep link al que Supabase regresa después del login con Google.
  // Debe coincidir con AndroidManifest.xml y con Supabase > Redirect URLs.
  static const String authRedirectUrl = 'io.supabase.pvm://login-callback/';

  static Future<void> initialize() {
    if (url.isEmpty || anonKey.isEmpty) {
      throw StateError(
        'Faltan SUPABASE_URL y SUPABASE_ANON_KEY. '
        'Ejecuta con: flutter run --dart-define-from-file=env.json',
      );
    }
    return Supabase.initialize(url: url, publishableKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}