import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/sale.dart';

class ExportService {
  /// Builds a CSV file (one row per line item, so it's easy to analyze in
  /// Excel/Google Sheets) and returns the saved file.
  static Future<File> exportSalesToCsv(List<Sale> sales) async {
    final dateFmt = DateFormat('yyyy-MM-dd HH:mm');

    List<List<dynamic>> rows = [
      [
        'Invoice #',
        'Date',
        'Customer',
        'Product',
        'Unit Price',
        'Quantity',
        'Line Total',
        'Discount',
        'Tax %',
        'Sale Total',
      ]
    ];

    for (final sale in sales) {
      for (final item in sale.items) {
        rows.add([
          sale.invoiceNumber,
          dateFmt.format(sale.date),
          sale.customerName ?? '',
          item.productName,
          item.unitPrice.toStringAsFixed(2),
          item.quantity,
          item.lineTotal.toStringAsFixed(2),
          sale.discount.toStringAsFixed(2),
          sale.taxPercent.toStringAsFixed(2),
          sale.total.toStringAsFixed(2),
        ]);
      }
    }

    final csvString = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'sales_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csvString);
    return file;
  }
}
