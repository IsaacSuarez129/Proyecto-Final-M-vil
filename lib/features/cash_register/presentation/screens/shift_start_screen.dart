import 'package:flutter/material.dart';
import 'package:pvm/core/constants/app_constants.dart';
import 'package:pvm/core/theme/app_theme.dart';
import 'package:pvm/core/utils/formatters.dart';
import 'package:pvm/core/widgets/numeric_keypad.dart';
import 'package:pvm/features/auth/data/repositories/profile_repository.dart';
import 'package:pvm/features/auth/domain/entities/profile.dart';
import 'package:pvm/features/auth/presentation/widgets/profile_avatar.dart';
import 'package:pvm/features/cash_register/data/repositories/shift_repository.dart';

enum _Step { selectProfile, enterPin, enterAmount }

class ShiftStartScreen extends StatefulWidget {
  const ShiftStartScreen({super.key, required this.onShiftOpened});

  // Se llama cuando el turno ya quedó guardado en Supabase.
  final VoidCallback onShiftOpened;

  @override
  State<ShiftStartScreen> createState() => _ShiftStartScreenState();
}

class _ShiftStartScreenState extends State<ShiftStartScreen> {
  final _profileRepository = const ProfileRepository();
  final _shiftRepository = const ShiftRepository();

  late Future<List<Profile>> _profilesFuture;
  _Step _step = _Step.selectProfile;
  Profile? _selected;
  String _pin = '';
  String _amount = '';
  String? _error;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _profilesFuture = _profileRepository.fetchAllProfiles();
  }

  void _reloadProfiles() {
    setState(() {
      _profilesFuture = _profileRepository.fetchAllProfiles();
    });
  }

  void _selectProfile(Profile profile) {
    setState(() {
      _selected = profile;
      _pin = '';
      _error = null;
      _step = _Step.enterPin;
    });
  }

  void _backToProfiles() {
    setState(() {
      _selected = null;
      _pin = '';
      _amount = '';
      _error = null;
      _step = _Step.selectProfile;
    });
  }

  Future<void> _onPinKey(String key) async {
    if (_isBusy) return;

    if (key == 'backspace') {
      if (_pin.isEmpty) return;
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = null;
      });
      return;
    }
    if (_pin.length >= AppConstants.pinLength) return;

    setState(() {
      _pin += key;
      _error = null;
    });
    if (_pin.length == AppConstants.pinLength) await _verifyPin();
  }

  Future<void> _verifyPin() async {
    setState(() => _isBusy = true);
    try {
      final isValid = await _profileRepository.verifyPin(
        profileId: _selected!.id,
        pin: _pin,
      );
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        if (isValid) {
          _amount = '';
          _step = _Step.enterAmount;
        } else {
          _pin = '';
          _error = 'PIN incorrecto';
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _pin = '';
        _error = 'No se pudo verificar el PIN. Intenta de nuevo.';
      });
    }
  }

  void _onAmountKey(String key) {
    setState(() {
      _error = null;

      if (key == 'backspace') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
        return;
      }
      if (key == '.') {
        if (_amount.contains('.')) return;
        _amount = _amount.isEmpty ? '0.' : '$_amount.';
        return;
      }

      if (_amount.length >= 9) return;
      final dot = _amount.indexOf('.');
      // Máximo 2 decimales.
      if (dot != -1 && _amount.length - dot > 2) return;
      _amount = _amount == '0' ? key : '$_amount$key';
    });
  }

  double get _amountValue {
    final text = _amount.endsWith('.')
        ? _amount.substring(0, _amount.length - 1)
        : _amount;
    return double.tryParse(text.isEmpty ? '0' : text) ?? 0;
  }

  Future<void> _openShift() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      await _shiftRepository.openShift(
        profileId: _selected!.id,
        openingAmount: _amountValue,
      );
      widget.onShiftOpened();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _error = 'No se pudo abrir el turno. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final isCompactHeight = constraints.maxHeight < 480;

            return switch (_step) {
              _Step.selectProfile =>
                _buildSelectProfile(isLandscape, isCompactHeight),
              _Step.enterPin => _buildPinStep(isLandscape, isCompactHeight),
              _Step.enterAmount =>
                _buildAmountStep(isLandscape, isCompactHeight),
            };
          },
        ),
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PosColors.keyBorder),
      );

  Widget _buildKeypadLayout({
    required bool isLandscape,
    required bool isCompactHeight,
    required Widget info,
    required Widget keypad,
    Widget? footer,
  }) {
    final outerPadding = isCompactHeight ? 12.0 : 20.0;
    final cardPadding = isCompactHeight ? 16.0 : 22.0;

    final Widget body;

    if (isLandscape) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _backButton(),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        info,
                        if (footer != null) ...[
                          const SizedBox(height: 8),
                          footer,
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 10,
            child: keypad,
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _backButton(),
          const SizedBox(height: 8),
          info,
          const SizedBox(height: 12),
          Expanded(child: keypad),
          if (footer != null) ...[
            const SizedBox(height: 14),
            footer,
          ],
        ],
      );
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(outerPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isLandscape ? 650 : 420,
            maxHeight: isLandscape ? 430 : 620,
          ),
          child: Container(
            padding: EdgeInsets.all(cardPadding),
            decoration: _cardDecoration,
            child: body,
          ),
        ),
      ),
    );
  }

  Widget _backButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: _isBusy ? null : _backToProfiles,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        icon: const Icon(Icons.arrow_back, size: 18),
        label: const Text('Cambiar perfil'),
      ),
    );
  }

  Widget _errorLine() {
    return SizedBox(
      height: 22,
      child: Center(
        child: Text(
          _error ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectProfile(bool isLandscape, bool isCompactHeight) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isCompactHeight ? 16 : 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isLandscape ? 600 : 420),
          child: Container(
            padding: EdgeInsets.all(isCompactHeight ? 20 : 28),
            decoration: _cardDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Inicia tu turno',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Elige tu perfil',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: PosColors.fieldLabel,
                  ),
                ),
                const SizedBox(height: 20),
                FutureBuilder<List<Profile>>(
                  future: _profilesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SizedBox(
                        height: 110,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Column(
                        children: [
                          const Text('No se pudieron cargar los perfiles.'),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: _reloadProfiles,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      );
                    }
                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final profile in snapshot.data!)
                          _ProfileCard(
                            profile: profile,
                            onTap: () => _selectProfile(profile),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinStep(bool isLandscape, bool isCompactHeight) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final profile = _selected!;

    final info = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: ProfileAvatar(
            name: profile.name,
            avatarUrl: profile.avatarUrl,
            radius: isCompactHeight ? 24 : 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          profile.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          'Ingresa tu PIN',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: PosColors.fieldLabel),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < AppConstants.pinLength; i++)
              Container(
                width: 13,
                height: 13,
                margin: const EdgeInsets.symmetric(horizontal: 7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < _pin.length ? scheme.primary : Colors.transparent,
                  border: Border.all(
                    color: i < _pin.length ? scheme.primary : PosColors.keyBorder,
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        _errorLine(),
      ],
    );

    return _buildKeypadLayout(
      isLandscape: isLandscape,
      isCompactHeight: isCompactHeight,
      info: info,
      keypad: NumericKeypad(
        onKeyPressed: _onPinKey,
        gap: isCompactHeight ? 8 : 10,
      ),
    );
  }

  Widget _buildAmountStep(bool isLandscape, bool isCompactHeight) {
    final textTheme = Theme.of(context).textTheme;
    final profile = _selected!;

    final info = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProfileAvatar(
              name: profile.name,
              avatarUrl: profile.avatarUrl,
              radius: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Saldo inicial de caja',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: PosColors.fieldLabel),
        ),
        const SizedBox(height: 6),
        Container(
          height: 52,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: PosColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PosColors.keyBorder),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              Formatters.currency(_amountValue),
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: PosColors.paymentText,
              ),
            ),
          ),
        ),
        _errorLine(),
      ],
    );

    final footer = SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: _isBusy ? null : _openShift,
        child: _isBusy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Abrir turno'),
      ),
    );

    return _buildKeypadLayout(
      isLandscape: isLandscape,
      isCompactHeight: isCompactHeight,
      info: info,
      keypad: NumericKeypad(
        onKeyPressed: _onAmountKey,
        showDot: true,
        gap: isCompactHeight ? 8 : 10,
      ),
      footer: footer,
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.onTap});

  final Profile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 116,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileAvatar(
                  name: profile.name,
                  avatarUrl: profile.avatarUrl,
                  radius: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  profile.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium,
                ),
                if (profile.isAdmin)
                  Text(
                    'Administrador',
                    style: textTheme.bodySmall?.copyWith(
                      color: PosColors.fieldLabel,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}