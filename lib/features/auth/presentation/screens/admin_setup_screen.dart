import 'package:flutter/material.dart';
import 'package:pvm/core/theme/app_theme.dart';
import 'package:pvm/features/auth/data/repositories/profile_repository.dart';
import 'package:pvm/features/auth/domain/entities/profile.dart';
import 'package:pvm/features/auth/presentation/widgets/profile_form.dart';

class AdminSetupScreen extends StatelessWidget {
  const AdminSetupScreen({super.key, required this.onCreated});

  // Se llama cuando el perfil de administrador ya quedó guardado.
  final VoidCallback onCreated;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: PosColors.keyBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_outlined,
                      size: 48,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Crea tu perfil de administrador',
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Con este perfil abrirás turno y administrarás a los cajeros.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: PosColors.fieldLabel,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ProfileForm(
                      submitLabel: 'Crear perfil',
                      onSubmit: (data) async {
                        await const ProfileRepository().createProfile(
                          name: data.name,
                          pin: data.pin,
                          role: ProfileRole.admin,
                          photo: data.photo,
                        );
                        onCreated();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}