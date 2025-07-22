// lib/screens/sale_screen.dart (Actualizado)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sale_controller.dart';

class SaleScreen extends StatelessWidget {
  SaleScreen({super.key});


  final SaleController saleController = Get.find<SaleController>();
  final TextEditingController barcodeInputController = TextEditingController();
  final TextEditingController receivedAmountController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
   ever(saleController.receivedAmount, (double value) {
      if (receivedAmountController.text != value.toStringAsFixed(2) && value == 0.0) {
        // Solo actualiza si el valor es 0 para evitar loops o sobreescritura constante
        // y si el texto actual no es ya "0.00"
        receivedAmountController.text = value.toStringAsFixed(2);
      } else if (value != 0.0 && receivedAmountController.text == "0.00") {
        // Si el usuario empieza a escribir, no fuerza a 0.00
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal de Venta'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => saleController.resetSale(), 
            tooltip: 'Nueva Venta',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Sección de entrada de Código de Barras
            TextField(
              controller: barcodeInputController,
              decoration: InputDecoration(
                labelText: 'Código de Barras / Producto',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () {
                    saleController
                        .addProductToSale(barcodeInputController.text.trim());
                    barcodeInputController
                        .clear(); // Limpiar el campo después de añadir
                  },
                ),
              ),
              keyboardType:
                  TextInputType.number, // Para facilitar la entrada de números
              onSubmitted: (value) {
                // Añadir al presionar Enter/Done en el teclado
                saleController.addProductToSale(value.trim());
                barcodeInputController.clear();
              },
            ),
            const SizedBox(height: 10),

           
            Expanded(
              child: Obx(
                () {
                  if (saleController.currentSaleItems.isEmpty) {
                    return const Center(
                        child: Text('No hay productos en esta venta.'));
                  }
                  return ListView.builder(
                    itemCount: saleController.currentSaleItems.length,
                    itemBuilder: (context, index) {
                      final item = saleController.currentSaleItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          title:
                              Text('${item.productName} (x${item.quantity})'),
                          subtitle: Text(
                              'Cód: ${item.productBarcode} - Precio Unit: \$${item.priceAtSale.toStringAsFixed(2)}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Para que el Row no ocupe todo el ancho
                            children: [
                              Text(
                                  '\$${(item.priceAtSale * item.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () =>
                                    saleController.removeItemFromSale(item
                                        .productBarcode), // Reduce cantidad o elimina
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Sección de Cálculos: TOTAL, RECIBIDO, VUELTO
            Container(
              padding: const EdgeInsets.all(12.0),
              color: Colors.grey[200], 
              child: Column(
                children: [
                  _buildCalculationRow(
                      'TOTAL', saleController.totalAmount, Colors.black),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                          child: Text('RECIBIDO',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blue))),
                      Expanded(
                        child: TextField(
                          controller: receivedAmountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blue),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true, // Reduce el espacio vertical
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 8.0), // Ajusta el padding
                          ),
                          onChanged: (value) =>
                              saleController.setReceivedAmount(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildCalculationRow(
                      'VUELTO', saleController.changeAmount, Colors.purple),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Botones OK y Cancelar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => saleController.processSale(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('OK - Procesar Venta'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => saleController
                        .resetSale(), // Puedes re-usar resetSale para "Cancelar"
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _buildCalculationRow(
      String label, RxDouble observableValue, Color color) {
    return Obx(
      // Ahora este Obx tiene una variable observable para escuchar
      () => Row(
        children: [
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color))),
          // Lee el .value DIRECTAMENTE dentro del Obx
          Text('\$${observableValue.value.toStringAsFixed(2)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ],
      ),
    );
  }
}
