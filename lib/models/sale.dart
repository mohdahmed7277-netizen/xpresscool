class SaleItem {
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toMap(String saleId) {
    return {
      'saleId': saleId,
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }
}

class Sale {
  final String id;
  final String invoiceNumber;
  final DateTime date;
  final List<SaleItem> items;
  final String? customerName;
  final double discount; // flat amount
  final double taxPercent; // e.g. 5 for 5%

  Sale({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.items,
    this.customerName,
    this.discount = 0,
    this.taxPercent = 0,
  });

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.lineTotal);
  double get taxAmount => (subtotal - discount) * (taxPercent / 100);
  double get total => (subtotal - discount) + taxAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'date': date.toIso8601String(),
      'customerName': customerName,
      'discount': discount,
      'taxPercent': taxPercent,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map, List<SaleItem> items) {
    return Sale(
      id: map['id'] as String,
      invoiceNumber: map['invoiceNumber'] as String,
      date: DateTime.parse(map['date'] as String),
      items: items,
      customerName: map['customerName'] as String?,
      discount: (map['discount'] as num).toDouble(),
      taxPercent: (map['taxPercent'] as num).toDouble(),
    );
  }
}
