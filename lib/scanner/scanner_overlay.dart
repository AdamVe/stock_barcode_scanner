import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScannerOverlay {
  final GlobalKey<_ScannerOverlayState>? _key;
  final VoidCallback? onDismissed;
  final Widget child;
  OverlayEntry? _entry;

  ScannerOverlay._internal(
      {required BuildContext context, required this.child, this.onDismissed})
      : _key = GlobalKey<_ScannerOverlayState>() {
    _entry = OverlayEntry(
      builder: (context) => _ScannerOverlay(
        key: _key,
        child: child,
        onDismissed: () {
          onDismissed?.call();
        },
      ),
    );
    final overlay = Overlay.of(context);
    overlay.insert(_entry!);
  }

  factory ScannerOverlay.show(
    BuildContext context,
    Widget child, [
    VoidCallback? onDismissed,
  ]) {
    return ScannerOverlay._internal(
        context: context, child: child, onDismissed: onDismissed);
  }

  Future<void> update(Widget child) async {
    await _key?.currentState?.update(child);
  }

  Future<void> hide() async {
    await _key?.currentState?.hide();
    if (_entry != null) {
      _entry?.remove();
      _entry = null;
    }
  }
}

class _ScannerOverlay extends ConsumerStatefulWidget {
  final Widget child;
  final VoidCallback? onDismissed;

  const _ScannerOverlay({super.key, required this.child, this.onDismissed});

  @override
  ConsumerState<_ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends ConsumerState<_ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Widget _child;

  static const Curve curve = Curves.easeOut;

  Future<void> _show() async {
    await _controller.forward();
  }

  Future<void> update(Widget child) async {
    setState(() {
      _child = child;
    });
  }

  Future<void> hide() async {
    await _controller.reverse(from: 1);
    widget.onDismissed?.call();
  }

  @override
  void initState() {
    super.initState();

    _child = widget.child;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _show();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedBuilder(
            builder: (context, child) {
              final double animationValue = curve.transform(_controller.value);
              return FractionalTranslation(
                translation: Offset(0, 1 - animationValue),
                child: child,
              );
            },
            animation: _controller,
            child: _child,
          ),
        ),
      ],
    );
  }
}
