import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stock_barcode_scanner/scanner/review_bottom_sheet.dart';

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

class _ScannerMessage extends ConsumerWidget {
  const _ScannerMessage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(scannerEventsProvider);

    final message = ref.watch(scannerActiveProvider) == true
        ? switch (s) {
            NewCode _ => '',
            DuplicateCode _ => '',
            CandidateCode _ => 'Hold still...',
            NoCode _ => 'Scan a new item',
          }
        : 'Scanner paused ...';

    return Text(message);
  }
}

class _ForegroundPathPainter extends ConsumerWidget {
  static const _strokeWidth = 5.0;
  final Path _cutoutPath;

  _ForegroundPathPainter({required Rect scanWindow})
      : _cutoutPath = _buildPath(scanWindow);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(scannerEventsProvider);

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = switch (s) {
        NewCode _ => Colors.green.withOpacity(1.0),
        DuplicateCode _ => Colors.red.withOpacity(0.7),
        CandidateCode _ => Colors.green.withOpacity(0.7),
        NoCode _ => Colors.white.withOpacity(0.7),
      };

    return _PathPainter(
      path: _cutoutPath,
      pathPaint: strokePaint,
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

class _OverlayForeground extends ConsumerWidget {
  final ValueNotifier<bool> soundController;
  final MobileScannerController controller;
  final Rect _scanWindow;

  const _OverlayForeground(
    this._scanWindow, {
    required this.soundController,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(scannerEventsProvider);

    if (soundController.value) {
      switch (s) {
        case NewCode _:
          ref.read(scanSoundProvider).resume();
          break;
        case DuplicateCode _:
          ref.read(duplicateSoundProvider).resume();
          break;
        default:
      }
    }

    return Stack(
      children: [
        _ForegroundPathPainter(scanWindow: _scanWindow),
        Positioned(
          left: 0,
          right: 0,
          top: _scanWindow.bottomCenter.dy,
          child: const Center(child: _ScannerMessage()),
        ),
        const Positioned(
          left: 0,
          right: 0,
          bottom: 80,
          child: Center(
            child: PauseResumeScanningButton(),
          ),
        ),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ReviewBottomSheet(soundController, controller))
      ],
    );
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
