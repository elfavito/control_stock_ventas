// lib/services/shared_preferences_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/sale_model.dart';
import 'data_storage_service.dart';

class SharedPreferencesService implements IDataStorageService {
  late SharedPreferences _prefs;
  static const String _productsKey = 'products_data';
  static const String _salesHistoryKey = 'sales_history_data';

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveProducts(List<Product> products) async {
    final List<Map<String, dynamic>> productsJsonList = products.map((product) => product.toJson()).toList();
    await _prefs.setString(_productsKey, jsonEncode(productsJsonList));
    // ignore: avoid_print
    print('Productos guardados en SharedPreferences');
  }

  @override
  Future<List<Product>> loadProducts() async {
    final String? productsJsonString = _prefs.getString(_productsKey);
    if (productsJsonString != null) {
      final List<dynamic> productsJsonList = jsonDecode(productsJsonString) as List<dynamic>;
      return productsJsonList.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  @override
  Future<void> saveSales(List<Sale> sales) async {
    final List<Map<String, dynamic>> salesJsonList = sales.map((sale) => sale.toJson()).toList();
    await _prefs.setString(_salesHistoryKey, jsonEncode(salesJsonList));
    print('Historial de ventas guardado en SharedPreferences');
  }

  @override
  Future<List<Sale>> loadSales() async {
    final String? salesJsonString = _prefs.getString(_salesHistoryKey);
    if (salesJsonString != null) {
      final List<dynamic> salesJsonList = jsonDecode(salesJsonString) as List<dynamic>;
      return salesJsonList.map((json) => Sale.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }
}