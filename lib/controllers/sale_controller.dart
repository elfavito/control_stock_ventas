import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'dart:convert'; 
import '../models/sale_model.dart';
import 'product_controller.dart';
import 'package:uuid/uuid.dart';

class SaleController extends GetxController {
  final ProductController productController = Get.find<ProductController>();
  final _uuid = const Uuid();
  static const String _salesHistoryKey = 'sales_history_data'; // Clave para guardar ventas

  // Estado de la venta actual
  var currentSaleItems = <SaleItem>[].obs;
  var totalAmount = 0.0.obs;
  var receivedAmount = 0.0.obs;
  var changeAmount = 0.0.obs;

  // Historial de ventas
  var salesHistory = <Sale>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSalesHistory(); // Carga historial de ventas al inicializar
    ever(currentSaleItems, (_) => _calculateTotal());
  }

  Future<void> _loadSalesHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? salesJsonString = prefs.getString(_salesHistoryKey);

    if (salesJsonString != null) {
      final List<dynamic> salesJsonList = jsonDecode(salesJsonString) as List<dynamic>;
      salesHistory.assignAll(salesJsonList.map((json) => Sale.fromJson(json as Map<String, dynamic>)).toList());
    }
  }

  Future<void> _saveSalesHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> salesJsonList = salesHistory.map((sale) => sale.toJson()).toList();
    await prefs.setString(_salesHistoryKey, jsonEncode(salesJsonList));
    print('Historial de ventas guardado en SharedPreferences'); // Para depuración
  }

  void addProductToSale(String barcode) {
    final product = productController.findProductByBarcode(barcode);
    if (product == null) {
      Get.snackbar('Error', 'Producto no encontrado.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final existingItemIndex = currentSaleItems.indexWhere((item) => item.productBarcode == barcode);

    if (existingItemIndex != -1) {
      final existingItem = currentSaleItems[existingItemIndex];
      currentSaleItems[existingItemIndex] = existingItem.copyWith(quantity: existingItem.quantity + 1);
    } else {
      currentSaleItems.add(SaleItem(
        productId: product.id,
        productName: product.name,
        productBarcode: product.barcode,
        priceAtSale: product.price,
        quantity: 1,
      ));
    }
    Get.snackbar('Éxito', '${product.name} añadido a la venta.', backgroundColor: Colors.green, colorText: Colors.white);
  }

  void _calculateTotal() {
    totalAmount.value = currentSaleItems.fold(0.0, (sum, item) => sum + (item.priceAtSale * item.quantity));
    _calculateChange();
  }

  void setReceivedAmount(String amount) {
    receivedAmount.value = double.tryParse(amount) ?? 0.0;
    _calculateChange();
  }

  void _calculateChange() {
    changeAmount.value = receivedAmount.value - totalAmount.value;
  }

  void processSale() {
    if (currentSaleItems.isEmpty) {
      Get.snackbar('Error', 'No hay ítems en la venta.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (receivedAmount.value < totalAmount.value) {
      Get.snackbar('Error', 'El monto recibido es insuficiente.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final newSale = Sale(
      id: _uuid.v4(),
      saleDate: DateTime.now(),
      items: List.from(currentSaleItems),
      totalAmount: totalAmount.value,
      receivedAmount: receivedAmount.value,
      changeAmount: changeAmount.value,
    );

    salesHistory.add(newSale);
    _saveSalesHistory(); // Guardar el historial después de añadir una venta
    resetSale(); // Limpiar la venta actual
    Get.snackbar('Venta Exitosa', 'Venta registrada con éxito.', backgroundColor: Colors.green, colorText: Colors.white);
  }

  void resetSale() {
    currentSaleItems.clear();
    totalAmount.value = 0.0;
    receivedAmount.value = 0.0;
    changeAmount.value = 0.0;
  }

  void removeItemFromSale(String barcode) {
    final index = currentSaleItems.indexWhere((item) => item.productBarcode == barcode);
    if (index != -1) {
      final item = currentSaleItems[index];
      if (item.quantity > 1) {
        currentSaleItems[index] = item.copyWith(quantity: item.quantity - 1);
      } else {
        currentSaleItems.removeAt(index);
      }
      Get.snackbar('Actualizado', '${item.productName} cantidad ajustada.', backgroundColor: Colors.orange, colorText: Colors.white);
    } else {
      Get.snackbar('Error', 'Producto no en la venta.', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void deleteSaleItemCompletely(String barcode) {
    currentSaleItems.removeWhere((item) => item.productBarcode == barcode);
    Get.snackbar('Eliminado', 'Producto $barcode eliminado de la venta.', backgroundColor: Colors.red, colorText: Colors.white);
  }
}