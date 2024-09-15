import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/item_repository.dart';
import '../domain/models.dart';
import '../theme.dart';
import 'models.dart';
import 'scan_duplicate.dart';
import 'scan_success.dart';
import 'scanner_overlay.dart';
import 'scanner_widget.dart';
import 'scanner_widget_overlay.dart';

part 'scanner_screen.g.dart';

final _log = Logger('scanner');

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

  Future<ScannedItem?> getLatest(int sectionId) async {
    // TODO: optimize this
    final allScans =
        await ref.read(itemRepositoryProvider).getScans(sectionId: sectionId);
    return allScans.firstOrNull;
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

final successOverlayProvider = StateProvider<ScannerOverlay?>((ref) => null);
final duplicateOverlayProvider = StateProvider<ScannerOverlay?>((ref) => null);
final canPopProvider = StateProvider<bool>((ref) =>
    ref.watch(successOverlayProvider) == null &&
    ref.watch(duplicateOverlayProvider) == null);

class ScannerScreen extends ConsumerStatefulWidget {
  static const routeName = '/scanner';

  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  ScannerOverlay? get successOverlay => ref.watch(successOverlayProvider);

  set successOverlay(ScannerOverlay? overlay) =>
      ref.read(successOverlayProvider.notifier).state = overlay;

  ScannerOverlay? get duplicateOverlay => ref.watch(duplicateOverlayProvider);

  set duplicateOverlay(ScannerOverlay? overlay) =>
      ref.read(duplicateOverlayProvider.notifier).state = overlay;

  Future<void> _hideSuccessOverlay() async {
    await successOverlay?.hide();
    successOverlay = null;
  }

  Future<void> _hideDuplicateOverlay() async {
    await duplicateOverlay?.hide();
    duplicateOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final section = ref.read(currentSectionProvider);

    ref.listen(scannerEventsProvider, (_, current) async {
      switch (current) {
        case NewCode c:
          {
            await _hideSuccessOverlay();
            await _hideDuplicateOverlay();
            final createdUpdatedDate = DateTime.now();
            final scannedItem = ScannedItem(
              barcode: c.code,
              created: createdUpdatedDate,
              updated: createdUpdatedDate,
              count: 1,
            );

            if (scannedItem.barcode.isNotEmpty) {
              ref
                  .read(_controllerProvider.notifier)
                  .addScannedItem(section.id, scannedItem);
              successOverlay =
                  ScannerOverlay.show(context, ScanSuccess(scannedItem));
            }
            break;
          }

        case DuplicateCode c:
          await _hideSuccessOverlay();

          final latestItem = await ref
              .read(_controllerProvider.notifier)
              .getLatest(section.id);

          if (latestItem == null || latestItem.barcode != c.code) {
            return;
          }
          final content = ScanDuplicate(
            scannedItem: latestItem,
            onUpdate: (updated) {
              ref.read(_controllerProvider.notifier).updateScannedItem(updated);
            },
            onClose: () async {
              await _hideDuplicateOverlay();
            },
          );

          if (duplicateOverlay == null) {
            duplicateOverlay = ScannerOverlay.show(context, content);
          } else {
            await duplicateOverlay?.update(content);
          }

          break;

        case NoCode _:
          // don't hide the duplicate overlay
          await _hideSuccessOverlay();
      }
    });

    return Theme(
      data: ref.read(themeDataProvider(Brightness.dark)),
      child: PopScope(
        canPop: ref.watch(canPopProvider),
        onPopInvokedWithResult: (popped, _) async {
          await _hideSuccessOverlay();
          await _hideDuplicateOverlay();
        },
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
                    final scanRect = _getScanRect(
                        constraints.maxWidth, constraints.maxHeight);
                    return Stack(children: [
                      ScannerWidget(
                        overlay: ScannerWidgetOverlay(scanWindow: scanRect),
                        onDetect: (barcodeCapture) => ref
                            .read(scannedCodeProvider.notifier)
                            .onDetect(firstEan13(barcodeCapture)),
                      ),
                    ]);
                  }),
                ),
                //const _ScannedItemList(),
              ],
            ),
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
}
