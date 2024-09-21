// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_screen.dart';

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
String _$controllerHash() => r'549ddccc307f038253fcbc4f0f15abb5bd76d1c6';

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
