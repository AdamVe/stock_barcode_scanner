import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stock_barcode_scanner/date_time_ext.dart';
import 'package:stock_barcode_scanner/domain/models.dart';

import '../confirmation_dialog.dart';
import 'models.dart';
import 'scanner_buttons.dart';

class ReviewBottomSheet extends ConsumerWidget {
  final ValueNotifier<bool> soundController;
  final MobileScannerController controller;

  const ReviewBottomSheet(this.soundController, this.controller, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) {
        final state = ref.watch(sectionControllerProvider);
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 0.0, 8.0, 0),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                state.whenOrNull(
                      data: (scannedItems) => Expanded(
                        child: ListTile(
                          title: Row(
                            children: [
                              Text(
                                'Latest ',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const Icon(
                                Symbols.barcode,
                                size: 24,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              if (scannedItems[0].count > 1)
                                Text('${scannedItems[0].count} \u00d7 '),
                              Text(
                                scannedItems[0].barcode,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          subtitle: Text(
                              'Section contains ${scannedItems.length} items.'),
                        ),
                      ),
                    ) ??
                    const SizedBox(),
                _ExpandBottomSheetButton(onPressed: () async {
                  ref.read(scannerActiveProvider.notifier).state = false;
                  if (!context.mounted) {
                    return;
                  }
                  await showModalBottomSheet(
                      context: context,
                      isScrollControlled: false,
                      enableDrag: true,
                      isDismissible: true,
                      showDragHandle: false,
                      builder: (context) {
                        return _ReviewModalBottomSheet(
                          soundController: soundController,
                          scannerController: controller,
                        );
                      });
                  ref.read(scannerActiveProvider.notifier).state = true;
                }),
              ]),
        );
      },
    );
  }
}

class _ReviewModalBottomSheet extends ConsumerWidget {
  final ValueNotifier<bool> soundController;
  final MobileScannerController scannerController;

  const _ReviewModalBottomSheet({
    required this.soundController,
    required this.scannerController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(builder: (context) {
      final state = ref.watch(sectionControllerProvider);
      return state.whenOrNull(
              data: (scannedItems) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Header(),
                      _Controls(soundController, scannerController),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                        child: Text(
                            'Section contains ${scannedItems.length} items:'),
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: scannedItems.length,
                            itemBuilder: (BuildContext context, int index) {
                              final scannedItem = scannedItems[index];
                              const align = ListTileTitleAlignment.titleHeight;
                              final leading = '${scannedItems.length - index}.';

                              return ListTile(
                                title: _ScannedItemTitle(scannedItem),
                                subtitle: Text(scannedItem.created.format()),
                                titleAlignment: align,
                                leading: Text(leading),
                                trailing: _DeleteButton(scannedItem),
                              );
                            }),
                      ),
                    ],
                  )) ??
          const SizedBox();
    });
  }
}

class _ExpandBottomSheetButton extends ConsumerWidget {
  final Function() onPressed;

  const _ExpandBottomSheetButton({required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
        onPressed: onPressed,
        child: const Icon(
          Symbols.expand_less,
        ));
  }
}

class _DeleteButton extends ConsumerWidget {
  final ScannedItem scannedItem;

  const _DeleteButton(this.scannedItem);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
        onPressed: () async {
          await showConfirmationDialog(context, 'Delete scan?',
              'This will remove the scan with the count. This action cannot be undone.',
              actions: [
                DialogAction('Cancel', () {}),
                DialogAction('Delete', () async {
                  await ref
                      .read(sectionControllerProvider.notifier)
                      .deleteScannedItem(scannedItem);
                })
              ],
              icon: const Icon(Symbols.delete_outline));
        },
        icon: const Icon(Symbols.delete));
  }
}

class _ScannedItemTitle extends StatelessWidget {
  final ScannedItem scannedItem;

  const _ScannedItemTitle(this.scannedItem);

  @override
  Widget build(BuildContext context) {
    final count = scannedItem.count;
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        const Icon(Symbols.barcode, size: 24),
        const SizedBox(width: 6),
        if (count > 1) Text('$count \u00d7 '),
        Text(scannedItem.barcode, style: TextStyle(color: primaryColor))
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 8, 0),
      child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Section review and controls'),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Icon(
                Symbols.expand_more,
              ),
            ),
          ]),
    );
  }
}

class _Controls extends StatelessWidget {
  final ValueNotifier<bool> soundController;
  final MobileScannerController scannerController;

  const _Controls(this.soundController, this.scannerController);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
