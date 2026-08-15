import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/product.dart';
import '../models/sale.dart';
import '../models/staff.dart';

class DBHelper {
  DBHelper._internal();
  static final DBHelper instance = DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'myshop_inventory.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            sku TEXT NOT NULL,
            price REAL NOT NULL,
            costPrice REAL NOT NULL,
            stockQty INTEGER NOT NULL,
            lowStockThreshold INTEGER NOT NULL,
            category TEXT,
            barcode TEXT,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE staff (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            username TEXT NOT NULL UNIQUE,
            pinHash TEXT NOT NULL,
            role TEXT NOT NULL,
            createdAt TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE sales (
            id TEXT PRIMARY KEY,
            invoiceNumber TEXT NOT NULL,
            date TEXT NOT NULL,
            customerName TEXT,
            discount REAL NOT NULL,
            taxPercent REAL NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE sale_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            saleId TEXT NOT NULL,
            productId TEXT NOT NULL,
            productName TEXT NOT NULL,
            unitPrice REAL NOT NULL,
            quantity INTEGER NOT NULL,
            FOREIGN KEY (saleId) REFERENCES sales (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE products ADD COLUMN barcode TEXT');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS staff (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              username TEXT NOT NULL UNIQUE,
              pinHash TEXT NOT NULL,
              role TEXT NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  // ---------- PRODUCTS ----------

  Future<void> insertProduct(Product p) async {
    final db = await database;
    await db.insert('products', p.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateProduct(Product p) async {
    final db = await database;
    await db.update('products', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final maps = await db.query('products', orderBy: 'name ASC');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final db = await database;
    final maps = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;
    final maps =
        await db.query('products', where: 'barcode = ?', whereArgs: [barcode]);
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  /// Looks up a product from a scanned code, checking generated-QR ids first
  /// (which store the product's internal id), then falling back to matching
  /// an existing manufacturer barcode (EAN/UPC) if one was saved.
  Future<Product?> getProductByScannedCode(String code) async {
    final byId = await getProductById(code);
    if (byId != null) return byId;
    return getProductByBarcode(code);
  }

  Future<void> adjustStock(String productId, int delta) async {
    final db = await database;
    final product = await getProductById(productId);
    if (product == null) return;
    final newQty = product.stockQty + delta;
    await db.update(
      'products',
      {'stockQty': newQty < 0 ? 0 : newQty},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // ---------- SALES ----------

  Future<void> insertSale(Sale sale) async {
    final db = await database;
    await db.insert('sales', sale.toMap());
    for (final item in sale.items) {
      await db.insert('sale_items', item.toMap(sale.id));
    }
    // Deduct stock for each item sold
    for (final item in sale.items) {
      await adjustStock(item.productId, -item.quantity);
    }
  }

  Future<List<Sale>> getAllSales() async {
    final db = await database;
    final saleMaps = await db.query('sales', orderBy: 'date DESC');
    List<Sale> sales = [];
    for (final sMap in saleMaps) {
      final itemMaps = await db.query('sale_items',
          where: 'saleId = ?', whereArgs: [sMap['id']]);
      final items = itemMaps.map((m) => SaleItem.fromMap(m)).toList();
      sales.add(Sale.fromMap(sMap, items));
    }
    return sales;
  }

  Future<int> getNextInvoiceNumber() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sales');
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count + 1;
  }

  // ---------- STAFF / LOGIN ----------

  Future<void> insertStaff(Staff staff) async {
    final db = await database;
    await db.insert('staff', staff.toMap());
  }

  Future<void> updateStaff(Staff staff) async {
    final db = await database;
    await db.update('staff', staff.toMap(), where: 'id = ?', whereArgs: [staff.id]);
  }

  Future<void> deleteStaff(String id) async {
    final db = await database;
    await db.delete('staff', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Staff>> getAllStaff() async {
    final db = await database;
    final maps = await db.query('staff', orderBy: 'createdAt ASC');
    return maps.map((m) => Staff.fromMap(m)).toList();
  }

  Future<bool> hasAnyStaff() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM staff');
    return (Sqflite.firstIntValue(result) ?? 0) > 0;
  }

  Future<Staff?> getStaffByUsername(String username) async {
    final db = await database;
    final maps =
        await db.query('staff', where: 'username = ?', whereArgs: [username]);
    if (maps.isEmpty) return null;
    return Staff.fromMap(maps.first);
  }
}
