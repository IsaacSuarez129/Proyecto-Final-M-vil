import 'package:pvm/core/constants/app_constants.dart';

class Responsive {
  const Responsive(this.width);

  // Ancho disponible real (ya descontado el SafeArea).
  final double width;

  bool get isCompact => width < AppConstants.compactBreakpoint;

  double get contentPadding => isCompact ? 12 : 20;

  double get gap => isCompact ? 12 : 16;

  // 42% del ancho, limitado entre un mínimo y un máximo.
  double get actionPanelWidth => (width * 0.42)
      .clamp(AppConstants.actionPanelMinWidth, AppConstants.actionPanelMaxWidth)
      .toDouble();
}
