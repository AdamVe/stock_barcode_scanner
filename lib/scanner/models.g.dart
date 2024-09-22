// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scanSoundHash() => r'5ba51decba984fc45361ec651e813f88dadc8b7a';

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
String _$duplicateSoundHash() => r'f79b122cd0058c1504ff21b4a1f9eacffae61051';

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
String _$scannedCodeHash() => r'a7c4660911c5b87cdb13addb87afe8f0fc105f5d';

/// See also [ScannedCode].
@ProviderFor(ScannedCode)
final scannedCodeProvider =
    AutoDisposeNotifierProvider<ScannedCode, String?>.internal(
  ScannedCode.new,
  name: r'scannedCodeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$scannedCodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScannedCode = AutoDisposeNotifier<String?>;
String _$scannerEventsHash() => r'b11bc62e86d115f0019a5f2294c2c8a54d746242';

/// See also [ScannerEvents].
@ProviderFor(ScannerEvents)
final scannerEventsProvider =
    AutoDisposeNotifierProvider<ScannerEvents, ScannerEvent>.internal(
  ScannerEvents.new,
  name: r'scannerEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scannerEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScannerEvents = AutoDisposeNotifier<ScannerEvent>;
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
String _$sectionControllerHash() => r'e113cebf13b4a57e4455531c9ed285593443fcaa';

/// See also [SectionController].
@ProviderFor(SectionController)
final sectionControllerProvider = AutoDisposeAsyncNotifierProvider<
    SectionController, List<ScannedItem>>.internal(
  SectionController.new,
  name: r'sectionControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sectionControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SectionController = AutoDisposeAsyncNotifier<List<ScannedItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
