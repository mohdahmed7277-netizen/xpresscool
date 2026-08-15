import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/db_helper.dart';
import '../models/product.dart';
import '../services/locale_provider.dart';
import 'product_qr_screen.dart';
import 'scan_screen.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _sku;
  late TextEditingController _price;
  late TextEditingController _cost;
  late TextEditingController _stock;
  late TextEditingController _lowStock;
  late TextEditingController _category;
  late TextEditingController _barcode;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _sku = TextEditingController(text: p?.sku ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _cost = TextEditingController(text: p?.costPrice.toString() ?? '');
    _stock = TextEditingController(text: p?.stockQty.toString() ?? '');
    _lowStock = TextEditingController(text: p?.lowStockThreshold.toString() ?? '5');
    _category = TextEditingController(text: p?.category ?? '');
    _barcode = TextEditingController(text: p?.barcode ?? '');
  }

  Future<void> _scanExistingBarcode() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (result != null) {
      setState(() => _barcode.text = result);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final product = Product(
      id: widget.product?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      sku: _sku.text.trim(),
      price: double.parse(_price.text),
      costPrice: double.parse(_cost.text.isEmpty ? '0' : _cost.text),
      stockQty: int.parse(_stock.text),
      lowStockThreshold: int.parse(_lowStock.text.isEmpty ? '5' : _lowStock.text),
      category: _category.text.trim().isEmpty ? null : _category.text.trim(),
      barcode: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
      createdAt: widget.product?.createdAt ?? DateTime.now(),
    );

    if (isEditing) {
      await DBHelper.instance.updateProduct(product);
    } else {
      await DBHelper.instance.insertProduct(product);
    }

    if (mounted) {
      if (!isEditing) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProductQrScreen(product: product)),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.tr('delete_product_title')),
        content: Text('"${widget.product!.name}"'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.tr('cancel'))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.tr('delete'), style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await DBHelper.instance.deleteProduct(widget.product!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? context.tr('edit_product') : context.tr('add_product')),
        actions: [
          if (isEditing)
            IconButton(icon: const Icon(Icons.qr_code), onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ProductQrScreen(product: widget.product!)));
            }),
          if (isEditing)
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: context.tr('product_name')),
              validator: (v) => (v == null || v.trim().isEmpty) ? context.tr('required') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sku,
              decoration: InputDecoration(labelText: context.tr('sku')),
              validator: (v) => (v == null || v.trim().isEmpty) ? context.tr('required') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _category,
              decoration: InputDecoration(labelText: context.tr('category_optional')),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _barcode,
              decoration: InputDecoration(
                labelText: context.tr('existing_barcode'),
                helperText: context.tr('barcode_helper'),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  onPressed: _scanExistingBarcode,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: context.tr('sale_price')),
                    validator: (v) =>
                        (v == null || double.tryParse(v) == null) ? context.tr('invalid') : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cost,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: context.tr('cost_price')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stock,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: context.tr('stock_qty')),
                    validator: (v) =>
                        (v == null || int.tryParse(v) == null) ? context.tr('invalid') : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lowStock,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: context.tr('low_stock_at')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: Text(isEditing ? context.tr('save_changes') : context.tr('add_generate_qr')),
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
