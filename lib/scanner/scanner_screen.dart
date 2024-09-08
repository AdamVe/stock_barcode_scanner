import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stock_barcode_scanner/confirmation_dialog.dart';
import 'package:stock_barcode_scanner/date_time_ext.dart';
import 'package:stock_barcode_scanner/scanner/scanner_widget.dart';
import 'package:stock_barcode_scanner/scanner/scanner_widget_overlay.dart';
import 'package:stock_barcode_scanner/theme.dart';

import '../data/item_repository.dart';
import '../domain/models.dart';
import 'models.dart';

part 'scanner_screen.freezed.dart';
part 'scanner_screen.g.dart';

final _log = Logger('scanner');

const _scannedItemListHeight = 250.0;

@freezed
class ScanInfoData with _$ScanInfoData {
  const factory ScanInfoData({
    required bool duplicateReported,
    required String current,
    required String previous,
    required bool scannerActive,
  }) = __ScanInfoData;

  factory ScanInfoData.fromJson(Map<String, Object?> json) =>
      _$ScanInfoDataFromJson(json);
}

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
      barcode: '',
      created: DateTime.fromMillisecondsSinceEpoch(0),
      updated: DateTime.fromMillisecondsSinceEpoch(0),
      count: 0);

  void update(ScannedItem newValue) {
    state = newValue;
  }
}

@Riverpod(keepAlive: true)
AudioPlayer scanSound(ScanSoundRef ref) {
  final player = AudioPlayer()
    ..setSource(AssetSource('sounds/scan.wav'))
    ..setReleaseMode(ReleaseMode.stop);

  ref.onDispose(() {
    _log.fine('scanSoundProvider audio player disposed');
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
    _log.fine('duplicateSoundProvider audio player disposed');
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
    ref.invalidate(currentBarcodeProvider);
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
  double testV = 0;
  double widthFactor = 1.0;
  double op = 1.0;

  @override
  Widget build(BuildContext context) {
    final section = ref.read(currentSectionProvider);

    ref.listen(scannerEventsProvider, (_, current) {
      switch (current) {
        case NewCode c:
          {
            final createdUpdatedDate = DateTime.now();
            final newScannedItem = ScannedItem(
              barcode: c.code,
              created: createdUpdatedDate,
              updated: createdUpdatedDate,
            );

            setState(() {
              testV = 420;
              op = 0.3;
              widthFactor = 0.7;
            });

            ref
                .read(_controllerProvider.notifier)
                .addScannedItem(section.id, newScannedItem)
                .then((id) => ref
                    .read(currentBarcodeProvider.notifier)
                    .update(newScannedItem.copyWith(id: id)));
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
                      onDetect: (barcodeCapture) => ref
                          .read(scannedCodeProvider.notifier)
                          .onDetect(firstEan13(barcodeCapture)),
                    ),
                    AnimatedPositioned(
                      top: scanRect.top + testV,
                      left: scanRect.bottomCenter.dx -
                          (widthFactor * scanRect.width / 2),
                      width: widthFactor * scanRect.width,
                      height: scanRect.height,
                      duration: const Duration(milliseconds: 750),
                      curve: Curves.easeInBack,
                      onEnd: () {
                        _log.fine('Animation ended');
                      },
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 750),
                        opacity: op,
                        curve: Curves.easeInBack,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                            ref.read(scannedCodeProvider) ?? '',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
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

  String? firstEan13(BarcodeCapture capture) => capture.barcodes
      .where((element) => element.format == BarcodeFormat.ean13)
      .firstOrNull
      ?.rawValue!;

  String currentlyObserved = '';
  DateTime firstTimeSeen = DateTime(0);

  Rect _getScanRect(double width, double height) {
    final center = Offset(width / 2, 160);
    const scanWinHeight = 130.0;
    final scanWinWidth = width - 80;
    return Rect.fromCenter(
        center: center, width: scanWinWidth, height: scanWinHeight);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ref.read(scannedCodeProvider.notifier).dispose();
    super.dispose();
  }
}

class _AdjustScanCountWidget extends ConsumerWidget {
  const _AdjustScanCountWidget();

  void _update(WidgetRef ref, int amount) {
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
                        Symbols.remove,
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
                        Symbols.add,
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
                    leading: const Icon(Symbols.document_scanner),
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
                                    icon: const Icon(Symbols.delete_outline));
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
