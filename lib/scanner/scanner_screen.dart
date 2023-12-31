import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stock_barcode_scanner/confirmation_dialog.dart';
import 'package:stock_barcode_scanner/date_time_ext.dart';
import 'package:stock_barcode_scanner/scanner/scanner_widget.dart';
import 'package:stock_barcode_scanner/scanner/scanner_widget_overlay.dart';
import 'package:stock_barcode_scanner/theme.dart';

import '../data/item_repository.dart';
import '../domain/models.dart';

part 'scanner_screen.g.dart';

const _scannedItemListHeight = 250.0;

@Riverpod(keepAlive: true)
class CurrentSection extends _$CurrentSection {
  @override
  Section build() => Section(
      id: 0,
      name: '',
      details: '',
      operatorName: '',
      created: DateTime(0),
      items: []);

  void update(Section section) {
    state = section;
  }
}

@Riverpod(keepAlive: true)
class CurrentBarcode extends _$CurrentBarcode {
  @override
  ScannedItem build() => ScannedItem(
      id: 0,
      barcode: '',
      created: DateTime.fromMillisecondsSinceEpoch(0),
      updated: DateTime.fromMillisecondsSinceEpoch(0),
      count: 0);

  void update(ScannedItem newValue) {
    state = newValue;
  }
}

@Riverpod(keepAlive: true)
class DetectedBarcode extends _$DetectedBarcode {
  @override
  String build() => '';

  void update(String newValue) {
    state = newValue;
  }
}

@Riverpod(keepAlive: true)
class LastSeenBarcode extends _$LastSeenBarcode {
  @override
  String build() => '';

  void update(String newValue) {
    state = newValue;
  }
}

@Riverpod(keepAlive: true)
class Duplicate extends _$Duplicate {
  @override
  bool build() => false;

  void update(bool newValue) {
    state = newValue;
  }
}

@Riverpod(keepAlive: true)
AudioPlayer scanSound(ScanSoundRef ref) {
  final player = AudioPlayer()
    ..setSource(AssetSource('sounds/scan.wav'))
    ..setReleaseMode(ReleaseMode.stop);

  ref.onDispose(() {
    if (kDebugMode) {
      print('scanSoundProvider audio player disposed');
    }
    player.dispose();
  });

  return player;
}

@Riverpod(keepAlive: true)
AudioPlayer duplicateSound(DuplicateSoundRef ref) {
  final player = AudioPlayer()
    ..setSource(AssetSource('sounds/duplicate.wav'))
    ..setReleaseMode(ReleaseMode.stop);

  ref.onDispose(() {
    if (kDebugMode) {
      print('duplicateSoundProvider audio player disposed');
    }
    player.dispose();
  });
  return player;
}

@riverpod
class _Controller extends _$Controller {
  Future<List<ScannedItem>> _read() async {
    final sectionId =
        ref.watch(currentSectionProvider.select((section) => section.id));
    return ref.watch(itemRepositoryProvider
        .select((repository) => repository.getScans(sectionId: sectionId)));
  }

  @override
  FutureOr<List<ScannedItem>> build() {
    ref.invalidate(duplicateProvider);
    ref.invalidate(currentBarcodeProvider);
    ref.invalidate(detectedBarcodeProvider);
    ref.invalidate(lastSeenBarcodeProvider);
    return _read();
  }

  Future<void> updateScannedItem(ScannedItem scannedItem) async {
    await ref
        .read(itemRepositoryProvider)
        .updateScan(scannedItemId: scannedItem.id, scan: scannedItem);
    await loadScannedItems();
  }

  Future<int> addScannedItem(int sectionId, ScannedItem scannedItem) async {
    int id = await ref
        .read(itemRepositoryProvider)
        .addScan(sectionId: sectionId, scan: scannedItem);
    await loadScannedItems();
    return id;
  }

  Future<void> deleteScannedItem(ScannedItem scannedItem) async {
    await ref.read(itemRepositoryProvider).deleteScan(scan: scannedItem);
    await loadScannedItems();
  }

  Future<void> loadScannedItems() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _read());
  }
}

class ScannerScreen extends ConsumerStatefulWidget {
  static const routeName = '/scanner';

  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    final scanSound = ref.watch(scanSoundProvider);
    final section = ref.watch(currentSectionProvider);

    ref.listen(detectedBarcodeProvider, (previous, next) async {
      if (next.isEmpty) {
        if (kDebugMode) {
          print('No barcode detected');
        }
        return;
      }

      if (next != ref.watch(lastSeenBarcodeProvider)) {
        if (kDebugMode) {
          print('Found new barcode: $next');
        }

        HapticFeedback.mediumImpact();
        scanSound.resume();

        final createdUpdatedDate = DateTime.now();

        final newScannedItem = ScannedItem(
          id: 0,
          barcode: next,
          created: createdUpdatedDate,
          updated: createdUpdatedDate,
          count: 1,
        );

        ref
            .read(_controllerProvider.notifier)
            .addScannedItem(section.id, newScannedItem)
            .then((id) => ref
                .read(currentBarcodeProvider.notifier)
                .update(newScannedItem.copyWith(id: id)));
      } else {
        if (previous?.isEmpty ?? true) {
          if (kDebugMode) {
            print('Notifying duplicate scan');
          }
          ref.read(duplicateProvider.notifier).update(true);
        }
        if (kDebugMode) {
          print('See old barcode: $next');
        }
      }
    });

