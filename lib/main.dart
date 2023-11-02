import 'package:flutter/material.dart';

import 'db.dart';
import 'project_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbConnector.init();
  runApp(const StockBarcodeScannerApp());
}

class StockBarcodeScannerApp extends StatelessWidget {
  const StockBarcodeScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Colors.indigoAccent;
    return MaterialApp(
      title: 'Stock Barcode Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor, brightness: Brightness.light),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: seedColor, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const ProjectPage(),
    );
  }
}
