import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stock_barcode_scanner/theme.dart';

import '../domain/models.dart';

class ScanSuccess extends ConsumerWidget {
  final ScannedItem scannedItem;

  const ScanSuccess(this.scannedItem, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: ref.watch(themeDataProvider(Brightness.dark)),
      child: BottomSheet(
        onClosing: () {},
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(8, 24, 8, 24),
            child: Column(
              children: [
                ListTile(
                    iconColor: Theme.of(context).colorScheme.primary,
                    title: Text(scannedItem.barcode,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary)),
                    subtitle: const Text('Scanned successfully'),
                    leading: const Icon(
                      Symbols.barcode,
                      size: 48,
                    )),
              ],
            ),
          );
        },
        // margin: const EdgeInsets.fromLTRB(8, 0, 8, 80),
        // child: ,
      ),
    );
  }
}
