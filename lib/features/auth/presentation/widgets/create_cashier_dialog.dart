import 'package:flutter/material.dart';
import 'package:pvm/features/auth/data/repositories/profile_repository.dart';
import 'package:pvm/features/auth/domain/entities/profile.dart';
import 'package:pvm/features/auth/presentation/widgets/profile_form.dart';

class CreateCashierDialog extends StatelessWidget {
  const CreateCashierDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nuevo cajero',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ProfileForm(
                submitLabel: 'Guardar',
                onCancel: () => Navigator.of(context).pop(false),
                onSubmit: (data) async {
                  await const ProfileRepository().createProfile(
                    name: data.name,
                    pin: data.pin,
                    role: ProfileRole.cashier,
                    photo: data.photo,
                  );
                  if (context.mounted) Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}