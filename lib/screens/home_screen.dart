import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'product_list_screen.dart'; 
import 'sale_screen.dart'; 
import 'sale_history_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Stock - Menú Principal'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              height: 70,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Get.to(() => SaleScreen()),
                icon: const Icon(Icons.point_of_sale),
                label: const Text('Realizar Venta',
                    style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 70,
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => ProductListScreen()),
                icon: const Icon(Icons.category),
                label: const Text('Gestión de Productos',
                    style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 250,
              height: 70,
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => SaleHistoryScreen()),
                icon: const Icon(Icons.history),
                label: const Text('Historial de Ventas',
                    style: TextStyle(fontSize: 20)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
