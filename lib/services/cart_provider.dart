import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/sale.dart';

class CartLine {
  final Product product;
  int quantity;
  CartLine({required this.product, this.quantity = 1});
  double get lineTotal => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};

  List<CartLine> get lines => _lines.values.toList();
  bool get isEmpty => _lines.isEmpty;

  double get subtotal => _lines.values.fold(0.0, (sum, l) => sum + l.lineTotal);

  void addProduct(Product product, {int qty = 1}) {
    if (_lines.containsKey(product.id)) {
      _lines[product.id]!.quantity += qty;
    } else {
      _lines[product.id] = CartLine(product: product, quantity: qty);
    }
    notifyListeners();
  }

  void setQuantity(String productId, int qty) {
    if (qty <= 0) {
      _lines.remove(productId);
    } else if (_lines.containsKey(productId)) {
      _lines[productId]!.quantity = qty;
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _lines.remove(productId);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }

  List<SaleItem> toSaleItems() {
    return _lines.values
        .map((l) => SaleItem(
              productId: l.product.id,
              productName: l.product.name,
              unitPrice: l.product.price,
              quantity: l.quantity,
            ))
        .toList();
  }
}
