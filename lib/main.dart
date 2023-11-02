import 'package:flutter/material.dart';
import 'package:stock_barcode_scanner/scanner_screen.dart';
import 'package:stock_barcode_scanner/sections_screen.dart';

import 'db.dart';
import 'projects_screen.dart';

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
      initialRoute: ProjectsScreen.routeName,
      routes: {
        ProjectsScreen.routeName: (context) => const ProjectsScreen(),
        SectionsScreen.routeName: (context) => const SectionsScreen(),
        ScannerScreen.routeName: (context) => const ScannerScreen()
      },
      home: const ProjectsScreen(),
    );
  }
}
