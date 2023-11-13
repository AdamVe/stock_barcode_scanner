import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/item_repository.dart';
import '../date_time_ext.dart';
import '../domain/models.dart';

part 'scanner_screen.g.dart';

const _strokeWidth = 3.0;

final sectionProvider =
    StateProvider<Section>((ref) => Section(0, 0, '', '', DateTime(0)));

final duplicateProvider = StateProvider((ref) => false);

@riverpod
class _Controller extends _$Controller {
  Future<List<ScannedItem>> _read() async {
    final sectionId = ref.read(sectionProvider).id;
    return ref.read(itemRepositoryProvider).getScans(sectionId: sectionId);
  }

  @override
  FutureOr<List<ScannedItem>> build() {
    ref.invalidate(duplicateProvider);
    ref.invalidate(barcodeProvider);
    ref.invalidate(detectedBarcodeProvider);
    ref.invalidate(lastSeenBarcodeProvider);
    return _read();
  }

  Future<void> updateScannedItem(ScannedItem scannedItem) async {
    await ref.read(itemRepositoryProvider).updateScan(scan: scannedItem);
    await loadScannedItems();
  }

  Future<int> addScannedItem(ScannedItem scannedItem) async {
    int id = await ref.read(itemRepositoryProvider).addScan(scan: scannedItem);
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

Timer? _timer;

class ScannerScreen extends ConsumerWidget {
  static const routeName = '/scanner';

  const ScannerScreen({super.key});

  Rect _getScanRect(double width, double height) {
    final center = Offset(width / 2, 160);
    const scanWinHeight = 130.0;
    final scanWinWidth = width - 40;
    return Rect.fromCenter(
        center: center, width: scanWinWidth, height: scanWinHeight);
  }

  Path _getOverlayCutOutPath(Rect rect) {
    return Path()..addRRect(RRect.fromRectXY(rect, 0, 0));
  }

  Path _getOverlayCutOutForegroundPath(Rect rect) {
    const strokeWidth_2 = _strokeWidth / 2;

    final x1 = rect.center.dx - rect.width / 2;
    final y1 = rect.center.dy - rect.height / 2;
    final x2 = rect.center.dx + rect.width / 2;
    final y2 = rect.center.dy + rect.height / 2;
    return Path()
      ..addPolygon([
        Offset(x1 - strokeWidth_2, y1 - 5),
        Offset(x1 - strokeWidth_2, y1 + 20)
      ], false)
      ..addPolygon([
        Offset(x1 - 5, y1 - strokeWidth_2),
        Offset(x1 + 20, y1 - strokeWidth_2)
      ], false)
      ..addPolygon([
        Offset(x2 + strokeWidth_2, y2 - 20),
        Offset(x2 + strokeWidth_2, y2 + 5)
      ], false)
      ..addPolygon([
        Offset(x2 - 20, y2 + strokeWidth_2),
        Offset(x2 + 5, y2 + strokeWidth_2)
      ], false)
      ..addPolygon([
        Offset(x1 - strokeWidth_2, y2 - 20),
        Offset(x1 - strokeWidth_2, y2 + 5)
      ], false)
      ..addPolygon([
        Offset(x1 - 5, y2 + strokeWidth_2),
        Offset(x1 + 20, y2 + strokeWidth_2)
      ], false)
      ..addPolygon([
        Offset(x2 + strokeWidth_2, y1 - 5),
        Offset(x2 + strokeWidth_2, y1 + 20)
      ], false)
      ..addPolygon([
        Offset(x2 - 20, y1 - strokeWidth_2),
        Offset(x2 + 5, y1 - strokeWidth_2)
      ], false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_controllerProvider);
    var controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 350,
    );

    ref.listen(detectedBarcodeProvider, (previous, next) async {
      if (next.isEmpty) {
        if (kDebugMode) {
          print('No barcode detected');
        }
        return;
      }

      if (next != ref.read(lastSeenBarcodeProvider)) {
        if (kDebugMode) {
          print('Found new barcode: $next');
        }

        // add this barcode
        HapticFeedback.mediumImpact();
        int rowId = await ref
            .read(_controllerProvider.notifier)
            .addScannedItem(ScannedItem(
              0,
              ref.read(sectionProvider).id,
              next,
              DateTime.now(),
              1,
            ));

        ref.read(barcodeProvider.notifier).state = BarcodeData(rowId, next, 1);
      } else {
        if (previous?.isEmpty ?? true) {
          // TODO: _duplicateVibrate();
          if (kDebugMode) {
            print('Notifying duplicate scan');
          }
          ref.read(duplicateProvider.notifier).state = true;
          Future.delayed(const Duration(milliseconds: 300), () {
            if (kDebugMode) {
              print('Clearing duplicate scan notification');
            }
            ref.read(duplicateProvider.notifier).state = false;
          });
        }
        if (kDebugMode) {
          print('See old barcode: $next');
        }
      }
    });

    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: Scaffold(
        appBar:
            AppBar(title: Text('Section: ${ref.read(sectionProvider).name}')),
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
                  final path = _getOverlayCutOutPath(scanRect);
                  final fgPath = _getOverlayCutOutForegroundPath(scanRect);

                  return Stack(children: [
                    MobileScanner(
                      controller: controller,
                      overlay: MobileScannerOverlay(
                        background: OverlayBackground(path),
                        foreground: OverlayForeground(
                          fgPath,
                        ),
                        color: Colors.black.withOpacity(0.6),
                      ),
                      scanWindow: scanRect,
                      onDetect: (capture) async {
                        final currentBarcode = capture.barcodes
                                .where((element) =>
                                    element.format == BarcodeFormat.ean13)
                                .firstOrNull
                                ?.rawValue! ??
                            '';

                        if (currentBarcode.isNotEmpty) {
                          _timer?.cancel();

                          ref.read(detectedBarcodeProvider.notifier).state =
                              currentBarcode;

                          ref.read(lastSeenBarcodeProvider.notifier).state =
                              currentBarcode;

                          // start timer to clear the code if not detected
                          _timer = Timer(const Duration(milliseconds: 750), () {
                            if (kDebugMode) {
                              print('clearing detected barcode');
                            }

                            ref.read(detectedBarcodeProvider.notifier).state =
                                '';
                          });
                        }
                      },
                    ),
                    const _AdjustScanCountWidget(),
                  ]);
                }),
              ),
              state.when(
                error: (e, st) => Center(child: Text('Error: $st')),
                loading: () => const CircularProgressIndicator(),
                data: (scannedItems) => _ScannedItemList(scannedItems),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BarcodeData {
  int rowId;
  String value;
  int count;

  BarcodeData(this.rowId, this.value, this.count);
}

final barcodeProvider =
    StateProvider<BarcodeData>((ref) => BarcodeData(0, '', 0));

final detectedBarcodeProvider = StateProvider<String>((ref) => '');
final lastSeenBarcodeProvider = StateProvider<String>((ref) => '');

class _AdjustScanCountWidget extends ConsumerWidget {
  const _AdjustScanCountWidget();

  void _update(WidgetRef ref, int amount) {
    final sectionId = ref.read(sectionProvider).id;
    final barcode = ref.read(barcodeProvider);
    int count = barcode.count + amount;
    HapticFeedback.mediumImpact();
    ref.read(_controllerProvider.notifier).updateScannedItem(ScannedItem(
          barcode.rowId,
          sectionId,
          barcode.value,
          DateTime.now(),
          count,
        ));

    ref.read(barcodeProvider.notifier).state =
        BarcodeData(barcode.rowId, barcode.value, count);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barcode = ref.watch(barcodeProvider);
    final isDuplicate = ref.watch(duplicateProvider);
    return PositionedDirectional(
        start: 0,
        end: 0,
        bottom: 30,
        child: Column(
          children: [
            Text(
              barcode.value,
              style: isDuplicate
                  ? Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.green, fontWeight: FontWeight.bold)
                  : Theme.of(context).textTheme.headlineMedium,
            ),
            if (barcode.value.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed:
                          barcode.count > 1 ? () => _update(ref, -1) : null,
                      child: const Icon(
                        Icons.remove,
                        size: 32,
                      )),
                  SizedBox(
                      width: 64,
                      child: Text(
                        barcode.count.toString(),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      )),
                  ElevatedButton(
                      onPressed:
                          barcode.count < 1000 ? () => _update(ref, 1) : null,
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

class _ScannedItemList extends ConsumerWidget {
  final List<ScannedItem> _scannedItems;

  const _ScannedItemList(this._scannedItems);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(builder: (context) {
      return Column(
        children: [
          ListTile(
            leading: const Icon(Icons.document_scanner_outlined),
            title: const Text('Items'),
            subtitle: Text('Count: ${_scannedItems.length}'),
          ),
          SizedBox(
            height: 250,
            child: ListView.builder(
                itemCount: _scannedItems.length,
                itemBuilder: (BuildContext context, int index) {
                  final scannedItem = _scannedItems[index];
                  final sum = _scannedItems
                      .where((i) => i.barcode == scannedItem.barcode)
                      .fold(0, (previousValue, i) => previousValue + i.count);
                  return ListTile(
                    title: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: scannedItem.count > 1
                              ? Text('${scannedItem.count} \u00d7')
                              : const Text(''),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          scannedItem.barcode,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const Spacer(),
                        IconButton(
                            onPressed: () {
                              ref
                                  .read(_controllerProvider.notifier)
                                  .deleteScannedItem(scannedItem);
                            },
                            icon: const Icon(Icons.delete_outline_outlined))
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        const SizedBox(
                          width: 40, // 32 + 8
                        ),
                        Text(scannedItem.created.format()),
                        const SizedBox(
                          width: 32,
                        ),
                        Text('Sum: $sum')
                      ],
                    ),
                  );
                }),
          ),
        ],
      );
    });
  }
}

class PathPainter extends StatelessWidget {
  final Path path;
  final Paint pathPaint;

  const PathPainter({required this.path, required this.pathPaint, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ShapePainter(path: path, pathPaint: pathPaint),
    );
  }
}

class ShapePainter extends CustomPainter {
  final Path path;
  final Paint pathPaint;

  const ShapePainter({required this.path, required this.pathPaint}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BarcodeDetectionIcon extends ConsumerWidget {
  const BarcodeDetectionIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seeBarcode = ref.watch(detectedBarcodeProvider) != '';

    final detectionColor = seeBarcode
        ? Colors.green.withOpacity(1)
        : Colors.white.withOpacity(0.3);

    return Icon(
      Icons.remove_red_eye_outlined,
      size: 32,
      color: detectionColor,
    );
  }
}

class OverlayForeground extends ConsumerWidget {
  final Path path;

  const OverlayForeground(this.path, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rect = path.getBounds();

    return Stack(
      children: [
        PathPainter(
          path: path,
          pathPaint: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = _strokeWidth
            ..strokeCap = StrokeCap.round
            ..color = Colors.white.withOpacity(0.3),
        ),
        Positioned(
          left: rect.left,
          top: rect.top - 32,
          child: const BarcodeDetectionIcon(),
        ),
      ],
    );
  }
}

class OverlayBackground extends StatelessWidget {
  final Path path;

  const OverlayBackground(this.path, {super.key});

  @override
  Widget build(BuildContext context) {
    return PathPainter(
      path: path,
      pathPaint: Paint()..color = Colors.black,
    );
  }
}

class MobileScannerOverlay extends StatelessWidget {
  final Widget background;
  final Widget? foreground;
  final Color color;

  const MobileScannerOverlay({
    required this.background,
    this.foreground,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcOut),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: color, backgroundBlendMode: BlendMode.dstOut),
            ),
            background
          ],
        ),
      ),
      if (foreground != null) foreground!
    ]);
  }
}
