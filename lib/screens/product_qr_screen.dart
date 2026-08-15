import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/product.dart';
import '../services/locale_provider.dart';

class ProductQrScreen extends StatelessWidget {
  final Product product;
  const ProductQrScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('product_qr_title'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              margin: const EdgeInsets.all(24),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    QrImageView(
                      data: product.id,
                      version: QrVersions.auto,
                      size: 220,
                    ),
                    const SizedBox(height: 16),
                    Text(product.name,
                        style:
                            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('${context.tr('sku')}: ${product.sku}'),
                    Text('\$${product.price.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                context.tr('qr_instructions'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.home),
              label: Text(context.tr('done')),
              onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            ),
          ],
        ),
      ),
    );
  }
}
