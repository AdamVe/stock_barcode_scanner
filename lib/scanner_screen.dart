import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stock_barcode_scanner/date_time_ext.dart';

import 'db.dart';

const _strokeWidth = 3.0;

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
  bool _detected = false;
  bool _valid = false;
  Timer? _timer;
  Barcode? _lastBarcode;
  int _lastCodeCount = 1;
  int _insertedScanItemId = 0;
  List<ScannedItem>? _scannedItems;

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
  void initState() {
    super.initState();
    _scannedItems = DbConnector.getScannedItems(widget.section.id);
  }

  @override
  Widget build(BuildContext context) {
    var controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 350,
    );

    return Theme(
      data: ThemeData.dark(useMaterial3: true),
      child: Scaffold(
        appBar: AppBar(title: Text('Section: ${widget.section.name}')),
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
                          detected: _detected,
                          valid: _valid,
                        ),
                        color: Colors.black.withOpacity(0.6),
                      ),
                      scanWindow: scanRect,
                      onDetect: (capture) {
                        bool detected = false;
                        bool valid = false;
                        Barcode? lastBarcode = _lastBarcode;
                        int lastCodeCount = _lastCodeCount;
                        int insertedScanItemId = _insertedScanItemId;
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          detected = true;
                        }

                        final currentBarcode = barcodes
                            .where((element) =>
                                element.format == BarcodeFormat.ean13)
                            .firstOrNull;

                        if (currentBarcode != null) {
                          valid = true;
                        }

                        if (currentBarcode != null &&
                            currentBarcode.rawValue != lastBarcode?.rawValue) {
                          if (kDebugMode) {
                            print(
                                'Found new barcode: ${currentBarcode.displayValue}');
                          }

                          // add this barcode
                          HapticFeedback.mediumImpact();
                          insertedScanItemId =
                              DbConnector.addScannedItem(ScannedItem(
                            0,
                            widget.section.id,
                            currentBarcode.rawValue!,
                            DateTime.now(),
                            1,
                          ));

                          lastCodeCount = 1;
                        } else {
                          if (currentBarcode != null &&
                              currentBarcode.rawValue ==
                                  lastBarcode?.rawValue) {
                            if (kDebugMode) {
                              print(
                                  'See old barcode: ${currentBarcode.displayValue}');
                            }
                          }
                        }

                        lastBarcode = currentBarcode;

                        if (_detected != detected || _valid != valid) {
                          _timer?.cancel();
                          setState(() {
                            _detected = detected;
                            _valid = valid;
                            _lastBarcode = lastBarcode;
                            _lastCodeCount = lastCodeCount;
                            _insertedScanItemId = insertedScanItemId;
                            _scannedItems =
                                DbConnector.getScannedItems(widget.section.id);
                          });
                        } else {
                          _timer?.cancel();
                          _timer = Timer(const Duration(milliseconds: 750), () {
                            setState(() {
                              _detected = false;
                              _valid = false;
                              _lastBarcode = lastBarcode;
                            });
                          });
                        }
                      },
                    ),
                    if (_lastBarcode != null && _lastBarcode?.rawValue != null)
                      PositionedDirectional(
                          start: 0,
                          end: 0,
                          bottom: 30,
                          child: Column(
                            children: [
                              Text(
                                _lastBarcode!.rawValue!,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      onPressed: _lastCodeCount > 1
                                          ? () {
                                              int lastCodeCount =
                                                  _lastCodeCount - 1;
                                              // add this barcode
                                              HapticFeedback.mediumImpact();
                                              DbConnector.updateScannedItem(
                                                  ScannedItem(
                                                _insertedScanItemId,
                                                widget.section.id,
                                                _lastBarcode!.rawValue!,
                                                DateTime.now(),
                                                lastCodeCount,
                                              ));

                                              setState(() {
                                                _lastCodeCount = lastCodeCount;
                                                _scannedItems =
                                                    DbConnector.getScannedItems(
                                                        widget.section.id);
                                              });
                                            }
                                          : null,
                                      child: const Icon(Icons.remove)),
                                  SizedBox(
                                      width: 64,
                                      child: Text(
                                        _lastCodeCount.toString(),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall,
                                      )),
                                  ElevatedButton(
                                      onPressed: _lastCodeCount < 1000
                                          ? () {
                                              int lastCodeCount =
                                                  _lastCodeCount + 1;
                                              // add this barcode
                                              HapticFeedback.mediumImpact();
                                              DbConnector.updateScannedItem(
                                                  ScannedItem(
                                                _insertedScanItemId,
                                                widget.section.id,
                                                _lastBarcode!.rawValue!,
                                                DateTime.now(),
                                                lastCodeCount,
                                              ));

                                              setState(() {
                                                _lastCodeCount = lastCodeCount;
                                                _scannedItems =
                                                    DbConnector.getScannedItems(
                                                        widget.section.id);
                                              });
                                            }
                                          : null,
                                      child: const Icon(Icons.add)),
                                ],
                              ),
                            ],
                          ))
                  ]);
                }),
              ),
              Builder(builder: (context) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.document_scanner_outlined),
                      title: const Text('Items'),
                      subtitle: Text('Count: ${_scannedItems?.length ?? 0}'),
                    ),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                          itemCount: _scannedItems?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            final scannedItem = _scannedItems![index];
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                  ),
                                ],
                              ),
                              subtitle: Text(scannedItem.created.format()),
                            );
                          }),
                    ),
                  ],
                );
              })
            ],
          ),
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

class OverlayForeground extends StatelessWidget {
  final Path path;
  final bool? detected;
  final bool? valid;

  const OverlayForeground(this.path, {this.detected, this.valid, super.key});

  @override
  Widget build(BuildContext context) {
    final rect = path.getBounds();

    final detectionColor = true == detected
        ? true == valid
            ? Colors.green.withOpacity(1)
            : Colors.green.withOpacity(0.3)
        : Colors.white.withOpacity(0.3);

    final detectionIcon = Icon(
      Icons.remove_red_eye_outlined,
      size: 32,
      color: detectionColor,
    );
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
          top: rect.top - (detectionIcon.size ?? 0).toInt(),
          child: detectionIcon,
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
