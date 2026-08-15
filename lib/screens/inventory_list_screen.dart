import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/product.dart';
import '../services/locale_provider.dart';
import 'add_edit_product_screen.dart';
import 'product_qr_screen.dart';

class InventoryListScreen extends StatefulWidget {
  const InventoryListScreen({super.key});

  @override
  State<InventoryListScreen> createState() => _InventoryListScreenState();
}

class _InventoryListScreenState extends State<InventoryListScreen> {
  List<Product> _products = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final products = await DBHelper.instance.getAllProducts();
    setState(() => _products = products);
  }

  List<Product> get _filtered {
    if (_query.isEmpty) return _products;
    final q = _query.toLowerCase();
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('inventory'))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: context.tr('search_hint'),
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Text(context.tr('no_products')))
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final p = _filtered[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              p.isLowStock ? Colors.red.shade100 : Colors.green.shade100,
                          child: Icon(Icons.inventory,
                              color: p.isLowStock ? Colors.red : Colors.green),
                        ),
                        title: Text(p.name),
                        subtitle: Text(
                            '${context.tr('sku')}: ${p.sku} • ${context.tr('stock')}: ${p.stockQty}${p.isLowStock ? "  ⚠ ${context.tr('low')}" : ""}'),
                        trailing: Text('\$${p.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => AddEditProductScreen(product: p)),
                          );
                          _load();
                        },
                        onLongPress: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ProductQrScreen(product: p)),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(context.tr('add_product')),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
          );
          _load();
        },
      ),
    );
  }
}