    return Theme(
      data: ref.read(themeDataProvider(Brightness.dark)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Section: ${section.name}'),
          forceMaterialTransparency: true,
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  final scanRect =
                      _getScanRect(constraints.maxWidth, constraints.maxHeight);
                  return Stack(children: [
                    ScannerWidget(
                      overlay: ScannerWidgetOverlay(scanWindow: scanRect),
                      onDetect: (capture) async {
                        final currentBarcode = capture.barcodes
                                .where((element) =>
                                    element.format == BarcodeFormat.ean13)
                                .firstOrNull
                                ?.rawValue! ??
                            '';

                        if (kDebugMode) {
                          print('Detected barcode: $currentBarcode');
                        }

                        if (currentBarcode.isNotEmpty) {
                          _timer?.cancel();

                          ref
                              .read(detectedBarcodeProvider.notifier)
                              .update(currentBarcode);

                          ref
                              .read(lastSeenBarcodeProvider.notifier)
                              .update(currentBarcode);

                          // start timer to clear the code if not detected
                          _timer = Timer(const Duration(milliseconds: 750), () {
                            if (kDebugMode) {
                              print('clearing detected barcode');
                            }

                            ref
                                .read(detectedBarcodeProvider.notifier)
                                .update('');
                          });
                        }
                      },
                    ),
                    const _AdjustScanCountWidget(),
                  ]);
                }),
              ),
              const _ScannedItemList(),
            ],
          ),
        ),
      ),
    );
  }

  Rect _getScanRect(double width, double height) {
    final center = Offset(width / 2, 160);
    const scanWinHeight = 130.0;
    final scanWinWidth = width - 80;
    return Rect.fromCenter(
        center: center, width: scanWinWidth, height: scanWinHeight);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class _AdjustScanCountWidget extends ConsumerWidget {
  const _AdjustScanCountWidget();

  void _update(WidgetRef ref, int amount) {
    // final sectionId =
    //     ref.watch(currentSectionProvider.select((section) => section.id));
    final currentBarcode = ref.watch(currentBarcodeProvider);
    final updatedScannedItem = currentBarcode.copyWith(
      updated: DateTime.now(),
      count: currentBarcode.count + amount,
    );
    HapticFeedback.mediumImpact();
    ref
        .read(_controllerProvider.notifier)
        .updateScannedItem(updatedScannedItem);

    ref.read(currentBarcodeProvider.notifier).update(updatedScannedItem);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBarcode = ref.watch(currentBarcodeProvider);
    return PositionedDirectional(
        start: 0,
        end: 0,
        bottom: 30,
        child: Column(
          children: [
            Text(
              currentBarcode.barcode,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (currentBarcode.barcode.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: currentBarcode.count > 1
                          ? () => _update(ref, -1)
                          : null,
                      child: const Icon(
                        Icons.remove,
                        size: 32,
                      )),
                  SizedBox(
                      width: 64,
                      child: Text(
                        currentBarcode.count.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      )),
                  ElevatedButton(
                      onPressed: currentBarcode.count < 1000
                          ? () => _update(ref, 1)
                          : null,
                      child: const Icon(
                        Icons.add,
                        size: 32,
                      )),
                ],
              ),
          ],
        ));
  }
}

class _ScannedItemListError extends StatelessWidget {
  const _ScannedItemListError();

  @override
  Widget build(BuildContext context) => const Column(children: [
        ListTile(
          leading: Icon(Icons.document_scanner_outlined),
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
          leading: Icon(Icons.document_scanner_outlined),
          title: Text('Items'),
          subtitle: Text('Loading'),
        ),
        SizedBox(
          height: _scannedItemListHeight,
        )
      ]);
}

class _ScannedItemList extends ConsumerWidget {
  const _ScannedItemList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(builder: (context) {
      final state = ref.watch(_controllerProvider);
      return state.when(
          error: (e, st) => const _ScannedItemListError(),
          loading: () => const _ScannedItemListLoading(),
          data: (scannedItems) => Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.document_scanner_outlined),
                    title: Text('${scannedItems.length} items'),
                  ),
                  SizedBox(
                    height: _scannedItemListHeight,
                    child: ListView.builder(
                        itemCount: scannedItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          final scannedItem = scannedItems[index];
                          final count = scannedItem.count;
                          final sum = scannedItems
                              .where((i) => i.barcode == scannedItem.barcode)
                              .fold(
                                  0,
                                  (previousValue, i) =>
                                      previousValue + i.count);
                          final textTheme = Theme.of(context).textTheme;
                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: () async {
                                await showConfirmationDialog(
                                    context,
                                    'Delete scan?',
                                    'This will remove the scan with the count. This action cannot be undone.',
                                    actions: [
                                      DialogAction('Cancel', () {}),
                                      DialogAction('Delete', () async {
                                        await ref
                                            .read(_controllerProvider.notifier)
                                            .deleteScannedItem(scannedItem);
                                      })
                                    ],
                                    icon: const Icon(
                                        Icons.delete_outline_outlined));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Builder(builder: (context) {
                                      return FittedBox(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('$count \u00d7 ',
                                                  style: textTheme.bodyLarge
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              Text(scannedItem.barcode,
                                                  style:
                                                      textTheme.displayMedium),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Scanned: ',
                                            style: textTheme.bodyLarge
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        Text(scannedItem.created.format()),
                                        const SizedBox(
                                          width: 32,
                                        ),
                                        Text('Sum: ',
                                            style: textTheme.bodyLarge
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        Text('$sum'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ));
    });
  }
}
