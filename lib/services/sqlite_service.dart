


import 'package:path/path.dart'; //para manejar rutas de archivos
import '../models/product_model.dart';
import '../models/sale_model.dart';
import 'data_storage_service.dart';
import 'dart:convert'; 
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // para escritorio (Windows, Linux, macOS)
import 'package:flutter/foundation.dart'; // Para kDebugMode
import 'dart:io'; // Necesario para Platform.isWindows y Directory


class SQLiteService implements IDataStorageService {
  static Database? _database; //probando static, de todas formas no es necesaria

  
  // Si no se proporciona una ruta, usará la predeterminada de GetDatabasesPath()
  final String? customDatabasePath;

  
  // constructor con un argumento para la ruta personalizada.
  SQLiteService({this.customDatabasePath}); // Constructor para inyección, puede recibir una ruta opcional

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
    }

    final DatabaseFactory databaseFactory = databaseFactoryFfi; // Usa la factoría FFI para escritorio

    String finalDbPath;

    if (customDatabasePath != null && customDatabasePath!.isNotEmpty) {
      // Si se proporcionó una ruta personalizada, úsala
      finalDbPath = customDatabasePath!;
      if (kDebugMode) {
        print('Usando ruta de DB personalizada: $finalDbPath');
      }
    } else {
      // Si no se proporcionó una ruta personalizada, usa la ruta por defecto de sqflite
      final databasesPath = await getDatabasesPath();
      finalDbPath = join(databasesPath, 'stock_app_sqlite.db');
      if (kDebugMode) {
        print('Usando ruta de DB por defecto: $finalDbPath');
      }
    }

    // Asegurarse de que el directorio padre de la base de datos exista
    // Esto es crucial para rutas personalizadas, ya que sqflite no crea directorios padre.
    final directory = Directory(dirname(finalDbPath));
    if (!await directory.exists()) {
      await directory.create(recursive: true);
      if (kDebugMode) {
        print('Directorio de DB creado: ${directory.path}');
      }
    }

    return await databaseFactory.openDatabase(
      finalDbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate, 
      ),
    );
  }



  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        barcode TEXT UNIQUE,
        name TEXT,
        price REAL
      )
    ''');
    await db.execute('''
      CREATE TABLE sales(
        id TEXT PRIMARY KEY,
        saleDate TEXT,
        totalAmount REAL,
        receivedAmount REAL,
        changeAmount REAL,
        items TEXT
      )
    ''');
    if (kDebugMode) {
      print('Tablas de DB creadas.');
    }
  }

  
  @override
  Future<void> init() async {
    await database;
  }

  @override
  Future<void> saveProducts(List<Product> products) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('products');
      for (var product in products) {
        await txn.insert(
          'products',
          product.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    if (kDebugMode) {
      print('Productos guardados en SQLite.');
    }
  }

  @override
  Future<List<Product>> loadProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products'); //el query es un "SElECT", cada map es una fila, key nombre de la columna, value la celda
    final products = List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
    if (kDebugMode) {
      print('Productos cargados de SQLite: ${products.length} ítems.');
    }
    return products;
  }

  @override
  Future<void> saveSales(List<Sale> sales) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('sales');
      for (var sale in sales) {
        final saleMap = sale.toJson();
        saleMap['items'] = jsonEncode(sale.items.map((item) => item.toJson()).toList()); //formato que la base de datos puede guardar en una sola columna de tipo TEXT
        await txn.insert(
          'sales',
          saleMap,
          conflictAlgorithm: ConflictAlgorithm.replace, //Si ya existe una fila con este ID, bórrala y reemplázala con la nueva fila que estoy intentando insertar.
        );
      }
    });
    if (kDebugMode) {
      print('Ventas guardadas en SQLite.');
    }
  }

  @override
  Future<List<Sale>> loadSales() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sales');
    final sales = List.generate(maps.length, (i) {
      final saleMap = Map<String, dynamic>.from(maps[i]); //crea una copia de un mapa existente
      final List<dynamic> itemsJson = jsonDecode(saleMap['items']); //toma la cadena de texto y la convierte en la estructura de datos más básica y genérica de Dart
      saleMap['items'] = itemsJson.map((item) => SaleItem.fromJson(item)).toList();//tomo la lista de items json y la convierto a lista de objeto Items
      return Sale.fromJson(saleMap);
    });
    if (kDebugMode) {
      print('Ventas cargadas de SQLite: ${sales.length} ítems.');
    }
    return sales;
  }
}