import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pvm/core/constants/app_constants.dart';

typedef ProfileFormData = ({String name, String pin, XFile? photo});

class ProfileForm extends StatefulWidget {
  const ProfileForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.onCancel,
  });

  final String submitLabel;
  final Future<void> Function(ProfileFormData data) onSubmit;
  final VoidCallback? onCancel;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();

  XFile? _photo;
  Uint8List? _photoBytes;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        imageQuality: 80,
      );

      // Si el cajero cierra o cancela la cámara, conserva sus iniciales.
      if (photo == null || !mounted) return;

      final bytes = await photo.readAsBytes();
      if (!mounted) return;

      setState(() {
        _photo = photo;
        _photoBytes = bytes;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la cámara.')),
      );
    }
  }

  Future<void> _submit() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.onSubmit((
        name: _nameController.text.trim(),
        pin: _pinController.text,
        photo: _photo,
      ));
    } catch (_) {
      if (mounted) {
        setState(() => _errorMessage = 'No se pudo guardar. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pinFormatters = [FilteringTextInputFormatter.digitsOnly];

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isSaving ? null : _takePhoto,
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: scheme.secondaryContainer,
                    backgroundImage:
                        _photoBytes == null ? null : MemoryImage(_photoBytes!),
                    child: _photoBytes == null
                        ? Icon(
                            Icons.add_a_photo_outlined,
                            size: 32,
                            color: scheme.onSecondaryContainer,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tomar foto (opcional)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Escribe un nombre'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: AppConstants.pinLength,
            inputFormatters: pinFormatters,
            decoration: InputDecoration(
              labelText: 'PIN de ${AppConstants.pinLength} dígitos',
              border: const OutlineInputBorder(),
              counterText: '',
            ),
            validator: (value) => (value ?? '').length != AppConstants.pinLength
                ? 'El PIN debe tener ${AppConstants.pinLength} dígitos'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: AppConstants.pinLength,
            inputFormatters: pinFormatters,
            decoration: const InputDecoration(
              labelText: 'Confirmar PIN',
              border: OutlineInputBorder(),
              counterText: '',
            ),
            onFieldSubmitted: (_) => _submit(),
            validator: (value) =>
                value != _pinController.text ? 'Los PIN no coinciden' : null,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(_errorMessage!, style: TextStyle(color: scheme.error)),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              if (widget.onCancel != null) ...[
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: TextButton(
                      onPressed: _isSaving ? null : widget.onCancel,
                      child: const Text('Cancelar'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.submitLabel),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}