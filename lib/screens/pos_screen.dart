import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../db/db_helper.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../services/cart_provider.dart';
import '../services/locale_provider.dart';
import 'scan_screen.dart';
import 'invoice_preview_screen.dart';

class POSScreen extends StatefulWidget {
  final bool startWithScanner;
  const POSScreen({super.key, this.startWithScanner = false});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  List<Product> _allProducts = [];
  final _customerController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _taxController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _loadProducts().then((_) {
      if (widget.startWithScanner) _scan();
    });
  }

  Future<void> _loadProducts() async {
    final products = await DBHelper.instance.getAllProducts();
    setState(() => _allProducts = products);
  }

  Future<void> _scan() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (result == null) return;

    final product = await DBHelper.instance.getProductByScannedCode(result);
    if (!mounted) return;

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('no_product_for_code'))),
      );
      return;
    }
    if (product.stockQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} ${context.tr('out_of_stock')}')),
      );
      return;
    }
    context.read<CartProvider>().addProduct(product);
  }

  void _showAddProductPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          builder: (ctx, scrollController) {
            return ListView.builder(
              controller: scrollController,
              itemCount: _allProducts.length,
              itemBuilder: (ctx, i) {
                final p = _allProducts[i];
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text('${context.tr('stock')}: ${p.stockQty} • \$${p.price.toStringAsFixed(2)}'),
                  enabled: p.stockQty > 0,
                  onTap: () {
                    context.read<CartProvider>().addProduct(p);
                    Navigator.pop(ctx);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _checkout() async {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    final invoiceNum = await DBHelper.instance.getNextInvoiceNumber();
    final sale = Sale(
      id: const Uuid().v4(),
      invoiceNumber: 'INV-${invoiceNum.toString().padLeft(4, '0')}',
      date: DateTime.now(),
      items: cart.toSaleItems(),
      customerName: _customerController.text.trim().isEmpty
          ? null
          : _customerController.text.trim(),
      discount: double.tryParse(_discountController.text) ?? 0,
      taxPercent: double.tryParse(_taxController.text) ?? 0,
    );

    await DBHelper.instance.insertSale(sale);
    cart.clear();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => InvoicePreviewScreen(sale: sale)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('new_sale')),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: _scan),
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddProductPicker),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Text(context.tr('cart_empty'), textAlign: TextAlign.center))
                : ListView(
                    children: cart.lines.map((line) {
                      return ListTile(
                        title: Text(line.product.name),
                        subtitle: Text('\$${line.product.price.toStringAsFixed(2)}'),
                        leading: IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => context
                              .read<CartProvider>()
                              .setQuantity(line.product.id, line.quantity - 1),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('x${line.quantity}',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Text('\$${line.lineTotal.toStringAsFixed(2)}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => context
                                  .read<CartProvider>()
                                  .setQuantity(line.product.id, line.quantity + 1),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          if (!cart.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _customerController,
                    decoration: InputDecoration(labelText: context.tr('customer_optional')),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _discountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: context.tr('discount')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _taxController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: context.tr('tax_percent')),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('${context.tr('subtotal')}: \$${cart.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.receipt),
                    label: Text(context.tr('complete_sale')),
                    onPressed: _checkout,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
