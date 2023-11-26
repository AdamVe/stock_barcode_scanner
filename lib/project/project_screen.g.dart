// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$projectIdHash() => r'9c42fee681ec127c7385e00ca569217c8a46e2ad';

/// See also [ProjectId].
@ProviderFor(ProjectId)
final projectIdProvider = NotifierProvider<ProjectId, int>.internal(
  ProjectId.new,
  name: r'projectIdProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$projectIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProjectId = Notifier<int>;
String _$controllerHash() => r'be8ce4641ba3f6c571cb36bba3daed8ed636e03f';

/// See also [_Controller].
@ProviderFor(_Controller)
final _controllerProvider =
    AutoDisposeAsyncNotifierProvider<_Controller, Project?>.internal(
  _Controller.new,
  name: r'_controllerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$controllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Controller = AutoDisposeAsyncNotifier<Project?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
