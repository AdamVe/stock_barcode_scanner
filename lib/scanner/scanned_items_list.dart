import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stock_barcode_scanner/date_time_ext.dart';
import 'package:stock_barcode_scanner/scanner/scanner_buttons.dart';

import '../confirmation_dialog.dart';
import 'models.dart';

const _scannedItemListHeight = 250.0;

class _ScannedItemListError extends StatelessWidget {
  const _ScannedItemListError();

  @override
  Widget build(BuildContext context) => const Column(children: [
        ListTile(
          leading: Icon(Symbols.document_scanner),
          title: Text('Items'),
          subtitle: Text('Error loading data'),
        ),
        SizedBox(
          height: _scannedItemListHeight,
        )
      ]);
}

class _ScannedItemListLoading extends StatelessWidget {
  const _ScannedItemListLoading();

  @override
  Widget build(BuildContext context) => const Column(children: [
        ListTile(
          leading: Icon(Symbols.document_scanner),
          title: Text('Items'),
          subtitle: Text('Loading'),
        ),
        SizedBox(
          height: _scannedItemListHeight,
        )
      ]);
}

class ScannedItemList extends ConsumerWidget {
  final ValueNotifier<bool> soundController;
  final MobileScannerController scannerController;

  const ScannedItemList({
    required this.soundController,
    required this.scannerController,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(builder: (context) {
      final state = ref.watch(sectionControllerProvider);
      return state.when(
          error: (e, st) => const _ScannedItemListError(),
          loading: () => const _ScannedItemListLoading(),
          data: (scannedItems) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 8, 0),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //Text('${scannedItems.length} items'),
                          const Text('Section review and controls'),
                          const SizedBox(),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Icon(
                              Symbols.expand_more,
                            ),
                          ),
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 4, 16, 4),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer
                              .withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SoundButton(soundController),
                            const SizedBox(
                              width: 8,
                            ),
                            TorchButton(scannerController)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                    child:
                        Text('Section contains ${scannedItems.length} items:'),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: scannedItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          final scannedItem = scannedItems[index];
                          final count = scannedItem.count;
                          final theme = Theme.of(context);
                          return ListTile(
                            titleAlignment: ListTileTitleAlignment.titleHeight,
                            leading: Text(
                              '${scannedItems.length - index}.',
                              textAlign: TextAlign.center,
                            ),
                            title: Row(
                              children: [
                                const Icon(
                                  Symbols.barcode,
                                  size: 24,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                if (count > 1) Text('$count \u00d7 '),
                                Text(
                                  scannedItem.barcode,
                                  style: TextStyle(
                                      color: theme.colorScheme.primary),
                                )
                              ],
                            ),
                            trailing: IconButton.filledTonal(
                                onPressed: () async {
                                  await showConfirmationDialog(
                                      context,
                                      'Delete scan?',
                                      'This will remove the scan with the count. This action cannot be undone.',
                                      actions: [
                                        DialogAction('Cancel', () {}),
                                        DialogAction('Delete', () async {
                                          await ref
                                              .read(sectionControllerProvider
                                                  .notifier)
                                              .deleteScannedItem(scannedItem);
                                        })
                                      ],
                                      icon: const Icon(Symbols.delete_outline));
                                },
                                icon: const Icon(Symbols.delete)),
                            subtitle: Text(scannedItem.created.format()),
                          );
                        }),
                  ),
                ],
              ));
    });
  }
}
