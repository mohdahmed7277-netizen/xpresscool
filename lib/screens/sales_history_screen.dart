import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../db/db_helper.dart';
import '../models/sale.dart';
import '../services/export_service.dart';
import '../services/locale_provider.dart';
import 'invoice_preview_screen.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  List<Sale> _sales = [];
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sales = await DBHelper.instance.getAllSales();
    setState(() => _sales = sales);
  }

  Future<void> _exportCsv() async {
    if (_sales.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.tr('no_sales_export'))));
      return;
    }
    setState(() => _exporting = true);
    final file = await ExportService.exportSalesToCsv(_sales);
    setState(() => _exporting = false);
    await Share.shareXFiles([XFile(file.path)],
        text: 'Sales export — ${_sales.length} sale(s)');
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d, yyyy • h:mm a');
    final totalRevenue = _sales.fold(0.0, (sum, s) => sum + s.total);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('sales_history')),
        actions: [
          IconButton(
            icon: _exporting
                ? const SizedBox(
                    height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.ios_share),
            tooltip: context.tr('export_csv'),
            onPressed: _exporting ? null : _exportCsv,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              children: [
                Text('${context.tr('total_sales')}: ${_sales.length}'),
                Text('${context.tr('total_revenue')}: \$${totalRevenue.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: _sales.isEmpty
                ? Center(child: Text(context.tr('no_sales_yet')))
                : ListView.builder(
                    itemCount: _sales.length,
                    itemBuilder: (context, i) {
                      final s = _sales[i];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.receipt)),
                        title: Text('${s.invoiceNumber} — \$${s.total.toStringAsFixed(2)}'),
                        subtitle: Text(
                            '${dateFmt.format(s.date)}${s.customerName != null ? " • ${s.customerName}" : ""}\n${s.items.length} item(s)'),
                        isThreeLine: true,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => InvoicePreviewScreen(sale: s))),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
