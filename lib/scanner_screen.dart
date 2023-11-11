import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stock_barcode_scanner/date_time_ext.dart';

import 'db.dart';

class ScannerScreenArguments {
  final Section section;

  ScannerScreenArguments(this.section);
}

class ScannerScreen extends StatelessWidget {
  static const routeName = '/scanner';

  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ScannerScreenArguments;
    return _ScannerScreenChild(section: args.section);
  }
}

class _ScannerScreenChild extends StatefulWidget {
  final Section section;

  const _ScannerScreenChild({required this.section});

  @override
  State<_ScannerScreenChild> createState() => _ScannerScreenChildState();
}

class _ScannerScreenChildState extends State<_ScannerScreenChild> {
  bool _active = true;
  List<ScannedItem>? scannedItems;

  @override
  void initState() {
    super.initState();
    scannedItems = DbConnector.getScannedItems(widget.section.id);
  }

  @override
  Widget build(BuildContext context) {
    var controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 750,
    );

    return Scaffold(
      appBar: AppBar(title: Text('Section: ${widget.section.name}')),
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
                          DbConnector.addScannedItem(ScannedItem(
                            0,
                            widget.section.id,
                            barcode.rawValue!,
                            DateTime.now(),
                            1,
                          ));
                          scannedItems =
                              DbConnector.getScannedItems(widget.section.id);
                          Future.delayed(const Duration(seconds: 3), () {
                            setState(() {
                              _active = true;
                            });
                          });
                        }
                      });
                    }
                  },
                );
              }),
            ),
            SizedBox(
                height: 400,
                child: ListView.builder(
                    itemCount: scannedItems?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      final scannedItem = scannedItems![index];
                      return ListTile(
                        leading: const Icon(Icons.document_scanner_outlined),
                        title: Text(scannedItem.barcode),
                        subtitle: Text(scannedItem.created.format()),
                        trailing: Text('${scannedItem.count}'),
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