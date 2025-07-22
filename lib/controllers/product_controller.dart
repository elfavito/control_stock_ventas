import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'dart:convert'; // Importa para JSON encoding/decoding
import '../models/product_model.dart';
import 'package:uuid/uuid.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  final _uuid = const Uuid();
  static const String _productsKey = 'products_data'; // Clave para guardar en SharedPreferences

  @override
  void onInit() {
    super.onInit();
    _loadProducts(); // Cargar productos al inicializar el controlador
    // Si no hay productos después de cargar, entonces poblar con datos iniciales
    if (products.isEmpty) {
      _populateInitialProducts();
    }
    // Escuchar cualquier cambio en la lista de productos y guardarlos automáticamente
    ever(products, (_) => _saveProducts());
  }

  void _populateInitialProducts() {
    products.addAll([
      Product(id: _uuid.v4(), barcode: '7791234567890', name: 'Leche Entera', price: 1200.0),
      Product(id: _uuid.v4(), barcode: '7790987654321', name: 'Pan de Molde', price: 850.0),
      Product(id: _uuid.v4(), barcode: '7795555444433', name: 'Azúcar 1kg', price: 900.0),
      Product(id: _uuid.v4(), barcode: '7791111222233', name: 'Aceite Girasol', price: 2500.0),
    ]);
    _saveProducts(); // Guarda los productos iniciales
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? productsJsonString = prefs.getString(_productsKey);

    if (productsJsonString != null) {
      final List<dynamic> productsJsonList = jsonDecode(productsJsonString) as List<dynamic>;
      products.assignAll(productsJsonList.map((json) => Product.fromJson(json as Map<String, dynamic>)).toList());
    }
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    // Convertir la lista de productos a una lista de mapas JSON
    final List<Map<String, dynamic>> productsJsonList = products.map((product) => product.toJson()).toList();
    // Convertir la lista de mapas a una cadena JSON y guardarla
    await prefs.setString(_productsKey, jsonEncode(productsJsonList));
    print('Productos guardados en SharedPreferences'); 
  }

  void addProduct(String barcode, String name, double price) {
    if (barcode.isEmpty || name.isEmpty || price <= 0) {
      Get.snackbar('Error', 'Todos los campos son obligatorios y el precio debe ser positivo.');
      return;
    }
    if (products.any((p) => p.barcode == barcode)) {
      Get.snackbar('Error', 'Ya existe un producto con este código de barras.');
      return;
    }

    final newProduct = Product(
      id: _uuid.v4(),
      barcode: barcode,
      name: name,
      price: price,
    );
    products.add(newProduct);
    Get.snackbar('Éxito', 'Producto "$name" añadido.');
    // _saveProducts() se llama automáticamente por el `ever`
  }

  void updateProduct(String id, String newBarcode, String newName, double newPrice) {
    final index = products.indexWhere((p) => p.id == id);
    if (index != -1) {
      if (products.any((p) => p.barcode == newBarcode && p.id != id)) {
        Get.snackbar('Error', 'Ya existe otro producto con este código de barras.');
        return;
      }
      products[index] = products[index].copyWith(
        barcode: newBarcode,
        name: newName,
        price: newPrice,
      );
      Get.snackbar('Éxito', 'Producto "$newName" actualizado.');
      // _saveProducts() se llama automáticamente por el `ever`
    } else {
      Get.snackbar('Error', 'Producto no encontrado.');
    }
  }

  void deleteProduct(String id) {
    products.removeWhere((p) => p.id == id);
    Get.snackbar('Eliminado', 'Producto eliminado.');
    // _saveProducts() se llama automáticamente por el `ever`
  }

  Product? findProductByBarcode(String barcode) {
    return products.firstWhereOrNull((p) => p.barcode == barcode);
  }
}