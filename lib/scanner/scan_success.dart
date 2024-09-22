import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../domain/models.dart';

class ScanSuccess extends StatelessWidget {
  final ScannedItem scannedItem;

  const ScanSuccess(this.scannedItem, {super.key});

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
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
                    //color: Colors.green,
                  )),
            ],
          ),
        );
      },
      // margin: const EdgeInsets.fromLTRB(8, 0, 8, 80),
      // child: ,
    );
  }
}
