import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_barcode_scanner/data/item_repository.dart';
import 'package:stock_barcode_scanner/scanner/scanner_screen.dart';
import 'package:stock_barcode_scanner/section/sections_screen.dart';
import 'package:stock_barcode_scanner/data/sqlite_item_repository.dart';

import 'data/db.dart';
import 'project/projects_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbConnector.init();
  runApp(ProviderScope(
    overrides: [
      itemRepositoryProvider.overrideWith((ref) => SqliteItemRepository())
    ],
    child: const StockBarcodeScannerApp(),
  ));
}

class StockBarcodeScannerApp extends StatelessWidget {
  const StockBarcodeScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color.fromARGB(255, 17, 111, 7);
    return MaterialApp(
      title: 'Stock Barcode Scanner',
      debugShowCheckedModeBanner: false,
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
      initialRoute: SectionsScreen.routeName,
      routes: {
        SectionsScreen.routeName: (context) => const SectionsScreen(),
        ProjectsScreen.routeName: (context) => const ProjectsScreen(),
        ScannerScreen.routeName: (context) => const ScannerScreen()
      },
    );
  }
}
