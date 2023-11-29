import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_barcode_scanner/scanner/scanner_screen.dart';

class ScannerWidgetOverlay extends ConsumerStatefulWidget {
  final Rect scanWindow;
  final backgroundColor = const Color.fromARGB(50, 0, 0, 0);

  const ScannerWidgetOverlay({
    super.key,
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
            _showDuplicate ? _colorAnimation.value! : widget.backgroundColor,
            BlendMode.srcOut),
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
      _OverlayForeground(widget.scanWindow)
    ]);
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);

    _colorAnimation = ColorTween(
            begin: Colors.white.withOpacity(0.3), end: widget.backgroundColor)
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
  static const _strokeWidth = 1.0;
  static const _strokeWidth_2 = _strokeWidth / 2;
  final Rect _scanWindow;
  final Path _cutoutPath;
  final Paint _cutoutPaint;

  _OverlayForeground(this._scanWindow)
      : _cutoutPath = _buildPath(_scanWindow),
        _cutoutPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = Colors.white.withOpacity(0.9);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        _PathPainter(
          path: _cutoutPath,
          pathPaint: _cutoutPaint,
        ),
        Positioned(
          left: _scanWindow.left,
          top: _scanWindow.top - 32,
          child: const _BarcodeDetectionIcon(),
        ),
      ],
    );
  }

  static Path _buildPath(Rect rect) {
    final x1 = rect.center.dx - rect.width / 2;
    final y1 = rect.center.dy - rect.height / 2;
    final x2 = rect.center.dx + rect.width / 2;
    final y2 = rect.center.dy + rect.height / 2;
    return Path()
      ..addPolygon([
        Offset(x1 - _strokeWidth_2, y1 - 5),
        Offset(x1 - _strokeWidth_2, y1 + 20)
      ], false)
      ..addPolygon([
        Offset(x1 - 5, y1 - _strokeWidth_2),
        Offset(x1 + 20, y1 - _strokeWidth_2)
      ], false)
      ..addPolygon([
        Offset(x2 + _strokeWidth_2, y2 - 20),
        Offset(x2 + _strokeWidth_2, y2 + 5)
      ], false)
      ..addPolygon([
        Offset(x2 - 20, y2 + _strokeWidth_2),
        Offset(x2 + 5, y2 + _strokeWidth_2)
      ], false)
      ..addPolygon([
        Offset(x1 - _strokeWidth_2, y2 - 20),
        Offset(x1 - _strokeWidth_2, y2 + 5)
      ], false)
      ..addPolygon([
        Offset(x1 - 5, y2 + _strokeWidth_2),
        Offset(x1 + 20, y2 + _strokeWidth_2)
      ], false)
      ..addPolygon([
        Offset(x2 + _strokeWidth_2, y1 - 5),
        Offset(x2 + _strokeWidth_2, y1 + 20)
      ], false)
      ..addPolygon([
        Offset(x2 - 20, y1 - _strokeWidth_2),
        Offset(x2 + 5, y1 - _strokeWidth_2)
      ], false);
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
    return Path()..addRRect(RRect.fromRectXY(rect, 0, 0));
  }
}
