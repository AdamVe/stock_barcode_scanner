import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stock_barcode_scanner/date_time_ext.dart';

import '../data/item_repository.dart';
import '../domain/models.dart';

part 'scanner_screen.g.dart';

const _strokeWidth = 3.0;
const _scannedItemListHeight = 250.0;

Timer? _timer;

@Riverpod(keepAlive: true)
class CurrentSection extends _$CurrentSection {
  @override
  Section build() => Section(
        id: 0,
        projectId: 0,
        name: '',
        details: '',
        operatorName: '',
        created: DateTime(0),
      );

  void update(Section sectionId) {
    state = sectionId;
  }
}

@Riverpod(keepAlive: true)
class CurrentBarcode extends _$CurrentBarcode {
  @override
  ScannedItem build() => ScannedItem(
      id: 0,
      sectionId: 0,
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

class ScannerScreen extends ConsumerWidget {
  static const routeName = '/scanner';

  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanSound = ref.watch(scanSoundProvider);
    final section = ref.watch(currentSectionProvider);
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

      if (next != ref.watch(lastSeenBarcodeProvider)) {
        if (kDebugMode) {
          print('Found new barcode: $next');
        }

        HapticFeedback.mediumImpact();
        scanSound.resume();

        final createdUpdatedDate = DateTime.now();

        final newScannedItem = ScannedItem(
          id: 0,
          sectionId: section.id,
          barcode: next,
          created: createdUpdatedDate,
          updated: createdUpdatedDate,
          count: 1,
        );

        ref
            .read(_controllerProvider.notifier)
            .addScannedItem(newScannedItem)
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
      data: ThemeData.dark(useMaterial3: true),
      child: Scaffold(
        appBar: AppBar(title: Text('Section: ${section.name}')),
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
                      overlay: _MobileScannerOverlay(
                        background: _OverlayBackground(path),
                        foreground: _OverlayForeground(
                          fgPath,
                        ),
                        color: Colors.black.withOpacity(0.8),
                      ),
                      scanWindow: scanRect,
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
}

class _AdjustScanCountWidget extends ConsumerWidget {
  const _AdjustScanCountWidget();

  void _update(WidgetRef ref, int amount) {
    final sectionId =
        ref.watch(currentSectionProvider.select((section) => section.id));
    final currentBarcode = ref.watch(currentBarcodeProvider);
    final updatedScannedItem = currentBarcode.copyWith(
      sectionId: sectionId,
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
                              onTap: () {},
                              onLongPress: () async {
                                await ref
                                    .read(_controllerProvider.notifier)
                                    .deleteScannedItem(scannedItem);
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

class _PathPainter extends StatelessWidget {
  final Path path;
  final Paint pathPaint;

  const _PathPainter({required this.path, required this.pathPaint});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ShapePainter(path: path, pathPaint: pathPaint),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final Path path;
  final Paint pathPaint;

  const _ShapePainter({required this.path, required this.pathPaint}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarcodeDetectionIcon extends ConsumerWidget {
  const _BarcodeDetectionIcon();

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

class _OverlayForeground extends ConsumerWidget {
  final Path path;

  const _OverlayForeground(this.path);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rect = path.getBounds();

    return Stack(
      children: [
        _PathPainter(
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
          child: const _BarcodeDetectionIcon(),
        ),
      ],
    );
  }
}

class _OverlayBackground extends StatelessWidget {
  final Path path;

  const _OverlayBackground(this.path);

  @override
  Widget build(BuildContext context) {
    return _PathPainter(
      path: path,
      pathPaint: Paint()..color = Colors.black,
    );
  }
}

class _MobileScannerOverlay extends ConsumerStatefulWidget {
  final Widget background;
  final Widget? foreground;
  final Color color;

  const _MobileScannerOverlay({
    required this.background,
    this.foreground,
    required this.color,
  });

  @override
  ConsumerState<_MobileScannerOverlay> createState() =>
      _MobileScannerOverlayState();
}

class _MobileScannerOverlayState extends ConsumerState<_MobileScannerOverlay>
    with SingleTickerProviderStateMixin {
  late Animation<Color?> _colorAnimation;
  late AnimationController _controller;

  bool _showDuplicate = false;

  @override
  Widget build(BuildContext context) {
    final duplicateSoundPlayer = ref.watch(duplicateSoundProvider);
    ref.listen(duplicateProvider, (previous, next) async {
      if (next == true) {
        TickerFuture tickerFuture = _controller.repeat();
        tickerFuture.timeout(const Duration(milliseconds: 400), onTimeout: () {
          _controller.forward(from: 0);
          _controller.stop(canceled: true);
          setState(() {
            _showDuplicate = false;
            if (kDebugMode) {
              print('Clearing duplicate scan notification');
            }
            ref.read(duplicateProvider.notifier).update(false);
          });
        });

        setState(() {
          _showDuplicate = true;
        });

        duplicateSoundPlayer.resume();
        int count = 4;
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
          HapticFeedback.lightImpact();
          count--;
          if (count == 0) {
            timer.cancel();
          }
        });
      }
    });

    return Stack(fit: StackFit.expand, children: [
      ColorFiltered(
        colorFilter: ColorFilter.mode(
            _showDuplicate ? _colorAnimation.value! : widget.color,
            BlendMode.srcOut),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: widget.color, backgroundBlendMode: BlendMode.dstOut),
            ),
            widget.background
          ],
        ),
      ),
      if (widget.foreground != null) widget.foreground!
    ]);
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);

    _colorAnimation =
        ColorTween(begin: Colors.white.withOpacity(0.3), end: widget.color)
            .animate(_controller)
          ..addListener(() {
            setState(() {
              // redraws the widget
            });
          });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _timer?.cancel();
  }
}
