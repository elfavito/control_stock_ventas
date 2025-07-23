// lib/services/sqlite_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import 'data_storage_service.dart';
import 'dart:convert'; // Para manejar SaleItem como JSON string

class SQLiteService implements IDataStorageService {
  static Database? _database; // Usamos un singleton para la base de datos

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'stock_app_sqlite.db'); // Nombre del archivo de la DB

    return await openDatabase(
      path,
      version: 1, // Versión de la base de datos
      onCreate: (db, version) async {
        // Tabla de Productos
        await db.execute('''
          CREATE TABLE products(
            id TEXT PRIMARY KEY,
            barcode TEXT UNIQUE,
            name TEXT,
            price REAL
          )
        ''');
        // Tabla de Ventas
        await db.execute('''
          CREATE TABLE sales(
            id TEXT PRIMARY KEY,
            saleDate TEXT,
            items TEXT, -- Guardaremos los SaleItem como una cadena JSON
            totalAmount REAL,
            receivedAmount REAL,
            changeAmount REAL
          )
        ''');
      },
    );
  }

  @override
  Future<void> init() async {
    // La inicialización se realiza la primera vez que se accede a 'database'
    await database; // Asegura que la DB se abra
    print('SQLite inicializado');
  }

  @override
  Future<void> saveProducts(List<Product> products) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('products'); // Borra todos los productos existentes
      for (var product in products) {
        await txn.insert(
          'products',
          product.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace, // Reemplaza si el ID ya existe
        );
      }
    });
    print('Productos guardados en SQLite');
  }

  @override
  Future<List<Product>> loadProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
  }

  @override
  Future<void> saveSales(List<Sale> sales) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('sales'); // Borra todas las ventas existentes
      for (var sale in sales) {
        // Convertimos la lista de SaleItem a una cadena JSON para guardarla en una sola columna
        final String itemsJsonString = jsonEncode(sale.items.map((item) => item.toJson()).toList());
        
        await txn.insert(
          'sales',
          {
            'id': sale.id,
            'saleDate': sale.saleDate.toIso8601String(),
            'items': itemsJsonString,
            'totalAmount': sale.totalAmount,
            'receivedAmount': sale.receivedAmount,
            'changeAmount': sale.changeAmount,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    print('Historial de ventas guardado en SQLite');
  }

  @override
  Future<List<Sale>> loadSales() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sales');
    return List.generate(maps.length, (i) {
      final saleMap = maps[i];
      // Convertimos la cadena JSON de items de vuelta a List<SaleItem>
      final List<dynamic> itemsJsonList = jsonDecode(saleMap['items'] as String);
      final List<SaleItem> items = itemsJsonList.map((itemJson) => SaleItem.fromJson(itemJson as Map<String, dynamic>)).toList();

      return Sale(
        id: saleMap['id'] as String,
        saleDate: DateTime.parse(saleMap['saleDate'] as String),
        items: items,
        totalAmount: saleMap['totalAmount'] as double,
        receivedAmount: saleMap['receivedAmount'] as double,
        changeAmount: saleMap['changeAmount'] as double,
      );
    });
  }
}