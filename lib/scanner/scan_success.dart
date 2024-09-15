import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../domain/models.dart';

class ScanSuccess extends StatelessWidget {
  final ScannedItem scannedItem;

  const ScanSuccess(this.scannedItem, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 64),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 16, 8, 16),
        child: Column(
          children: [
            ListTile(
                iconColor: Theme.of(context).colorScheme.primary,
                title: const Text('Successful scan'),
                subtitle: Text(scannedItem.barcode),
                leading: const Icon(
                  Symbols.check_rounded,
                  size: 36,
                  //color: Colors.green,
                )),
          ],
        ),
      ),
    );
  }
}
