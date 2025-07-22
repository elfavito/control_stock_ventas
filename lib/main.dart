import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyecto_control_stock/screens/home_screen.dart'; // Importa la nueva HomeScreen
import 'package:proyecto_control_stock/controllers/product_controller.dart'; // Asegúrate de inyectarlos
import 'package:proyecto_control_stock/controllers/sale_controller.dart';

void main() {
  Get.put(ProductController());
  Get.put(SaleController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Control de Stock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Color principal del tema
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo, // AppBar global
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(), 
    );
  }
}
