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
  String _code = '';
  bool _active = true;

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
              child: MobileScanner(
                controller: controller,
                overlay: ScannerAreaCutout(active: _active),
                onDetect: (capture) {
                  if (!_active) {
                    return;
                  }
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    setState(() {
                      _active = false;
                      HapticFeedback.mediumImpact();
                      _code = barcode.rawValue ?? '';
                      Future.delayed(const Duration(seconds: 3), () {
                        setState(() {
                          _code = '';
                          _active = true;
                        });
                      });
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(height: 200, child: Text('Scanned: $_code')),
            )
          ],
        ),
      ),
    );
  }
}

class ScannerAreaCutout extends StatelessWidget {
  final bool active;

  const ScannerAreaCutout({required this.active, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColorFiltered(
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcOut),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Colors.black, backgroundBlendMode: BlendMode.dstOut),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      margin:
                          const EdgeInsets.only(top: 80, left: 20, right: 20),
                      height: 200,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.green,
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignInside,
                              style: BorderStyle.solid)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 80, left: 20, right: 20),
                height: 200,
                decoration: BoxDecoration(
                    color: active == true
                        ? Colors.transparent
                        : Colors.black.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.green,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                        style: BorderStyle.solid)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
