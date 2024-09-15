import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:stock_barcode_scanner/scanner/scanner_screen.dart';

import 'models.dart';

const pi_2 = pi / 2.0;
const pi_3_2 = 3.0 * pi_2;

class ScannerWidgetOverlay extends ConsumerStatefulWidget {
  final Rect scanWindow;
  final backgroundColor = const Color.fromARGB(140, 0, 0, 0);

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
    ref.listen(scannerEventsProvider, (previous, next) async {
      if (next is DuplicateCode) {
        TickerFuture tickerFuture = _controller.repeat();
        tickerFuture.timeout(const Duration(milliseconds: 400), onTimeout: () {
          _controller.forward(from: 0);
          _controller.stop(canceled: true);
          setState(() {
            _showDuplicate = false;
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
    final s = ref.watch(scannerEventsProvider);

    final code = switch (s) {
      NewCode c => c.code,
      DuplicateCode d => '${d.code} (Duplicate)',
      CandidateCode c => 'Candidate ${c.code}',
      _ => ''
    };

    final detectionColor = switch (s) {
      NewCode _ => Colors.white.withOpacity(1.0),
      DuplicateCode _ => Colors.red.withOpacity(0.5),
      CandidateCode _ => Colors.white.withOpacity(0.5),
      _ => Colors.white.withOpacity(0.1),
    };

    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Symbols.remove_red_eye,
            size: 32,
            color: detectionColor,
          ),
          Text(code)
        ]);
  }
}

class _OverlayForeground extends ConsumerWidget {
  static const _strokeWidth = 5.0;
  final Rect _scanWindow;
  final Path _cutoutPath;

  _OverlayForeground(this._scanWindow) : _cutoutPath = _buildPath(_scanWindow);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(scannerEventsProvider);

    final detectionColor = switch (s) {
      NewCode _ => Colors.green.withOpacity(1.0),
      DuplicateCode _ => Colors.red.withOpacity(0.7),
      CandidateCode _ => Colors.green.withOpacity(0.7),
      _ => Colors.white.withOpacity(0.7),
    };

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = detectionColor;

    return Stack(
      children: [
        _PathPainter(
          path: _cutoutPath,
          pathPaint: strokePaint,
        ),
        // Positioned(
        //   left: 0,
        //   right: 0,
        //   top: _scanWindow.bottomCenter.dy,
        //   child: ColoredBox(
        //     color: Colors.transparent,
        //     child: Text(
        //       'Scan an item...',
        //       textAlign: TextAlign.center,
        //     ),
        //   ),
        // ),
        Positioned(
          left: _scanWindow.left,
          top: _scanWindow.top - 32,
          child: const _BarcodeDetectionIcon(),
        ),
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
