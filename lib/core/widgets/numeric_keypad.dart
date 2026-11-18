import 'package:flutter/material.dart';
import 'package:pvm/core/theme/app_theme.dart';

class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    this.showDot = false,
    this.gap = 10,
  });

  // Recibe '0'-'9', '.' o 'backspace'.
  final ValueChanged<String> onKeyPressed;
  final bool showDot;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      [showDot ? '.' : '', '0', 'backspace'],
    ];

    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) SizedBox(height: gap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var c = 0; c < rows[r].length; c++) ...[
                  if (c > 0) SizedBox(width: gap),
                  Expanded(
                    child: rows[r][c].isEmpty
                        ? const SizedBox.shrink()
                        : _KeyButton(
                            keyValue: rows[r][c],
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

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.keyValue, required this.onPressed});

  final String keyValue;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    final isBackspace = keyValue == 'backspace';
    final isDark = isBackspace || keyValue == '.';
    final foreground = isDark ? PosColors.darkKeyText : PosColors.keyText;

    return Material(
      color: isDark ? PosColors.darkKey : PosColors.key,
      elevation: 1.5,
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
                ? Icon(Icons.backspace_outlined, size: 24, color: foreground)
                : Text(
                    keyValue,
                    style: TextStyle(
                      fontSize: 25,
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