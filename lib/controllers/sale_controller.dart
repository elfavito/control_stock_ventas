import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/sale_model.dart';
import 'product_controller.dart';
import 'package:uuid/uuid.dart';
import '../services/data_storage_service.dart'; // Importa la interfaz


class SaleController extends GetxController {
  final ProductController productController = Get.find<ProductController>();
  final _uuid = const Uuid();

  late final IDataStorageService _storageService;

  SaleController({required IDataStorageService storageService})
      : _storageService = storageService;

  var currentSaleItems = <SaleItem>[].obs;
  var totalAmount = 0.0.obs;
  var receivedAmount = 0.0.obs;
  var changeAmount = 0.0.obs;

  var salesHistory = <Sale>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSalesHistory();
    ever(currentSaleItems, (_) => _calculateTotal());
    // No necesitamos un ever para salesHistory porque solo se guarda en processSale
  }

  // Los métodos de carga y guardado ahora usan la interfaz
  Future<void> _loadSalesHistory() async {
    final loadedSales = await _storageService.loadSales();
    salesHistory.assignAll(loadedSales);
  }

  Future<void> _saveSalesHistory() async {
    await _storageService.saveSales(salesHistory.toList());
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
    _saveSalesHistory(); // Guarda la nueva venta
    resetSale();
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
    Get.snackbar('Eliminado', 'Producto ${barcode} eliminado de la venta.', backgroundColor: Colors.red, colorText: Colors.white);
  }
}