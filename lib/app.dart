import 'package:flutter/material.dart';
import 'package:pvm/core/config/supabase_config.dart';
import 'package:pvm/core/constants/app_constants.dart';
import 'package:pvm/core/theme/app_theme.dart';
import 'package:pvm/features/auth/data/repositories/profile_repository.dart';
import 'package:pvm/features/auth/presentation/screens/admin_setup_screen.dart';
import 'package:pvm/features/auth/presentation/screens/login_screen.dart';
import 'package:pvm/features/cash_register/data/repositories/shift_repository.dart';
import 'package:pvm/features/cash_register/domain/entities/shift.dart';
import 'package:pvm/features/cash_register/presentation/screens/shift_start_screen.dart';
import 'package:pvm/features/checkout/presentation/screens/pos_home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AuthGate(),
    );
  }
}

// Sin sesión de Google muestra el login; con sesión pasa a _SessionGate.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = SupabaseConfig.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;
        return session == null ? const LoginScreen() : const _SessionGate();
      },
    );
  }
}

typedef _SessionState = ({bool hasAdmin, Shift? shift});

// Decide la pantalla según el estado de la cuenta:
// sin administrador -> crear perfil; sin turno abierto -> iniciar turno;
// con turno abierto -> terminal de cobro.
class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  final _profileRepository = const ProfileRepository();
  final _shiftRepository = const ShiftRepository();
  late Future<_SessionState> _stateFuture;

  @override
  void initState() {
    super.initState();
    _stateFuture = _load();
  }

  Future<_SessionState> _load() async {
    final hasAdmin = await _profileRepository.hasAdminProfile();
    final shift = hasAdmin ? await _shiftRepository.fetchOpenShift() : null;
    return (hasAdmin: hasAdmin, shift: shift);
  }

  void _reload() {
    setState(() {
      _stateFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SessionState>(
      future: _stateFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudo conectar con el servidor.'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _reload,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final state = snapshot.data!;
        if (!state.hasAdmin) return AdminSetupScreen(onCreated: _reload);

        final shift = state.shift;
        if (shift == null) return ShiftStartScreen(onShiftOpened: _reload);

        return PosHomeScreen(shift: shift);
      },
    );
  }
}