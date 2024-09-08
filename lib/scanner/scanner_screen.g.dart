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

String _$scanSoundHash() => r'3a68143bb3841c6481a872f1e1d840d6a886fce1';

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
String _$duplicateSoundHash() => r'3e553c89a182accb2f76f31f97319cf5417c555e';

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
String _$currentBarcodeHash() => r'56d70576a7a5d1cb5cb448bed590f115b5c0ba4b';

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
String _$controllerHash() => r'cb969a014f7eddfffa9aae91d3a5881696c6966a';

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
