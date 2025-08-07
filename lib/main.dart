// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: unused_import
import 'package:proyecto_control_stock/services/shared_preferences.dart';
import 'services/sqlite_service.dart';
import 'screens/home_screen.dart';
import 'controllers/product_controller.dart';
import 'controllers/sale_controller.dart';
import '../services/data_storage_service.dart';

import 'package:path/path.dart';
import 'dart:io'; // Necesario para Directory.current

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync<IDataStorageService>(() async {
    IDataStorageService service;

    // --- ELIGE TU SERVICIO DE ALMACENAMIENTO AQUÍ ---

    // Opción 1: Usar SQLiteService
    final String currentDir = Directory.current.path;
    final String databasePath = join(currentDir, 'database');
    final Directory databaseDir = Directory(databasePath);

    if (!await databaseDir.exists()) {
      await databaseDir.create(recursive: true);
    }
    final String finalDbPath = join(databasePath, 'proyecto_control_stock.db');
    service = SQLiteService(customDatabasePath: finalDbPath);
    // ------------------------------------------------------------------
    // Opción 2:
    //  service = SharedPreferencesService();
    await service.init(); // Inicializa el servicio seleccionado
    return service; // Devuelve la instancia inicializada a GetX
  }, permanent: true);
  Get.put(ProductController(storageService: Get.find<IDataStorageService>()));
  Get.put(SaleController(storageService: Get.find<IDataStorageService>()));
//todo: buscar beneficios del get.page y el lazy-loading
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      color: Colors.amber,
      debugShowCheckedModeBanner: false,
      title: 'Stock Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}
