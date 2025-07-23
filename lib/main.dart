// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/sqlite_service.dart';
import 'screens/home_screen.dart';
import '../models/sale_model.dart';
import 'controllers/product_controller.dart';
import 'controllers/sale_controller.dart';
import '../services/data_storage_service.dart'; // Importa el nuevo servicio SQLite

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegura la inicialización de plugins

  // --- PUNTO DE DECISIÓN CLAVE ---
  // Descomenta la línea que deseas usar para la persistencia de datos
  // y comenta la otra.

  // Opcion 1: Usar SharedPreferences
  // IDataStorageService storageService = SharedPreferencesService();

  // Opcion 2: Usar SQLite
  IDataStorageService storageService = SQLiteService();
  // ------------------------------

  await storageService
      .init(); // Inicializa el servicio de almacenamiento elegido

  // Inyecta los controladores, pasándoles la instancia del servicio de almacenamiento
  Get.put(ProductController(storageService: storageService));
  Get.put(SaleController(storageService: storageService));

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
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
