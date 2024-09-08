import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:stock_barcode_scanner/theme.dart';

import 'data/db.dart';
import 'data/item_repository.dart';
import 'data/sqlite_item_repository.dart';
import 'project/project_screen.dart';
import 'project_manager/project_manager_screen.dart';
import 'scanner/scanner_screen.dart';

void main() async {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();
  await DbConnector.init();
  runApp(ProviderScope(
    overrides: [
      itemRepositoryProvider.overrideWith((ref) => SqliteItemRepository())
    ],
    child: const StockBarcodeScannerApp(),
  ));
}

class StockBarcodeScannerApp extends ConsumerWidget {
  const StockBarcodeScannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Stock Barcode Scanner',
      debugShowCheckedModeBanner: false,
      theme: ref.read(themeDataProvider(Brightness.light)),
      darkTheme: ref.read(themeDataProvider(Brightness.dark)),
      initialRoute: ProjectScreen.routeName,
      routes: {
        ProjectScreen.routeName: (context) => const ProjectScreen(),
        ProjectManagerScreen.routeName: (context) =>
            const ProjectManagerScreen(),
        ScannerScreen.routeName: (context) => const ScannerScreen()
      },
    );
  }
}
