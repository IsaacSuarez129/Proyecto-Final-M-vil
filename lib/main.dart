import 'package:flutter/material.dart';
import 'package:pvm/app.dart';
import 'package:pvm/core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const PosApp());
}