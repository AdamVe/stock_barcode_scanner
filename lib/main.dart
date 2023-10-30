import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const StockBarcodeScannerApp());
}

class StockBarcodeScannerApp extends StatelessWidget {
  const StockBarcodeScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Barcode Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Stock Barcode Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _active = true;
  final List<String> _scannedCodes = [];

  @override
  Widget build(BuildContext context) {
    var controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 750,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                final center = Offset(width / 2, height / 2);
                const scanWinHeight = 130.0;
                final scanWinWidth = width - 40;
                final scanWinRect = Rect.fromCenter(
                    center: center, width: scanWinWidth, height: scanWinHeight);

                final path = Path()
                  ..addRRect(RRect.fromRectXY(scanWinRect, 0, 0));

                const strokeWidth = 3.0;
                const strokeWidth_2 = strokeWidth / 2;
                final x1 = center.dx - scanWinWidth / 2;
                final y1 = center.dy - scanWinHeight / 2;
                final x2 = center.dx + scanWinWidth / 2;
                final y2 = center.dy + scanWinHeight / 2;
                final fgPath = Path()
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
                return MobileScanner(
                  controller: controller,
                  overlay: MobileScannerOverlay(
                    active: _active,
                    background: PathPainter(
                      path: path,
                      pathPaint: Paint()..color = Colors.black,
                    ),
                    foreground: PathPainter(
                      path: fgPath,
                      pathPaint: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = strokeWidth
                        ..strokeCap = StrokeCap.round
                        ..color = Colors.white.withOpacity(0.3),
                    ),
                    color: Colors.black.withOpacity(0.6),
                  ),
                  scanWindow: scanWinRect,
                  onDetect: (capture) {
                    if (!_active) {
                      return;
                    }
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      setState(() {
                        _active = false;
                        HapticFeedback.mediumImpact();
                        if (barcode.rawValue != null) {
                          _scannedCodes.insertAll(0, [barcode.rawValue!]);
                        }
                        Future.delayed(const Duration(seconds: 3), () {
                          setState(() {
                            _active = true;
                          });
                        });
                      });
                    }
                  },
                );
              }),
            ),
            SizedBox(
                height: 400,
                child: ListView.builder(
                    itemCount: _scannedCodes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: const Icon(Icons.camera),
                        title: Text(_scannedCodes[index]),
                      );
                    }))
          ],
        ),
      ),
    );
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

class MobileScannerOverlay extends StatelessWidget {
  final bool active;
  final Widget background;
  final Widget? foreground;
  final Color color;

  const MobileScannerOverlay(
      {required this.active,
      required this.background,
      this.foreground,
      required this.color,
      super.key});

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
