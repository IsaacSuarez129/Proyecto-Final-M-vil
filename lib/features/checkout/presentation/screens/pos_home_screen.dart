import 'package:flutter/material.dart';
import 'package:pvm/core/constants/app_constants.dart';
import 'package:pvm/core/theme/app_theme.dart';
import 'package:pvm/core/utils/formatters.dart';
import 'package:pvm/core/utils/responsive.dart';
import 'package:pvm/features/auth/presentation/screens/cashiers_screen.dart';
import 'package:pvm/features/auth/presentation/widgets/profile_avatar.dart';
import 'package:pvm/features/cash_register/domain/entities/shift.dart';
import 'package:pvm/features/catalog/domain/entities/product.dart';
import 'package:pvm/features/catalog/presentation/widgets/catalog_dialog.dart';
import 'package:pvm/features/checkout/data/datasources/cart_local_datasource.dart';
import 'package:pvm/features/checkout/data/repositories/sale_repository.dart';
import 'package:pvm/features/checkout/domain/entities/cart_item.dart';
import 'package:pvm/features/checkout/domain/entities/pos_ticket.dart';
import 'package:pvm/features/checkout/domain/entities/sale.dart';
import 'package:pvm/features/checkout/presentation/widgets/action_buttons_panel.dart';
import 'package:pvm/features/checkout/presentation/widgets/payment_panel.dart';
import 'package:pvm/features/checkout/presentation/widgets/product_list_panel.dart';
import 'package:pvm/features/checkout/presentation/widgets/ticket_tabs_bar.dart';
import 'package:pvm/features/checkout/services/ticket_pdf_service.dart';
import 'package:pvm/shared/services/file_export_service.dart';
import 'package:uuid/uuid.dart';

class PosHomeScreen extends StatefulWidget {
  const PosHomeScreen({super.key, required this.shift});

  // Turno abierto: define quién atiende y con cuánto abrió.
  final Shift shift;

  @override
  State<PosHomeScreen> createState() => _PosHomeScreenState();
}

class _PosHomeScreenState extends State<PosHomeScreen> {
  final _localDatasource = const CartLocalDatasource();
  final _saleRepository = const SaleRepository();
  final _pdfService = const TicketPdfService();
  final _exportService = const FileExportService();
  final _uuid = const Uuid();

  late List<PosTicket> _tickets;
  int _activeIndex = 0;
  bool _isCharging = false;

  PosTicket get _currentTicket => _tickets[_activeIndex];

  @override
  void initState() {
    super.initState();
    _tickets = [PosTicket(id: _uuid.v4(), number: 1)];
    _restoreTickets();
  }

  Future<void> _restoreTickets() async {
    final saved = await _localDatasource.loadTickets(widget.shift.id);
    if (!mounted || saved == null) return;
    setState(() {
      _tickets = saved.tickets;
      _activeIndex = saved.activeIndex;
    });
  }

  void _persistTickets() {
    _localDatasource.saveTickets(
      shiftId: widget.shift.id,
      tickets: _tickets,
      activeIndex: _activeIndex,
    );
  }

  void _updateCurrentTicket(PosTicket updated) {
    setState(() {
      _tickets[_activeIndex] = updated;
    });
    _persistTickets();
  }

  // Busca el número libre más bajo entre 1 y 5 (ej. Ticket 1, Ticket 2...).
  int _nextAvailableTicketNumber() {
    final usedNumbers = _tickets.map((t) => t.number).toSet();
    for (var n = 1; n <= AppConstants.maxOpenTickets; n++) {
      if (!usedNumbers.contains(n)) return n;
    }
    return _tickets.length + 1;
  }

  void _createNewTicket() {
    if (_tickets.length >= AppConstants.maxOpenTickets) return;
    setState(() {
      _tickets.add(
        PosTicket(id: _uuid.v4(), number: _nextAvailableTicketNumber()),
      );
      _activeIndex = _tickets.length - 1;
    });
    _persistTickets();
  }

  void _selectTicket(int index) {
    if (index == _activeIndex) return;
    setState(() => _activeIndex = index);
    _persistTickets();
  }

