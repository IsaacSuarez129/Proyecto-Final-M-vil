import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pvm/core/constants/app_constants.dart';
import 'package:pvm/core/utils/formatters.dart';
import 'package:pvm/features/checkout/domain/entities/sale.dart';

class TicketPdfService {
  const TicketPdfService();

  Future<Uint8List> generateTicketPdf(Sale sale) async {
    final doc = pw.Document();
    final folioText = sale.folio.toString().padLeft(6, '0');

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                AppConstants.appName.toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Comprobante de Venta',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.8),
              _metaRow('Ticket:', '#$folioText'),
              _metaRow('Fecha:', Formatters.dateTime(sale.createdAt)),
              _metaRow('Atendió:', sale.cashierName),
              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.8),
              pw.SizedBox(height: 4),
              for (final item in sale.items) ...[
                pw.Text(
                  item.name,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '${item.quantity} x ${Formatters.currency(item.price)}',
                      style: const pw.TextStyle(fontSize: 8.5),
                    ),
                    pw.Text(
                      Formatters.currency(item.subtotal),
                      style: const pw.TextStyle(fontSize: 8.5),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
              ],
              pw.Divider(borderStyle: pw.BorderStyle.dashed, thickness: 0.8),
              pw.SizedBox(height: 4),
              _totalRow('TOTAL:', Formatters.currency(sale.total), bold: true),
              pw.SizedBox(height: 2),
              _totalRow('Efectivo:', Formatters.currency(sale.payment)),
              _totalRow('Cambio:', Formatters.currency(sale.change)),
              pw.SizedBox(height: 12),
              pw.Text(
                '¡Gracias por su compra!',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 9.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  pw.Widget _metaRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8.5)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 8.5)),
        ],
      ),
    );
  }

  pw.Widget _totalRow(String label, String value, {bool bold = false}) {
    final style = pw.TextStyle(
      fontSize: bold ? 11 : 9,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text(value, style: style),
      ],
    );
  }
}