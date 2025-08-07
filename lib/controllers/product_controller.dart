import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:uuid/uuid.dart';
import '../services/data_storage_service.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs;
  final _uuid = const Uuid();

  // Dependencia de la interfaz, NO de una implementación concreta
  //instancia de la clase abstracta
  late final IDataStorageService _storageService; //declaracion de una variable

  // Constructor que recibe la dependencia
  ProductController({required IDataStorageService storageService}) {
    //obliga a que el controlador reciba su dependencia al ser creado
    _storageService = storageService;
  }

  @override
  void onInit() {
    super.onInit();
    // Primero, carga los productos y ESPERA a que la operación termine.
    _loadProducts().then((_) {
      //asegura que el código dentro del bloque solo se ejecute después de que los productos se hayan cargado
      // DESPUÉS de cargar, comprueba si la lista está vacía.
      if (products.isEmpty) {
        _populateInitialProducts();
      }
    });

    // evita tener que llamar a _saveProducts() manualmente en cada método (addProduct, deleteProduct)
    ever(products, (_) => _saveProducts());
  }

  void _populateInitialProducts() {
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
    _saveProducts();
  }

  // Los métodos de carga y guardado ahora usan el data_storage
  Future<void> _loadProducts() async {
    final loadedProducts = await _storageService.loadProducts();
    products.assignAll(loadedProducts);
  }

  Future<void> _saveProducts() async {
    await _storageService.saveProducts(products.toList());
  }

  // Estado para controlar si se está procesando una adición
  var isAddingProduct = false.obs;

  Future<void> addProduct(String barcode, String name, double price) async {
    // Prevenir que se pulse el botón varias veces rápidamente
    if (isAddingProduct.value) return;

    try {
      isAddingProduct.value = true;

      if (barcode.isEmpty || name.isEmpty || price <= 0) {
        Get.snackbar('Error',
            'Todos los campos son obligatorios y el precio debe ser positivo.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      // La validación de código de barras duplicado ya existía y es correcta
      if (products.any((p) => p.barcode == barcode)) {
        Get.snackbar(
            'Error', 'Ya existe un producto con este código de barras.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      //si queremos usarlo en la UI obliga a crear un nuevo mecanismo para que el controlador pueda comunicarse con la pantalla.

      final newProduct = Product(
        id: _uuid.v4(),
        barcode: barcode,
        name: name,
        price: price,
      );
      products.add(newProduct);

      // Cierra el diálogo
      Get.back();

      // Pequeña pausa para asegurar que la navegación se complete
      await Future.delayed(const Duration(milliseconds: 50));

      // Muestra la confirmación en la pantalla a la que hemos vuelto
      Get.snackbar('Éxito', 'Producto "$name" añadido.',
          backgroundColor: Colors.green, colorText: Colors.white);
    } finally {
      // Asegura que el estado de carga se restablezca siempre
      isAddingProduct.value = false;
    }
  }

  void updateProduct(
      //Al reemplazar el objeto completo en la lista, te aseguras de que el sistema reactivo de Getx (.obs) detecte el cambio.
      String id,
      String newBarcode,
      String newName,
      double newPrice) {
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
      Get.snackbar('Éxito', 'Producto "$newName" actualizado.',
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
