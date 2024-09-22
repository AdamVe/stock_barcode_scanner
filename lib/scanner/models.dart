import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/item_repository.dart';
import '../domain/models.dart';

part 'models.g.dart';

sealed class ScannerEvent {
  const ScannerEvent();
}

class NoCode extends ScannerEvent {}

class NewCode extends ScannerEvent {
  final String code;
  const NewCode(this.code);
}

class DuplicateCode extends ScannerEvent {
  final String code;
  const DuplicateCode(this.code);
}

class CandidateCode extends ScannerEvent {
  final String code;
  const CandidateCode(this.code);
}

@riverpod
class ScannedCode extends _$ScannedCode {
  late final KeepAliveLink _link;
  int clearCounter = 0;
  Timer? checkTimer;

  @override
  String? build() {
    _link = ref.keepAlive();
    return null;
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

      _promoteCandidate = Timer(const Duration(milliseconds: 300), () {
        _lastCode = _candidateCode;
        if (state is! NewCode || ((state as NewCode).code != _candidateCode)) {
          state = NewCode(_candidateCode!);
        }
      });

      _candidateCode = scannedCode;
      return CandidateCode(scannedCode);
    }

    return NoCode();
  }
}

@Riverpod(keepAlive: true)
class CurrentSection extends _$CurrentSection {
  @override
  Section build() => Section(
      id: 0,
      name: '',
      details: '',
      operatorName: '',
      created: DateTime(0),
      items: []);

  void update(Section section) {
    state = section;
  }
}

@Riverpod(keepAlive: true)
AudioPlayer scanSound(ScanSoundRef ref) {
  final player = AudioPlayer()
    ..setSource(AssetSource('sounds/success_2.wav'))
    ..setReleaseMode(ReleaseMode.stop);

  ref.onDispose(() {
    player.dispose();
  });

  return player;
}

@Riverpod(keepAlive: true)
AudioPlayer duplicateSound(DuplicateSoundRef ref) {
  final player = AudioPlayer()
    ..setSource(AssetSource('sounds/fail_1.wav'))
    ..setReleaseMode(ReleaseMode.stop);

  ref.onDispose(() {
    player.dispose();
  });
  return player;
}

@riverpod
class SectionController extends _$SectionController {
  Future<List<ScannedItem>> _read() async {
    final sectionId =
        ref.watch(currentSectionProvider.select((section) => section.id));
    return ref.watch(itemRepositoryProvider
        .select((repository) => repository.getScans(sectionId: sectionId)));
  }

  @override
  FutureOr<List<ScannedItem>> build() {
    return _read();
  }

  Future<void> updateScannedItem(ScannedItem scannedItem) async {
    await ref
        .read(itemRepositoryProvider)
        .updateScan(scannedItemId: scannedItem.id, scan: scannedItem);
    await loadScannedItems();
  }

  Future<int> addScannedItem(int sectionId, ScannedItem scannedItem) async {
    int id = await ref
        .read(itemRepositoryProvider)
        .addScan(sectionId: sectionId, scan: scannedItem);
    await loadScannedItems();
    return id;
  }

  Future<ScannedItem?> getLatest(int sectionId) async {
    // TODO: optimize this
    final allScans =
        await ref.read(itemRepositoryProvider).getScans(sectionId: sectionId);
    return allScans.firstOrNull;
  }

  Future<void> deleteScannedItem(ScannedItem scannedItem) async {
    await ref.read(itemRepositoryProvider).deleteScan(scan: scannedItem);
    await loadScannedItems();
  }

  Future<void> loadScannedItems() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _read());
  }
}
