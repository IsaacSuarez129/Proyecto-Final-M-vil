import 'package:flutter/material.dart';
import 'package:pvm/core/theme/app_theme.dart';

class PosAction {
  const PosAction({required this.label, required this.onPressed});

  final String label;

  // Si es null, el botón se ve deshabilitado.
  final VoidCallback? onPressed;
}

class ActionButtonsPanel extends StatelessWidget {
  const ActionButtonsPanel({
    super.key,
    required this.actions,
    this.columns = 3,
  });

  final List<PosAction> actions;
  final int columns;

  static const double _gap = 12;

  @override
  Widget build(BuildContext context) {
    final rowCount = (actions.length / columns).ceil();

    return Column(
      children: [
        for (var r = 0; r < rowCount; r++) ...[
          if (r > 0) const SizedBox(height: _gap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var c = 0; c < columns; c++) ...[
                  if (c > 0) const SizedBox(width: _gap),
                  Expanded(child: _cell(r * columns + c)),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _cell(int index) {
    if (index >= actions.length) return const SizedBox.shrink();
    final action = actions[index];
    final enabled = action.onPressed != null;
    const fade = 0.45;

    return Material(
      color: enabled
          ? PosColors.actionButton
          : PosColors.actionButton.withValues(alpha: fade),
      elevation: enabled ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: enabled
              ? PosColors.actionButtonBorder
              : PosColors.actionButtonBorder.withValues(alpha: fade),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: action.onPressed,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                action.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? PosColors.actionButtonText
                      : PosColors.actionButtonText.withValues(alpha: fade),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}