import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stock_barcode_scanner/scanner/scanner_widget_overlay.dart';

class _MobileScannerWidget extends StatelessWidget {
  final ScannerWidgetOverlay overlay;
  final Function(BarcodeCapture) onDetect;

  const _MobileScannerWidget(
      {required this.overlay, required this.onDetect});

  @override
  Widget build(BuildContext context) {
    final controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 350,
    );
    return MobileScanner(
      controller: controller,
      scanWindow: overlay.getScanWindow(),
      onDetect: onDetect,
      overlay: overlay,
    );
  }
}

class _DesktopScannerWidget extends StatefulWidget {
  final ScannerWidgetOverlay overlay;
  final Function(BarcodeCapture) onDetect;

  const _DesktopScannerWidget(
      {required this.overlay, required this.onDetect});

  @override
  State<_DesktopScannerWidget> createState() => _DesktopScannerWidgetState();
}

class _DesktopScannerWidgetState extends State<_DesktopScannerWidget> {
  final FocusNode barcodeFieldFocusNode = FocusNode();
  TextEditingController? barcodeFieldController;

  @override
  void initState() {
    super.initState();
    barcodeFieldController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.overlay,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextFormField(
                        autofocus: true,
                        controller: barcodeFieldController,
                        focusNode: barcodeFieldFocusNode,
                        onFieldSubmitted: (String value) {
                          _submit(value);
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Simulate barcode scan',
                        )),
                  ),
                  IconButton(
                    onPressed: () {
                      _submit(barcodeFieldController?.text ?? '');
                    },
                    icon: const Icon(Icons.keyboard_return_outlined),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submit(String value) {
    widget.onDetect(BarcodeCapture(barcodes: [
      Barcode(
          format: BarcodeFormat.ean13, type: BarcodeType.isbn, rawValue: value)
    ]));
    barcodeFieldController?.text = value;
    FocusScope.of(context).requestFocus(barcodeFieldFocusNode);
  }

  @override
  void dispose() {
    barcodeFieldController?.dispose();
    super.dispose();
  }
}

class ScannerWidget extends ConsumerWidget {
  final ScannerWidgetOverlay overlay;
  final Function(BarcodeCapture) onDetect;

  const ScannerWidget(
      {super.key, required this.overlay, required this.onDetect});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      Platform.isAndroid || Platform.isIOS
          ? _MobileScannerWidget(
              overlay: overlay,
              onDetect: onDetect,
            )
          : _DesktopScannerWidget(
              overlay: overlay,
              onDetect: onDetect,
            );
}
