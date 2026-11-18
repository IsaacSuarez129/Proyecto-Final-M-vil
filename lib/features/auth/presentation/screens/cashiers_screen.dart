import 'package:flutter/material.dart';
import 'package:pvm/core/theme/app_theme.dart';
import 'package:pvm/features/auth/data/repositories/profile_repository.dart';
import 'package:pvm/features/auth/domain/entities/profile.dart';
import 'package:pvm/features/auth/presentation/widgets/create_cashier_dialog.dart';
import 'package:pvm/features/auth/presentation/widgets/profile_avatar.dart';

class CashiersScreen extends StatefulWidget {
  const CashiersScreen({super.key});

  @override
  State<CashiersScreen> createState() => _CashiersScreenState();
}

class _CashiersScreenState extends State<CashiersScreen> {
  final _repository = const ProfileRepository();
  late Future<List<Profile>> _cashiersFuture;

  @override
  void initState() {
    super.initState();
    _cashiersFuture = _repository.fetchCashiers();
  }

  void _reload() {
    setState(() {
      _cashiersFuture = _repository.fetchCashiers();
    });
  }

  Future<void> _createCashier() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateCashierDialog(),
    );
    if (created == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cajeros'),
        backgroundColor: PosColors.background,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createCashier,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nuevo cajero'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: FutureBuilder<List<Profile>>(
              future: _cashiersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorState(onRetry: _reload);
                }
                final cashiers = snapshot.data!;
                if (cashiers.isEmpty) {
                  return const _EmptyState();
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: cashiers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _CashierTile(cashier: cashiers[index]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CashierTile extends StatelessWidget {
  const _CashierTile({required this.cashier});

  final Profile cashier;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: PosColors.keyBorder),
      ),
      child: ListTile(
        leading: ProfileAvatar(name: cashier.name, avatarUrl: cashier.avatarUrl),
        title: Text(
          cashier.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined, size: 64, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              'Aún no hay cajeros.\nCrea el primero.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se pudieron cargar los cajeros.'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}