  Future<void> _closeTicket(int index) async {
    final target = _tickets[index];

    if (target.items.isNotEmpty) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Eliminar Ticket ${target.number}'),
          content: Text(
            'Este ticket tiene ${target.totalItemsCount} producto(s). ¿Deseas eliminarlo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    _removeOrResetTicketAt(index);
  }

  // Quita un ticket por su id (no por posición), aunque la pestaña activa cambie.
  void _removeTicketById(String id) {
    final index = _tickets.indexWhere((t) => t.id == id);
    if (index != -1) _removeOrResetTicketAt(index);
  }

  void _removeOrResetTicketAt(int index) {
    setState(() {
      if (_tickets.length == 1) {
        _tickets[0] = PosTicket(id: _uuid.v4(), number: 1);
        _activeIndex = 0;
      } else {
        _tickets.removeAt(index);
        // Si se quitó una pestaña anterior a la activa, la activa se recorre.
        if (index < _activeIndex) {
          _activeIndex--;
        } else if (_activeIndex >= _tickets.length) {
          _activeIndex = _tickets.length - 1;
        }
      }
    });
    _persistTickets();
  }

  void _addProduct(Product product) {
    final items = List<CartItem>.from(_currentTicket.items);
    final index = items.indexWhere((item) => item.productId == product.id);
    if (index != -1) {
      final current = items[index];
      items[index] = current.copyWith(quantity: current.quantity + 1);
    } else {
      items.add(
        CartItem(
          productId: product.id,
          name: product.name,
          barcode: product.code,
          price: product.price,
        ),
      );
    }
    _updateCurrentTicket(_currentTicket.copyWith(items: items));
  }

  void _incrementItem(CartItem target) {
    final items = List<CartItem>.from(_currentTicket.items);
    final index = items.indexWhere(
      (item) => item.productId == target.productId,
    );
    if (index == -1) return;
    final current = items[index];
    items[index] = current.copyWith(quantity: current.quantity + 1);
    _updateCurrentTicket(_currentTicket.copyWith(items: items));
  }

  void _decrementItem(CartItem target) {
    final items = List<CartItem>.from(_currentTicket.items);
    final index = items.indexWhere(
      (item) => item.productId == target.productId,
    );
    if (index == -1) return;
    final current = items[index];
    if (current.quantity <= 1) {
      items.removeAt(index);
    } else {
      items[index] = current.copyWith(quantity: current.quantity - 1);
    }
    _updateCurrentTicket(_currentTicket.copyWith(items: items));
  }

  void _removeItem(CartItem target) {
    final items = _currentTicket.items
        .where((item) => item.productId != target.productId)
        .toList();
    _updateCurrentTicket(_currentTicket.copyWith(items: items));
  }

  void _onPaymentKey(String key) {
    if (_isCharging) return;
    var input = _currentTicket.paymentInput;

    if (key == 'backspace') {
      if (input.isNotEmpty) {
        input = input.substring(0, input.length - 1);
      }
    } else if (key == '.') {
      if (input.contains('.')) return;
      input = input.isEmpty ? '0.' : '$input.';
    } else {
      if (input.length >= 9) return;
      final dot = input.indexOf('.');
      if (dot != -1 && input.length - dot > 2) return;
      input = input == '0' ? key : '$input$key';
    }

    _updateCurrentTicket(_currentTicket.copyWith(paymentInput: input));
  }

  Future<void> _onCharge() async {
    if (_isCharging) return;
    final ticket = _currentTicket;

    if (ticket.items.isEmpty) {
      _showSnackBar('Agrega al menos un producto para cobrar.');
      return;
    }

    if (ticket.paymentCents < ticket.totalCents) {
      _showSnackBar('El pago recibido es menor al total.');
      return;
    }

    setState(() => _isCharging = true);

    try {
      final sale = await _saleRepository.registerSale(
        ticketId: ticket.id,
        shift: widget.shift,
        items: ticket.items,
        total: ticket.total,
        payment: ticket.payment,
        change: ticket.change,
      );

      if (!mounted) return;
      setState(() => _isCharging = false);

      // Se cierra el ticket que se cobró, por id.
      _removeTicketById(ticket.id);

      await _showSaleCompletedDialog(sale);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isCharging = false);
      _showSnackBar('No se pudo registrar la venta. Verifica tu conexión.');
    }
  }

  Future<void> _showSaleCompletedDialog(Sale sale) async {
    final shouldPrintPdf = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SaleCompletedDialog(sale: sale),
    );

