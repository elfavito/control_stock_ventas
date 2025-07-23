// lib/services/data_storage_service.dart
import '../models/product_model.dart';
import '../models/sale_model.dart';

abstract class IDataStorageService {
  Future<void> init();
  Future<void> saveProducts(List<Product> products);
  Future<List<Product>> loadProducts();
  Future<void> saveSales(List<Sale> sales);
  Future<List<Sale>> loadSales();
}