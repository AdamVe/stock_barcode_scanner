import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'models.g.dart';

class ScannerEvent {
  const ScannerEvent();
}

class NoCode extends ScannerEvent {}

class _ScannerCodeEvent extends ScannerEvent {
  final String code;

  const _ScannerCodeEvent(this.code);
}

class NewCode extends _ScannerCodeEvent {
  const NewCode(super.code);
}

class DuplicateCode extends _ScannerCodeEvent {
  const DuplicateCode(super.code);
}

class CandidateCode extends _ScannerCodeEvent {
  const CandidateCode(super.code);
}

@riverpod
class ScannedCode extends _$ScannedCode {
  late final KeepAliveLink _link;
  int clearCounter = 0;
  Timer? checkTimer;

  @override
  String? build() {
    _link = ref.keepAlive();
    return '';
  }

  void dispose() {
    _link.close();
  }

  void _clear() {
    _set(null);
  }

  void _set(String? value) {
    if (value != state) {
      state = value;
    }
  }

  void onDetect(String? code) async {
    startTimer() => checkTimer = Timer(const Duration(milliseconds: 200), () {
          clearCounter++;
          if (clearCounter > 3) {
            _clear();
          } else {
            startTimer();
          }
        });

    checkTimer?.cancel();
    clearCounter = 0;
    _set(code);
    startTimer();
  }
}

@riverpod
class ScannerEvents extends _$ScannerEvents {
  String? _candidateCode;
  String? _lastCode;
  Timer? _promoteCandidate;

  @override
  ScannerEvent build() {
    _promoteCandidate?.cancel();

    final scannedCode = ref.watch(scannedCodeProvider);

    if (scannedCode != null) {
      if (scannedCode == _lastCode) {
        return DuplicateCode(scannedCode);
      }

      _promoteCandidate = Timer(const Duration(milliseconds: 2500), () {
        _lastCode = _candidateCode;
        state = NewCode(_candidateCode!);
      });

      _candidateCode = scannedCode;
      return CandidateCode(scannedCode);
    }

    return NoCode();
  }
}
