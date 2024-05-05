// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_screen.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_ScanInfoDataImpl _$$_ScanInfoDataImplFromJson(Map<String, dynamic> json) =>
    _$_ScanInfoDataImpl(
      duplicateReported: json['duplicateReported'] as bool,
      current: json['current'] as String,
      previous: json['previous'] as String,
      scannerActive: json['scannerActive'] as bool,
    );

Map<String, dynamic> _$$_ScanInfoDataImplToJson(_$_ScanInfoDataImpl instance) =>
    <String, dynamic>{
      'duplicateReported': instance.duplicateReported,
      'current': instance.current,
      'previous': instance.previous,
      'scannerActive': instance.scannerActive,
    };

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
String _$scanInfoHash() => r'cd7de558457b9f11233609f0ac5e50939d653948';

/// See also [ScanInfo].
@ProviderFor(ScanInfo)
final scanInfoProvider = NotifierProvider<ScanInfo, ScanInfoData>.internal(
  ScanInfo.new,
  name: r'scanInfoProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$scanInfoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScanInfo = Notifier<ScanInfoData>;
String _$scanningIsActiveHash() => r'7be794ddd8070f32bb937179f0a869d7f1b3e4cd';

/// See also [ScanningIsActive].
@ProviderFor(ScanningIsActive)
final scanningIsActiveProvider =
    NotifierProvider<ScanningIsActive, bool>.internal(
  ScanningIsActive.new,
  name: r'scanningIsActiveProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scanningIsActiveHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScanningIsActive = Notifier<bool>;
String _$currentSectionHash() => r'61ed4445e0dd548f3008cd446aeb811055745a2e';

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
String _$currentBarcodeHash() => r'bf727685843b3207bb318f9848ee0b21997196d7';

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
String _$shownBarcodeHash() => r'7ad8f6133eb72c843ee5d4b7089ab5cd525850f4';

/// See also [ShownBarcode].
@ProviderFor(ShownBarcode)
final shownBarcodeProvider = NotifierProvider<ShownBarcode, String>.internal(
  ShownBarcode.new,
  name: r'shownBarcodeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$shownBarcodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShownBarcode = Notifier<String>;
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
String _$controllerHash() => r'1a225f47ec6d3aaf5c734f758e9dc7f3c1ab1e3b';

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
