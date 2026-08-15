import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/sale.dart';
import '../services/invoice_service.dart';
import '../services/locale_provider.dart';

class InvoicePreviewScreen extends StatefulWidget {
  final Sale sale;
  const InvoicePreviewScreen({super.key, required this.sale});

  @override
  State<InvoicePreviewScreen> createState() => _InvoicePreviewScreenState();
}

class _InvoicePreviewScreenState extends State<InvoicePreviewScreen> {
  bool _loading = true;
  String? _pdfPath;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    final file = await InvoiceService.generateInvoice(widget.sale,
        businessName: 'My Shop', businessContact: '');
    setState(() {
      _pdfPath = file.path;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sale.invoiceNumber),
        actions: [
          if (_pdfPath != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => Share.shareXFiles([XFile(_pdfPath!)]),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.green.shade50,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(context.tr('sale_completed')),
                    ],
                  ),
                ),
                Expanded(
                  child: PdfPreview(
                    build: (format) => InvoiceService.generateInvoice(widget.sale)
                        .then((f) => f.readAsBytes()),
                    allowSharing: true,
                    allowPrinting: true,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.home),
        label: Text(context.tr('done')),
        onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
      ),
    );
  }
}
