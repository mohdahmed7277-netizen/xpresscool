import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';

class InvoiceService {
  static final currencyFmt = NumberFormat.currency(symbol: '\$');

  /// Builds a PDF invoice for the given sale and returns the saved file.
  static Future<File> generateInvoice(Sale sale,
      {String businessName = 'My Shop',
      String businessContact = ''}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(businessName,
                          style: pw.TextStyle(
                              fontSize: 22, fontWeight: pw.FontWeight.bold)),
                      if (businessContact.isNotEmpty)
                        pw.Text(businessContact,
                            style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('#${sale.invoiceNumber}'),
                      pw.Text(DateFormat('yyyy-MM-dd HH:mm').format(sale.date)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              if (sale.customerName != null && sale.customerName!.isNotEmpty)
                pw.Text('Bill To: ${sale.customerName}'),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(4),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      _cell('Item', bold: true),
                      _cell('Qty', bold: true),
                      _cell('Unit Price', bold: true),
                      _cell('Total', bold: true),
                    ],
                  ),
                  ...sale.items.map((item) => pw.TableRow(children: [
                        _cell(item.productName),
                        _cell(item.quantity.toString()),
                        _cell(currencyFmt.format(item.unitPrice)),
                        _cell(currencyFmt.format(item.lineTotal)),
                      ])),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Subtotal: ${currencyFmt.format(sale.subtotal)}'),
                    if (sale.discount > 0)
                      pw.Text('Discount: -${currencyFmt.format(sale.discount)}'),
                    if (sale.taxPercent > 0)
                      pw.Text(
                          'Tax (${sale.taxPercent}%): ${currencyFmt.format(sale.taxAmount)}'),
                    pw.SizedBox(height: 6),
                    pw.Text('TOTAL: ${currencyFmt.format(sale.total)}',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.BarcodeWidget(
                      data: sale.id,
                      barcode: pw.Barcode.qrCode(),
                      width: 90,
                      height: 90,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Scan to verify invoice',
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/invoice_${sale.invoiceNumber}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: 10)),
    );
  }
}
