class Product {
  final String id; // used as QR code payload too
  final String name;
  final String sku;
  final double price;
  final double costPrice;
  final int stockQty;
  final int lowStockThreshold;
  final String? category;
  final String? barcode; // existing manufacturer barcode (EAN/UPC), optional
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.costPrice,
    required this.stockQty,
    this.lowStockThreshold = 5,
    this.category,
    this.barcode,
    required this.createdAt,
  });

  bool get isLowStock => stockQty <= lowStockThreshold;

  Product copyWith({
    String? name,
    String? sku,
    double? price,
    double? costPrice,
    int? stockQty,
    int? lowStockThreshold,
    String? category,
    String? barcode,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stockQty: stockQty ?? this.stockQty,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      category: category ?? this.category,
      barcode: barcode ?? this.barcode,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'price': price,
      'costPrice': costPrice,
      'stockQty': stockQty,
      'lowStockThreshold': lowStockThreshold,
      'category': category,
      'barcode': barcode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      sku: map['sku'] as String,
      price: (map['price'] as num).toDouble(),
      costPrice: (map['costPrice'] as num).toDouble(),
      stockQty: map['stockQty'] as int,
      lowStockThreshold: map['lowStockThreshold'] as int,
      category: map['category'] as String?,
      barcode: map['barcode'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
