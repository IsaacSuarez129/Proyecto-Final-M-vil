import 'package:flutter/material.dart';
import 'package:pvm/core/theme/app_theme.dart';
import 'package:pvm/core/utils/formatters.dart';

class PaymentPanel extends StatelessWidget {
  const PaymentPanel({
    super.key,
    required this.total,
    required this.payment,
    required this.change,
    required this.onKeyPressed,
    required this.onCharge,
  });

  final double total;
  final double payment;
  final double change;

  // Recibe '0'-'9', '.' o 'backspace'.
  final ValueChanged<String> onKeyPressed;

  // Se llama al presionar el botón verde de cobrar.
  final VoidCallback onCharge;

  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 84,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _AmountField(
                  label: 'Total',
                  value: total,
                  labelColor: PosColors.fieldLabel,
                  valueColor: PosColors.totalText,
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: _AmountField(
                  label: 'Pago',
                  value: payment,
                  labelColor: PosColors.paymentText,
                  valueColor: PosColors.paymentText,
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: _AmountField(
                  label: 'Cambio',
                  value: change,
                  labelColor: PosColors.changeText,
                  valueColor: PosColors.changeText,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _gap),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 3, child: _Keypad(onKeyPressed: onKeyPressed)),
              const SizedBox(width: _gap),
              Expanded(child: _ChargeButton(onPressed: onCharge)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
  });

  final String label;
  final double value;
  final Color labelColor;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: PosColors.keyBorder),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                Formatters.currency(value),
                style: textTheme.headlineSmall?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKeyPressed});

  final ValueChanged<String> onKeyPressed;

  static const double _gap = 12;
  static const List<List<String>> _rows = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['0', '.', 'backspace'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var r = 0; r < _rows.length; r++) ...[
          if (r > 0) const SizedBox(height: _gap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var c = 0; c < _rows[r].length; c++) ...[
                  if (c > 0) const SizedBox(width: _gap),
                  Expanded(
                    child: _KeypadButton(
                      keyValue: _rows[r][c],
                      onPressed: onKeyPressed,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({required this.keyValue, required this.onPressed});

  final String keyValue;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    final isBackspace = keyValue == 'backspace';
    final isDark = isBackspace || keyValue == '.';
    final foreground = isDark ? PosColors.darkKeyText : PosColors.keyText;

    return Material(
      color: isDark ? PosColors.darkKey : PosColors.key,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? PosColors.darkKey : PosColors.keyBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onPressed(keyValue),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: isBackspace
                ? Icon(Icons.backspace_outlined, size: 30, color: foreground)
                : Text(
                    keyValue,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: foreground,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _ChargeButton extends StatelessWidget {
  const _ChargeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PosColors.charge,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.keyboard_return,
                    size: 40,
                    color: PosColors.chargeText,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Cobrar',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: PosColors.chargeText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}