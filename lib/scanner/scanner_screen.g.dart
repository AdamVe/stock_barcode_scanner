// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scanSoundHash() => r'5d86405225f191aca32a8d7ef143dcbe6df83f6e';

/// See also [scanSound].
@ProviderFor(scanSound)
final scanSoundProvider = Provider<AudioPlayer>.internal(
  scanSound,
  name: r'scanSoundProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$scanSoundHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ScanSoundRef = ProviderRef<AudioPlayer>;
String _$duplicateSoundHash() => r'1b2c2068501701d6bc028ee0587f3dac53f65694';

/// See also [duplicateSound].
@ProviderFor(duplicateSound)
final duplicateSoundProvider = Provider<AudioPlayer>.internal(
  duplicateSound,
  name: r'duplicateSoundProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$duplicateSoundHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DuplicateSoundRef = ProviderRef<AudioPlayer>;
String _$currentSectionHash() => r'4e952973b233e3aefc2f4518e167ad7c4ca52941';

/// See also [CurrentSection].
@ProviderFor(CurrentSection)
final currentSectionProvider =
    NotifierProvider<CurrentSection, Section>.internal(
  CurrentSection.new,
  name: r'currentSectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentSectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentSection = Notifier<Section>;
String _$currentBarcodeHash() => r'1bfef1a85a962c3f70f267f2aa3264ce44ffb77d';

/// See also [CurrentBarcode].
@ProviderFor(CurrentBarcode)
final currentBarcodeProvider =
    NotifierProvider<CurrentBarcode, ScannedItem>.internal(
  CurrentBarcode.new,
  name: r'currentBarcodeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentBarcodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentBarcode = Notifier<ScannedItem>;
String _$detectedBarcodeHash() => r'92757cfd343bcbff45daca10b210fe1050db100b';

/// See also [DetectedBarcode].
@ProviderFor(DetectedBarcode)
final detectedBarcodeProvider =
    NotifierProvider<DetectedBarcode, String>.internal(
  DetectedBarcode.new,
  name: r'detectedBarcodeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$detectedBarcodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DetectedBarcode = Notifier<String>;
String _$lastSeenBarcodeHash() => r'975ea17d3269495e99b83f0f25c33d3aeb016430';

/// See also [LastSeenBarcode].
@ProviderFor(LastSeenBarcode)
final lastSeenBarcodeProvider =
    NotifierProvider<LastSeenBarcode, String>.internal(
  LastSeenBarcode.new,
  name: r'lastSeenBarcodeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lastSeenBarcodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LastSeenBarcode = Notifier<String>;
String _$duplicateHash() => r'c89b999fd815ac935421b10fa7df2ac907ab5307';

/// See also [Duplicate].
@ProviderFor(Duplicate)
final duplicateProvider = NotifierProvider<Duplicate, bool>.internal(
  Duplicate.new,
  name: r'duplicateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$duplicateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Duplicate = Notifier<bool>;
String _$controllerHash() => r'c034c82166eae5d874b098d8de9b072caf0234a6';

/// See also [_Controller].
@ProviderFor(_Controller)
final _controllerProvider =
    AutoDisposeAsyncNotifierProvider<_Controller, List<ScannedItem>>.internal(
  _Controller.new,
  name: r'_controllerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$controllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Controller = AutoDisposeAsyncNotifier<List<ScannedItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
