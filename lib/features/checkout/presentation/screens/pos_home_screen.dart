import 'package:flutter/material.dart';
import 'package:pvm/core/utils/responsive.dart';
import 'package:pvm/features/auth/presentation/screens/cashiers_screen.dart';
import 'package:pvm/features/auth/presentation/widgets/profile_avatar.dart';
import 'package:pvm/features/cash_register/domain/entities/shift.dart';
import 'package:pvm/features/catalog/domain/entities/product.dart';
import 'package:pvm/features/catalog/presentation/widgets/catalog_dialog.dart';
import 'package:pvm/features/checkout/domain/entities/cart_item.dart';
import 'package:pvm/features/checkout/presentation/widgets/action_buttons_panel.dart';
import 'package:pvm/features/checkout/presentation/widgets/payment_panel.dart';
import 'package:pvm/features/checkout/presentation/widgets/product_list_panel.dart';

class PosHomeScreen extends StatefulWidget {
  const PosHomeScreen({super.key, required this.shift});

  // Turno abierto: define quién atiende y con cuánto abrió.
  final Shift shift;

  @override
  State<PosHomeScreen> createState() => _PosHomeScreenState();
}

class _PosHomeScreenState extends State<PosHomeScreen> {
  final List<CartItem> _items = [];

  void _addProduct(Product product) {
    setState(() {
      final index = _items.indexWhere((item) => item.productId == product.id);
      if (index != -1) {
        final current = _items[index];
        _items[index] = current.copyWith(quantity: current.quantity + 1);
      } else {
        _items.add(
          CartItem(
            productId: product.id,
            name: product.name,
            barcode: product.code,
            price: product.price,
          ),
        );
      }
    });
  }

  void _incrementItem(CartItem target) {
    setState(() {
      final index = _items.indexWhere(
        (item) => item.productId == target.productId,
      );
      if (index == -1) return;
      final current = _items[index];
      _items[index] = current.copyWith(quantity: current.quantity + 1);
    });
  }

  void _decrementItem(CartItem target) {
    setState(() {
      final index = _items.indexWhere(
        (item) => item.productId == target.productId,
      );
      if (index == -1) return;
      final current = _items[index];
      if (current.quantity <= 1) {
        _items.removeAt(index);
      } else {
        _items[index] = current.copyWith(quantity: current.quantity - 1);
      }
    });
  }

  void _removeItem(CartItem target) {
    setState(() {
      _items.removeWhere((item) => item.productId == target.productId);
    });
  }

  // Botón 1: gestión de cajeros (solo administrador). Botón 2: catálogo.
  // Los demás se definen después.
  List<PosAction> _buildActions(BuildContext context) {
    return List.generate(6, (index) {
      if (index == 0 && widget.shift.profile.isAdmin) {
        return PosAction(
          label: 'Cajeros',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (context) => const CashiersScreen()),
          ),
        );
      }
      if (index == 1) {
        return PosAction(
          label: 'Productos',
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => CatalogDialog(
              canManage: widget.shift.profile.isAdmin,
              onAddProduct: _addProduct,
            ),
          ),
        );
      }
      return PosAction(label: 'Botón ${index + 1}', onPressed: () {});
    });
  }

  @override
  Widget build(BuildContext context) {
        // Se suma en centavos (enteros) y se convierte a pesos solo para mostrar.
    final totalCents = _items.fold<int>(0, (sum, item) => sum + item.subtotalCents);
    final total = totalCents / 100;
    final actions = _buildActions(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final responsive = Responsive(constraints.maxWidth);

            return Padding(
              padding: EdgeInsets.all(responsive.contentPadding),
              child: Column(
                children: [
                  _ShiftHeader(shift: widget.shift),
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
        Expanded(
          child: ProductListPanel(
            items: _items,
            onIncrementItem: _incrementItem,
            onDecrementItem: _decrementItem,
            onRemoveItem: _removeItem,
          ),
        ),
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
          SizedBox(
            height: 300,
            child: ProductListPanel(
              items: _items,
              onIncrementItem: _incrementItem,
              onDecrementItem: _decrementItem,
              onRemoveItem: _removeItem,
            ),
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