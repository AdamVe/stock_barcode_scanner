// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scanner_screen.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScanInfoData _$ScanInfoDataFromJson(Map<String, dynamic> json) {
  return __ScanInfoData.fromJson(json);
}

/// @nodoc
mixin _$ScanInfoData {
  bool get duplicateReported => throw _privateConstructorUsedError;
  String get current => throw _privateConstructorUsedError;
  String get previous => throw _privateConstructorUsedError;
  bool get scannerActive => throw _privateConstructorUsedError;

  /// Serializes this ScanInfoData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScanInfoData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScanInfoDataCopyWith<ScanInfoData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScanInfoDataCopyWith<$Res> {
  factory $ScanInfoDataCopyWith(
          ScanInfoData value, $Res Function(ScanInfoData) then) =
      _$ScanInfoDataCopyWithImpl<$Res, ScanInfoData>;
  @useResult
  $Res call(
      {bool duplicateReported,
      String current,
      String previous,
      bool scannerActive});
}

/// @nodoc
class _$ScanInfoDataCopyWithImpl<$Res, $Val extends ScanInfoData>
    implements $ScanInfoDataCopyWith<$Res> {
  _$ScanInfoDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScanInfoData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? duplicateReported = null,
    Object? current = null,
    Object? previous = null,
    Object? scannerActive = null,
  }) {
    return _then(_value.copyWith(
      duplicateReported: null == duplicateReported
          ? _value.duplicateReported
          : duplicateReported // ignore: cast_nullable_to_non_nullable
              as bool,
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as String,
      previous: null == previous
          ? _value.previous
          : previous // ignore: cast_nullable_to_non_nullable
              as String,
      scannerActive: null == scannerActive
          ? _value.scannerActive
          : scannerActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_ScanInfoDataImplCopyWith<$Res>
    implements $ScanInfoDataCopyWith<$Res> {
  factory _$$_ScanInfoDataImplCopyWith(
          _$_ScanInfoDataImpl value, $Res Function(_$_ScanInfoDataImpl) then) =
      __$$_ScanInfoDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool duplicateReported,
      String current,
      String previous,
      bool scannerActive});
}

/// @nodoc
class __$$_ScanInfoDataImplCopyWithImpl<$Res>
    extends _$ScanInfoDataCopyWithImpl<$Res, _$_ScanInfoDataImpl>
    implements _$$_ScanInfoDataImplCopyWith<$Res> {
  __$$_ScanInfoDataImplCopyWithImpl(
      _$_ScanInfoDataImpl _value, $Res Function(_$_ScanInfoDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScanInfoData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? duplicateReported = null,
    Object? current = null,
    Object? previous = null,
    Object? scannerActive = null,
  }) {
    return _then(_$_ScanInfoDataImpl(
      duplicateReported: null == duplicateReported
          ? _value.duplicateReported
          : duplicateReported // ignore: cast_nullable_to_non_nullable
              as bool,
      current: null == current
          ? _value.current
          : current // ignore: cast_nullable_to_non_nullable
              as String,
      previous: null == previous
          ? _value.previous
          : previous // ignore: cast_nullable_to_non_nullable
              as String,
      scannerActive: null == scannerActive
          ? _value.scannerActive
          : scannerActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ScanInfoDataImpl
    with DiagnosticableTreeMixin
    implements __ScanInfoData {
  const _$_ScanInfoDataImpl(
      {required this.duplicateReported,
      required this.current,
      required this.previous,
      required this.scannerActive});

  factory _$_ScanInfoDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$_ScanInfoDataImplFromJson(json);

  @override
  final bool duplicateReported;
  @override
  final String current;
  @override
  final String previous;
  @override
  final bool scannerActive;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ScanInfoData(duplicateReported: $duplicateReported, current: $current, previous: $previous, scannerActive: $scannerActive)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ScanInfoData'))
      ..add(DiagnosticsProperty('duplicateReported', duplicateReported))
      ..add(DiagnosticsProperty('current', current))
      ..add(DiagnosticsProperty('previous', previous))
      ..add(DiagnosticsProperty('scannerActive', scannerActive));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ScanInfoDataImpl &&
            (identical(other.duplicateReported, duplicateReported) ||
                other.duplicateReported == duplicateReported) &&
            (identical(other.current, current) || other.current == current) &&
            (identical(other.previous, previous) ||
                other.previous == previous) &&
            (identical(other.scannerActive, scannerActive) ||
                other.scannerActive == scannerActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, duplicateReported, current, previous, scannerActive);

  /// Create a copy of ScanInfoData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$_ScanInfoDataImplCopyWith<_$_ScanInfoDataImpl> get copyWith =>
      __$$_ScanInfoDataImplCopyWithImpl<_$_ScanInfoDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ScanInfoDataImplToJson(
      this,
    );
  }
}

abstract class __ScanInfoData implements ScanInfoData {
  const factory __ScanInfoData(
      {required final bool duplicateReported,
      required final String current,
      required final String previous,
      required final bool scannerActive}) = _$_ScanInfoDataImpl;

  factory __ScanInfoData.fromJson(Map<String, dynamic> json) =
      _$_ScanInfoDataImpl.fromJson;

  @override
  bool get duplicateReported;
  @override
  String get current;
  @override
  String get previous;
  @override
  bool get scannerActive;

  /// Create a copy of ScanInfoData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$_ScanInfoDataImplCopyWith<_$_ScanInfoDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
