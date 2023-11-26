import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_barcode_scanner/scanner/scanner_screen.dart';

const _strokeWidth = 3.0;

class ScannerWidgetOverlay extends ConsumerStatefulWidget {
  final Rect scanWindow;
  final Color color;

  const ScannerWidgetOverlay({
    super.key,
    required this.scanWindow,
    required this.color,
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

    final path = _getOverlayCutOutPath(widget.scanWindow);
    final fgPath = _getOverlayCutOutForegroundPath(widget.scanWindow);


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
            _OverlayBackground(path)
          ],
        ),
      ),
      _OverlayForeground(fgPath)
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

