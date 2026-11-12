import 'package:flutter/material.dart';
import 'package:pvm/core/constants/app_constants.dart';

class BarcodeLabel extends StatelessWidget {
  const BarcodeLabel({super.key, required this.barcode});

  final String barcode;

  static const double _iconSlot = 20;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.titleMedium!.copyWith(
          letterSpacing: 1,
          color: scheme.onSurfaceVariant,
        );

    final isScrollable = barcode.length > AppConstants.barcodeInlineMaxDigits;
    final boxWidth = _measureSixDigits(context, style);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: boxWidth,
            child: isScrollable
                ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(barcode, style: style, softWrap: false),
                  )
                : Text(barcode, style: style, maxLines: 1),
          ),
          SizedBox(
            width: _iconSlot,
            child: isScrollable
                ? Icon(Icons.swap_horiz, size: 16, color: scheme.outline)
                : null,
          ),
        ],
      ),
    );
  }

  // Mide cuánto ocupan 6 dígitos con este estilo y el tamaño de texto del
  // usuario, para que la caja nunca sea más ancha ni más angosta de lo debido.
  double _measureSixDigits(BuildContext context, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(
        text: '0' * AppConstants.barcodeInlineMaxDigits,
        style: style,
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width + 2;
  }
}
