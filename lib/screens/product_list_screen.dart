import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../models/product_model.dart';

class ProductListScreen extends StatelessWidget {
  ProductListScreen({super.key});

  final ProductController productController = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Obx(
        () {
          if (productController.products.isEmpty) {
            return const Center(
              child: Text('No hay productos registrados.'),
            );
          }
          return ListView.builder(
            itemCount: productController.products.length,
            itemBuilder: (context, index) {
              final product = productController.products[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText('Nombre: ${product.name}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      SelectableText('Código: ${product.barcode}'),
                      SelectableText(
                          'Precio: \$${product.price.toStringAsFixed(2)}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showProductFormDialog(context,
                                product: product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                productController.deleteProduct(product.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductFormDialog(context),
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showProductFormDialog(BuildContext context, {Product? product}) {
    final isEditing = product != null;
    final barcodeController = TextEditingController(text: product?.barcode);
    final nameController = TextEditingController(text: product?.name);
    final priceController =
        TextEditingController(text: product?.price.toString());

    Get.dialog(
      AlertDialog(
        title: Text(isEditing ? 'Editar Producto' : 'Añadir Producto'),
        content: SingleChildScrollView(
          // Para evitar desbordamiento si el teclado es grande
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: barcodeController,
                decoration:
                    const InputDecoration(labelText: 'Código de Barras'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(labelText: 'Nombre del Producto'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number, // Para números decimales
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final barcode = barcodeController.text.trim();
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim());

              if (price == null) {
                Get.snackbar('Error', 'El precio debe ser un número válido.');
                return;
              }

              if (isEditing) {
                productController.updateProduct(
                    product.id, barcode, name, price);
              } else {
                productController.addProduct(barcode, name, price);
              }
              Get.back();
            },
            child: Text(isEditing ? 'Guardar Cambios' : 'Añadir'),
          ),
        ],
      ),
    );
  }
}
