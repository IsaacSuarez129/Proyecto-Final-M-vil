import 'package:flutter/material.dart';
import 'package:pvm/core/utils/responsive.dart';
import 'package:pvm/features/checkout/domain/entities/cart_item.dart';
import 'package:pvm/features/checkout/presentation/widgets/action_buttons_panel.dart';
import 'package:pvm/features/checkout/presentation/widgets/payment_panel.dart';
import 'package:pvm/features/checkout/presentation/widgets/product_list_panel.dart';

class PosHomeScreen extends StatelessWidget {
  const PosHomeScreen({super.key});

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

  // TEMPORAL: 6 botones genéricos; sus nombres y acciones se definen después.
  static final List<PosAction> _actions = List.generate(
    6,
    (index) => PosAction(label: 'Botón ${index + 1}', onPressed: () {}),
  );

  @override
  Widget build(BuildContext context) {
    final total = _demoItems.fold<double>(0, (sum, item) => sum + item.price);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final responsive = Responsive(constraints.maxWidth);

            return Padding(
              padding: EdgeInsets.all(responsive.contentPadding),
              child: responsive.isCompact
                  ? _compactBody(responsive, total)
                  : _expandedBody(responsive, total),
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
  Widget _expandedBody(Responsive responsive, double total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(child: ProductListPanel(items: _demoItems)),
        SizedBox(width: responsive.gap),
        SizedBox(
          width: responsive.actionPanelWidth,
          child: Column(
            children: [
              Expanded(flex: 2, child: ActionButtonsPanel(actions: _actions)),
              SizedBox(height: responsive.gap),
              Expanded(flex: 5, child: _paymentPanel(total)),
            ],
          ),
        ),
      ],
    );
  }

  // Pantalla angosta: todo en una columna con scroll vertical.
  Widget _compactBody(Responsive responsive, double total) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 300,
            child: ProductListPanel(items: _demoItems),
          ),
          SizedBox(height: responsive.gap),
          SizedBox(height: 160, child: ActionButtonsPanel(actions: _actions)),
          SizedBox(height: responsive.gap),
          SizedBox(height: 460, child: _paymentPanel(total)),
        ],
      ),
    );
  }
}