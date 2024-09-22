import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stock_barcode_scanner/scanner/scanned_items_list.dart';

import 'models.dart';
import 'scanner_buttons.dart';

const pi_2 = pi / 2.0;
const pi_3_2 = 3.0 * pi_2;

class ScannerWidgetOverlay extends ConsumerStatefulWidget {
  final MobileScannerController controller;
  final Rect scanWindow;
  final backgroundColor = const Color.fromARGB(140, 0, 0, 0);
  final ValueNotifier<bool> soundController;

  const ScannerWidgetOverlay({
    super.key,
    required this.soundController,
    required this.controller,
    required this.scanWindow,
  });

  Rect getScanWindow() {
    return scanWindow;
  }

  @override
  ConsumerState<ScannerWidgetOverlay> createState() =>
      _ScannerWidgetOverlayState();
}

class _ScannerWidgetOverlayState extends ConsumerState<ScannerWidgetOverlay>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(fit: StackFit.expand, children: [
      ColorFiltered(
        colorFilter: ColorFilter.mode(widget.backgroundColor, BlendMode.srcOut),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  backgroundBlendMode: BlendMode.dstOut),
            ),
            _OverlayBackground(widget.scanWindow)
          ],
        ),
      ),
      _OverlayForeground(widget.scanWindow,
          soundController: widget.soundController,
          controller: widget.controller)
    ]);
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

class _ActionParameters {
  final Color strokeColor;
  final String userInstruction;
  final Function()? action;

  _ActionParameters({
    required this.strokeColor,
    this.userInstruction = '',
    this.action,
  });
}

class _OverlayForeground extends ConsumerWidget {
  static const _strokeWidth = 5.0;
  final ValueNotifier<bool> soundController;
  final MobileScannerController controller;
  final Rect _scanWindow;
  final Path _cutoutPath;

  _OverlayForeground(
    this._scanWindow, {
    required this.soundController,
    required this.controller,
  }) : _cutoutPath = _buildPath(_scanWindow);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(scannerEventsProvider);

    final ui = switch (s) {
      NewCode _ => _ActionParameters(
          strokeColor: Colors.green.withOpacity(1.0),
          action: () {
            if (soundController.value) {
              ref.read(scanSoundProvider).resume();
            }
          },
        ),
      DuplicateCode _ => _ActionParameters(
          strokeColor: Colors.red.withOpacity(0.7),
          action: () {
            if (soundController.value) {
              ref.read(duplicateSoundProvider).resume();
            }
          },
        ),
      CandidateCode _ => _ActionParameters(
          strokeColor: Colors.green.withOpacity(0.7),
          userInstruction: 'Hold still...'),
      NoCode _ => _ActionParameters(
          strokeColor: Colors.white.withOpacity(0.7),
          userInstruction: 'Scan a new item'),
    };

    ui.action?.call();

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = ui.strokeColor;

    return Stack(
      children: [
        _PathPainter(
          path: _cutoutPath,
          pathPaint: strokePaint,
        ),
        Positioned(
          left: 0,
          right: 0,
          top: _scanWindow.bottomCenter.dy,
          child: Center(child: Text(ui.userInstruction)),
        ),
        const Positioned(
            left: 0,
            right: 0,
            bottom: 80,
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 64, 0, 0),
                child: PauseResumeScanningButton(),
              ),
            )),
        Positioned(
            right: 0,
            top: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Consumer(builder: (context, ref, _) {
                return ref.watch(scannerActiveProvider) != true
                    ? const Icon(Symbols.pause)
                    : const SizedBox();
              }),
            )),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomSheet(
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
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        const Icon(
                                          Symbols.barcode,
                                          size: 24,
                                        ),
                                        const SizedBox(
                                          width: 6,
                                        ),
                                        if (scannedItems[0].count > 1)
                                          Text(
                                              '${scannedItems[0].count} \u00d7 '),
                                        Text(
                                          scannedItems[0].barcode,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        )
                                      ],
                                    ),
                                    subtitle: Text(
                                        'Section contains ${scannedItems.length} items.'),
                                  ),
                                ),
                              ) ??
                              const SizedBox(),
                          ReviewButton(onPressed: () async {
                            ref.read(scannerActiveProvider.notifier).state =
                                false;
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
                                  return ScannedItemList(
                                    soundController: soundController,
                                    scannerController: controller,
                                  );
                                });
                            ref.read(scannerActiveProvider.notifier).state =
                                true;
                          }),
                        ]),
                  );
                }))
      ],
    );
  }

  static Path _buildPath(Rect rect) {
    final x1 = rect.center.dx - rect.width / 2 + 5;
    final y1 = rect.center.dy - rect.height / 2 + 5;
    final x2 = rect.center.dx + rect.width / 2 - 5;
    final y2 = rect.center.dy + rect.height / 2 - 5;

    final r1 = Rect.fromLTWH(x1, y1, 40, 40);
    final r2 = Rect.fromLTWH(x2 - 40, y1, 40, 40);
    final r3 = Rect.fromLTWH(x1, y2 - 40, 40, 40);
    final r4 = Rect.fromLTWH(x2 - 40, y2 - 40, 40, 40);
    return Path()
      ..addArc(r1, pi, pi_2)
      ..addArc(r2, pi_3_2, pi_2)
      ..addArc(r3, pi_2, pi_2)
      ..addArc(r4, 0, pi_2);
  }
}

class _OverlayBackground extends StatelessWidget {
  final Path path;

  _OverlayBackground(Rect r) : path = _buildPath(r);

  @override
  Widget build(BuildContext context) {
    return _PathPainter(
      path: path,
      pathPaint: Paint()..color = Colors.black,
    );
  }

  static Path _buildPath(Rect rect) {
    return Path()..addRRect(RRect.fromRectXY(rect, 25, 25));
  }
}
