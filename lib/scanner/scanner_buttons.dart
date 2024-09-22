import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stock_barcode_scanner/scanner/models.dart';

class SoundButton extends ConsumerWidget {
  final ValueNotifier<bool> soundController;

  const SoundButton(this.soundController, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
        valueListenable: soundController,
        builder: (context, state, child) {
          final soundIsOn = state == true;
          return IconButton.filledTonal(
              onPressed: () async =>
                  soundController.value = !soundController.value,
              icon: Icon(soundIsOn ? Symbols.volume_up : Symbols.volume_off));
        });
  }
}

class TorchButton extends ConsumerWidget {
  final MobileScannerController controller;

  const TorchButton(this.controller, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, state, child) {
          final torchIsOn = state.torchState == TorchState.on;
          return IconButton.filledTonal(
              onPressed: () async => await controller.toggleTorch(),
              icon: Icon(torchIsOn ? Symbols.flash_on : Symbols.flash_off));
        });
  }
}

class PauseResumeScanningButton extends ConsumerWidget {
  const PauseResumeScanningButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scannerActive = ref.watch(scannerActiveProvider);
    return TextButton.icon(
        onPressed: () async {
          ref.read(scannerActiveProvider.notifier).state = !scannerActive;
        },
        label: scannerActive
            ? const Text('Pause scanning')
            : const Text('Resume scanning'),
        icon: Icon(
          scannerActive ? Symbols.pause : Symbols.resume,
        ));
  }
}

class ReviewButton extends ConsumerWidget {
  final Function() onPressed;

  const ReviewButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
        onPressed: onPressed,
        child: const Icon(
          Symbols.expand_less,
        ));
  }
}