    if (shouldPrintPdf == true) {
      await _generateAndExportTicket(sale);
    }
  }

  Future<void> _generateAndExportTicket(Sale sale) async {
    try {
      final bytes = await _pdfService.generateTicketPdf(sale);
      final folio = sale.folio.toString().padLeft(6, '0');
      await _exportService.saveAndSharePdf(
        bytes: bytes,
        fileName: 'ticket_$folio.pdf',
      );
    } catch (_) {
      _showSnackBar('No se pudo generar el ticket en PDF.');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<PosAction> _buildActions(BuildContext context) {
    return List.generate(6, (index) {
      if (index == 0 && widget.shift.profile.isAdmin) {
        return PosAction(
          label: 'Cajeros',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const CashiersScreen(),
            ),
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
    final ticket = _currentTicket;
    final actions = _buildActions(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // Mientras se registra la venta no se puede tocar nada (evita editar o
      // cambiar de ticket a la mitad del cobro).
      body: AbsorbPointer(
        absorbing: _isCharging,
        child: SafeArea(
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
                          ? _compactBody(responsive, ticket, actions)
                          : _expandedBody(responsive, ticket, actions),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _paymentPanel(PosTicket ticket) {
    return PaymentPanel(
      total: ticket.total,
      payment: ticket.payment,
      change: ticket.change,
      isCharging: _isCharging,
      onKeyPressed: _onPaymentKey,
      onCharge: _onCharge,
    );
  }

  Widget _ticketTabsBar() {
    return TicketTabsBar(
      tickets: _tickets,
      activeIndex: _activeIndex,
      onSelectTicket: _selectTicket,
      onAddTicket: _createNewTicket,
      onCloseTicket: _closeTicket,
    );
  }

  // Tablet / pantalla ancha: productos + pestañas de tickets a la izquierda.
  Widget _expandedBody(
    Responsive responsive,
    PosTicket ticket,
    List<PosAction> actions,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: ProductListPanel(
                  items: ticket.items,
                  onIncrementItem: _incrementItem,
                  onDecrementItem: _decrementItem,
                  onRemoveItem: _removeItem,
                ),
              ),
              const SizedBox(height: 10),
              _ticketTabsBar(),
            ],
          ),
        ),
        SizedBox(width: responsive.gap),
        SizedBox(
          width: responsive.actionPanelWidth,
          child: Column(
            children: [
              Expanded(flex: 2, child: ActionButtonsPanel(actions: actions)),
              SizedBox(height: responsive.gap),
              Expanded(flex: 5, child: _paymentPanel(ticket)),
            ],
          ),
        ),
      ],
    );
  }

  // Pantalla angosta: todo en una columna con scroll vertical.
  Widget _compactBody(
    Responsive responsive,
    PosTicket ticket,
    List<PosAction> actions,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 280,
            child: ProductListPanel(
              items: ticket.items,
              onIncrementItem: _incrementItem,
              onDecrementItem: _decrementItem,
              onRemoveItem: _removeItem,
            ),
          ),
          const SizedBox(height: 10),
          _ticketTabsBar(),
          SizedBox(height: responsive.gap),
          SizedBox(height: 160, child: ActionButtonsPanel(actions: actions)),
          SizedBox(height: responsive.gap),
          SizedBox(height: 460, child: _paymentPanel(ticket)),
        ],
      ),
    );
  }
}

class _ShiftHeader extends StatelessWidget {
  const _ShiftHeader({required this.shift});

  final Shift shift;

  @override
  Widget build(BuildContext context) {
    final profile = shift.profile;

    return Row(
      children: [
        ProfileAvatar(
          name: profile.name,
          avatarUrl: profile.avatarUrl,
          radius: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            profile.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _SaleCompletedDialog extends StatelessWidget {
  const _SaleCompletedDialog({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final folio = sale.folio.toString().padLeft(6, '0');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: PosColors.charge, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Venta cobrada (#$folio)',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _summaryRow('Total:', Formatters.currency(sale.total)),
          const SizedBox(height: 6),
          _summaryRow('Pagó:', Formatters.currency(sale.payment)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cambio:',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                Formatters.currency(sale.change),
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PosColors.changeText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '¿Deseas imprimir el ticket en PDF?',
            style: textTheme.bodyMedium?.copyWith(color: PosColors.fieldLabel),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No, continuar'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(true),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Imprimir PDF'),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          amount,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
