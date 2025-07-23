import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:uuid/uuid.dart';
import '../services/data_storage_service.dart'; // Importa la interfaz

class ProductController extends GetxController {
  var products = <Product>[].obs;
  final _uuid = const Uuid();

  // Dependencia de la interfaz, NO de una implementación concreta
  late final IDataStorageService _storageService;

  // Constructor que recibe la dependencia
  ProductController({required IDataStorageService storageService})
      : _storageService = storageService;

  @override
  void onInit() {
    super.onInit();
    _loadProducts();
    if (products.isEmpty) {
      _populateInitialProducts();
    }
   
    ever(products, (_) => _saveProducts());
  }

  void _populateInitialProducts() {
    // ... tu lógica de productos iniciales
    products.addAll([
      Product(
          id: _uuid.v4(),
          barcode: '7791234567890',
          name: 'Leche Entera',
          price: 1200.0),
      Product(
          id: _uuid.v4(),
          barcode: '7790987654321',
          name: 'Pan de Molde',
          price: 850.0),
      Product(
          id: _uuid.v4(),
          barcode: '7795555444433',
          name: 'Azúcar 1kg',
          price: 900.0),
      Product(
          id: _uuid.v4(),
          barcode: '7791111222233',
          name: 'Aceite Girasol',
          price: 2500.0),
    ]);
    _saveProducts(); // Guarda estos iniciales
  }

  // Los métodos de carga y guardado ahora usan el data_storage
  Future<void> _loadProducts() async {
    final loadedProducts = await _storageService.loadProducts();
    products.assignAll(loadedProducts);
  }

  Future<void> _saveProducts() async {
    await _storageService.saveProducts(products.toList());
  }

  void addProduct(String barcode, String name, double price) {
    if (barcode.isEmpty || name.isEmpty || price <= 0) {
      Get.snackbar('Error',
          'Todos los campos son obligatorios y el precio debe ser positivo.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (products.any((p) => p.barcode == barcode)) {
      Get.snackbar('Error', 'Ya existe un producto con este código de barras.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final newProduct = Product(
      id: _uuid.v4(),
      barcode: barcode,
      name: name,
      price: price,
    );
    products.add(newProduct);
    Get.snackbar('Éxito', 'Producto "${name}" añadido.',
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  void updateProduct(
      String id, String newBarcode, String newName, double newPrice) {
    final index = products.indexWhere((p) => p.id == id);
    if (index != -1) {
      if (products.any((p) => p.barcode == newBarcode && p.id != id)) {
        Get.snackbar(
            'Error', 'Ya existe otro producto con este código de barras.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      products[index] = products[index].copyWith(
        barcode: newBarcode,
        name: newName,
        price: newPrice,
      );
      Get.snackbar('Éxito', 'Producto "${newName}" actualizado.',
          backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar('Error', 'Producto no encontrado.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
    Get.snackbar('Eliminado', 'Producto eliminado.',
        backgroundColor: Colors.orange, colorText: Colors.white);
  }

  Product? findProductByBarcode(String barcode) {
    return products.firstWhereOrNull((p) => p.barcode == barcode);
  }
}
