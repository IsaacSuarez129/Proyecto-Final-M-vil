import 'package:flutter/material.dart';
import 'package:pvm/core/constants/app_constants.dart';
import 'package:pvm/core/theme/app_theme.dart';
import 'package:pvm/features/checkout/domain/entities/pos_ticket.dart';

class TicketTabsBar extends StatelessWidget {
  const TicketTabsBar({
    super.key,
    required this.tickets,
    required this.activeIndex,
    required this.onSelectTicket,
    required this.onAddTicket,
    required this.onCloseTicket,
  });

  final List<PosTicket> tickets;
  final int activeIndex;
  final ValueChanged<int> onSelectTicket;
  final VoidCallback onAddTicket;
  final ValueChanged<int> onCloseTicket;

  bool get _canAddMore => tickets.length < AppConstants.maxOpenTickets;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 46,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: tickets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                final isSelected = index == activeIndex;
                final count = ticket.totalItemsCount;

                return _TicketTabChip(
                  label: count > 0
                      ? 'Ticket ${ticket.number} ($count)'
                      : 'Ticket ${ticket.number}',
                  isSelected: isSelected,
                  onTap: () => onSelectTicket(index),
                  onClose: () => onCloseTicket(index),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: _canAddMore
                ? 'Nuevo ticket (${tickets.length}/${AppConstants.maxOpenTickets})'
                : 'Máximo ${AppConstants.maxOpenTickets} tickets abiertos',
            child: Material(
              color: _canAddMore ? scheme.primary : Colors.white54,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _canAddMore ? onAddTicket : null,
                child: SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.add,
                    color: _canAddMore ? scheme.onPrimary : PosColors.fieldLabel,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketTabChip extends StatelessWidget {
  const _TicketTabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.onClose,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? scheme.primaryContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? scheme.primary : PosColors.keyBorder,
          width: isSelected ? 1.8 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 14, right: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 18,
                color: isSelected ? scheme.primary : PosColors.fieldLabel,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? scheme.onPrimaryContainer : PosColors.totalText,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: isSelected
                        ? scheme.onPrimaryContainer
                        : PosColors.fieldLabel,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}