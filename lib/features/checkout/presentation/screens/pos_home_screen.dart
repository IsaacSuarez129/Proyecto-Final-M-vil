import 'package:flutter/material.dart';
import 'package:pvm/core/utils/responsive.dart';
import 'package:pvm/features/auth/presentation/screens/cashiers_screen.dart';
import 'package:pvm/features/auth/presentation/widgets/profile_avatar.dart';
import 'package:pvm/features/cash_register/domain/entities/shift.dart';
import 'package:pvm/features/checkout/domain/entities/cart_item.dart';
import 'package:pvm/features/checkout/presentation/widgets/action_buttons_panel.dart';
import 'package:pvm/features/checkout/presentation/widgets/payment_panel.dart';
import 'package:pvm/features/checkout/presentation/widgets/product_list_panel.dart';

class PosHomeScreen extends StatelessWidget {
  const PosHomeScreen({super.key, required this.shift});

  // Turno abierto: define quién atiende y con cuánto abrió.
  final Shift shift;

  // TEMPORAL: productos de ejemplo para ver el diseño.
  static const List<CartItem> _demoItems = [
    CartItem(name: 'Coca-Cola 600 ml', barcode: '750105', price: 18.50),
    CartItem(name: 'Galletas Marías', barcode: '7501000123456', price: 24),
    CartItem(
      name: 'Aceite comestible vegetal de canola botella familiar 946 ml',
      barcode: '7501234567890',
      price: 52.90,
    ),
    CartItem(name: 'Pan', barcode: '1234', price: 3.5),
  ];

  // El botón 1 abre la gestión de cajeros (solo administrador);
  // los demás se definen después.
  List<PosAction> _buildActions(BuildContext context) {
    return List.generate(6, (index) {
      if (index == 0 && shift.profile.isAdmin) {
        return PosAction(
          label: 'Cajeros',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (context) => const CashiersScreen()),
          ),
        );
      }
      return PosAction(label: 'Botón ${index + 1}', onPressed: () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _demoItems.fold<double>(0, (sum, item) => sum + item.price);
    final actions = _buildActions(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final responsive = Responsive(constraints.maxWidth);

            return Padding(
              padding: EdgeInsets.all(responsive.contentPadding),
              child: Column(
                children: [
                  _ShiftHeader(shift: shift),
                  SizedBox(height: responsive.gap),
                  Expanded(
                    child: responsive.isCompact
                        ? _compactBody(responsive, total, actions)
                        : _expandedBody(responsive, total, actions),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _paymentPanel(double total) {
    // TEMPORAL: pago y cambio en cero; teclas y cobrar todavía no hacen nada.
    return PaymentPanel(
      total: total,
      payment: 0,
      change: 0,
      onKeyPressed: (key) {},
      onCharge: () {},
    );
  }

  // Tablet / pantalla ancha: productos a la izquierda; botones y cobro a la derecha.
  Widget _expandedBody(
    Responsive responsive,
    double total,
    List<PosAction> actions,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(child: ProductListPanel(items: _demoItems)),
        SizedBox(width: responsive.gap),
        SizedBox(
          width: responsive.actionPanelWidth,
          child: Column(
            children: [
              Expanded(flex: 2, child: ActionButtonsPanel(actions: actions)),
              SizedBox(height: responsive.gap),
              Expanded(flex: 5, child: _paymentPanel(total)),
            ],
          ),
        ),
      ],
    );
  }

  // Pantalla angosta: todo en una columna con scroll vertical.
  Widget _compactBody(
    Responsive responsive,
    double total,
    List<PosAction> actions,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 300,
            child: ProductListPanel(items: _demoItems),
          ),
          SizedBox(height: responsive.gap),
          SizedBox(height: 160, child: ActionButtonsPanel(actions: actions)),
          SizedBox(height: responsive.gap),
          SizedBox(height: 460, child: _paymentPanel(total)),
        ],
      ),
    );
  }
}

// Franja superior: quién está atendiendo.
class _ShiftHeader extends StatelessWidget {
  const _ShiftHeader({required this.shift});

  final Shift shift;

  @override
  Widget build(BuildContext context) {
    final profile = shift.profile;

    return Row(
      children: [
        ProfileAvatar(name: profile.name, avatarUrl: profile.avatarUrl, radius: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            profile.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}