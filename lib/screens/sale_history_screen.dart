import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sale_controller.dart';
import 'package:intl/intl.dart'; 

class SaleHistoryScreen extends StatelessWidget {
  SaleHistoryScreen({super.key});

  final SaleController saleController = Get.find<SaleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Obx(
        () {
          if (saleController.salesHistory.isEmpty) {
            return const Center(child: Text('No hay ventas registradas.'));
          }
          return ListView.builder(
            itemCount: saleController.salesHistory.length,
            itemBuilder: (context, index) {
              final sale = saleController.salesHistory[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile( // Permite expandir para ver detalles
                  title: Text('Venta #${index + 1} - ${DateFormat('dd/MM/yyyy HH:mm').format(sale.saleDate)}'),
                  subtitle: Text('Total: \$${sale.totalAmount.toStringAsFixed(2)} - Vuelto: \$${sale.changeAmount.toStringAsFixed(2)}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...sale.items.map((item) => Text(
                                '- ${item.productName} (x${item.quantity}) - \$${(item.priceAtSale * item.quantity).toStringAsFixed(2)}',
                              )),
                          const SizedBox(height: 8),
                          Text('Monto Recibido: \$${sale.receivedAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}