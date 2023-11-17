// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Project _$ProjectFromJson(Map<String, dynamic> json) {
  return _Project.fromJson(json);
}

/// @nodoc
mixin _$Project {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get details => throw _privateConstructorUsedError;
  DateTime get created => throw _privateConstructorUsedError;
  DateTime get accessed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProjectCopyWith<Project> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectCopyWith<$Res> {
  factory $ProjectCopyWith(Project value, $Res Function(Project) then) =
      _$ProjectCopyWithImpl<$Res, Project>;
  @useResult
  $Res call(
      {int id,
      String name,
      String details,
      DateTime created,
      DateTime accessed});
}

/// @nodoc
class _$ProjectCopyWithImpl<$Res, $Val extends Project>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? details = null,
    Object? created = null,
    Object? accessed = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      details: null == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
      accessed: null == accessed
          ? _value.accessed
          : accessed // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProjectImplCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$$ProjectImplCopyWith(
          _$ProjectImpl value, $Res Function(_$ProjectImpl) then) =
      __$$ProjectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String details,
      DateTime created,
      DateTime accessed});
}

/// @nodoc
class __$$ProjectImplCopyWithImpl<$Res>
    extends _$ProjectCopyWithImpl<$Res, _$ProjectImpl>
    implements _$$ProjectImplCopyWith<$Res> {
  __$$ProjectImplCopyWithImpl(
      _$ProjectImpl _value, $Res Function(_$ProjectImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? details = null,
    Object? created = null,
    Object? accessed = null,
  }) {
    return _then(_$ProjectImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      details: null == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
      accessed: null == accessed
          ? _value.accessed
          : accessed // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProjectImpl with DiagnosticableTreeMixin implements _Project {
  const _$ProjectImpl(
      {required this.id,
      required this.name,
      required this.details,
      required this.created,
      required this.accessed});

  factory _$ProjectImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProjectImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String details;
  @override
  final DateTime created;
  @override
  final DateTime accessed;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Project(id: $id, name: $name, details: $details, created: $created, accessed: $accessed)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Project'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('details', details))
      ..add(DiagnosticsProperty('created', created))
      ..add(DiagnosticsProperty('accessed', accessed));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.details, details) || other.details == details) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.accessed, accessed) ||
                other.accessed == accessed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, details, created, accessed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      __$$ProjectImplCopyWithImpl<_$ProjectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProjectImplToJson(
      this,
    );
  }
}

abstract class _Project implements Project {
  const factory _Project(
      {required final int id,
      required final String name,
      required final String details,
      required final DateTime created,
      required final DateTime accessed}) = _$ProjectImpl;

  factory _Project.fromJson(Map<String, dynamic> json) = _$ProjectImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get details;
  @override
  DateTime get created;
  @override
  DateTime get accessed;
  @override
  @JsonKey(ignore: true)
  _$$ProjectImplCopyWith<_$ProjectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Section _$SectionFromJson(Map<String, dynamic> json) {
  return _Section.fromJson(json);
}

/// @nodoc
mixin _$Section {
  int get id => throw _privateConstructorUsedError;
  int get projectId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get details => throw _privateConstructorUsedError;
  String get operatorName => throw _privateConstructorUsedError;
  DateTime get created => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SectionCopyWith<Section> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SectionCopyWith<$Res> {
  factory $SectionCopyWith(Section value, $Res Function(Section) then) =
      _$SectionCopyWithImpl<$Res, Section>;
  @useResult
  $Res call(
      {int id,
      int projectId,
      String name,
      String details,
      String operatorName,
      DateTime created});
}

/// @nodoc
class _$SectionCopyWithImpl<$Res, $Val extends Section>
    implements $SectionCopyWith<$Res> {
  _$SectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? projectId = null,
    Object? name = null,
    Object? details = null,
    Object? operatorName = null,
    Object? created = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      details: null == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String,
      operatorName: null == operatorName
          ? _value.operatorName
          : operatorName // ignore: cast_nullable_to_non_nullable
              as String,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SectionImplCopyWith<$Res> implements $SectionCopyWith<$Res> {
  factory _$$SectionImplCopyWith(
          _$SectionImpl value, $Res Function(_$SectionImpl) then) =
      __$$SectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int projectId,
      String name,
      String details,
      String operatorName,
      DateTime created});
}

/// @nodoc
class __$$SectionImplCopyWithImpl<$Res>
    extends _$SectionCopyWithImpl<$Res, _$SectionImpl>
    implements _$$SectionImplCopyWith<$Res> {
  __$$SectionImplCopyWithImpl(
      _$SectionImpl _value, $Res Function(_$SectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? projectId = null,
    Object? name = null,
    Object? details = null,
    Object? operatorName = null,
    Object? created = null,
  }) {
    return _then(_$SectionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      projectId: null == projectId
          ? _value.projectId
          : projectId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      details: null == details
          ? _value.details
          : details // ignore: cast_nullable_to_non_nullable
              as String,
      operatorName: null == operatorName
          ? _value.operatorName
          : operatorName // ignore: cast_nullable_to_non_nullable
              as String,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SectionImpl with DiagnosticableTreeMixin implements _Section {
  const _$SectionImpl(
      {required this.id,
      required this.projectId,
      required this.name,
      required this.details,
      required this.operatorName,
      required this.created});

  factory _$SectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SectionImplFromJson(json);

  @override
  final int id;
  @override
  final int projectId;
  @override
  final String name;
  @override
  final String details;
  @override
  final String operatorName;
  @override
  final DateTime created;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Section(id: $id, projectId: $projectId, name: $name, details: $details, operatorName: $operatorName, created: $created)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Section'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('projectId', projectId))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('details', details))
      ..add(DiagnosticsProperty('operatorName', operatorName))
      ..add(DiagnosticsProperty('created', created));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.projectId, projectId) ||
                other.projectId == projectId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.details, details) || other.details == details) &&
            (identical(other.operatorName, operatorName) ||
                other.operatorName == operatorName) &&
            (identical(other.created, created) || other.created == created));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, projectId, name, details, operatorName, created);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SectionImplCopyWith<_$SectionImpl> get copyWith =>
      __$$SectionImplCopyWithImpl<_$SectionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SectionImplToJson(
      this,
    );
  }
}

abstract class _Section implements Section {
  const factory _Section(
      {required final int id,
      required final int projectId,
      required final String name,
      required final String details,
      required final String operatorName,
      required final DateTime created}) = _$SectionImpl;

  factory _Section.fromJson(Map<String, dynamic> json) = _$SectionImpl.fromJson;

  @override
  int get id;
  @override
  int get projectId;
  @override
  String get name;
  @override
  String get details;
  @override
  String get operatorName;
  @override
  DateTime get created;
  @override
  @JsonKey(ignore: true)
  _$$SectionImplCopyWith<_$SectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScannedItem _$ScannedItemFromJson(Map<String, dynamic> json) {
  return _ScannedItem.fromJson(json);
}

/// @nodoc
mixin _$ScannedItem {
  int get id => throw _privateConstructorUsedError;
  int get sectionId => throw _privateConstructorUsedError;
  String get barcode => throw _privateConstructorUsedError;
  DateTime get created => throw _privateConstructorUsedError;
  DateTime get updated => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ScannedItemCopyWith<ScannedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScannedItemCopyWith<$Res> {
  factory $ScannedItemCopyWith(
          ScannedItem value, $Res Function(ScannedItem) then) =
      _$ScannedItemCopyWithImpl<$Res, ScannedItem>;
  @useResult
  $Res call(
      {int id,
      int sectionId,
      String barcode,
      DateTime created,
      DateTime updated,
      int count});
}

/// @nodoc
class _$ScannedItemCopyWithImpl<$Res, $Val extends ScannedItem>
    implements $ScannedItemCopyWith<$Res> {
  _$ScannedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sectionId = null,
    Object? barcode = null,
    Object? created = null,
    Object? updated = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      sectionId: null == sectionId
          ? _value.sectionId
          : sectionId // ignore: cast_nullable_to_non_nullable
              as int,
      barcode: null == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updated: null == updated
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScannedItemImplCopyWith<$Res>
    implements $ScannedItemCopyWith<$Res> {
  factory _$$ScannedItemImplCopyWith(
          _$ScannedItemImpl value, $Res Function(_$ScannedItemImpl) then) =
      __$$ScannedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int sectionId,
      String barcode,
      DateTime created,
      DateTime updated,
      int count});
}

/// @nodoc
class __$$ScannedItemImplCopyWithImpl<$Res>
    extends _$ScannedItemCopyWithImpl<$Res, _$ScannedItemImpl>
    implements _$$ScannedItemImplCopyWith<$Res> {
  __$$ScannedItemImplCopyWithImpl(
      _$ScannedItemImpl _value, $Res Function(_$ScannedItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sectionId = null,
    Object? barcode = null,
    Object? created = null,
    Object? updated = null,
    Object? count = null,
  }) {
    return _then(_$ScannedItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      sectionId: null == sectionId
          ? _value.sectionId
          : sectionId // ignore: cast_nullable_to_non_nullable
              as int,
      barcode: null == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updated: null == updated
          ? _value.updated
          : updated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScannedItemImpl with DiagnosticableTreeMixin implements _ScannedItem {
  const _$ScannedItemImpl(
      {required this.id,
      required this.sectionId,
      required this.barcode,
      required this.created,
      required this.updated,
      required this.count});

  factory _$ScannedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScannedItemImplFromJson(json);

  @override
  final int id;
  @override
  final int sectionId;
  @override
  final String barcode;
  @override
  final DateTime created;
  @override
  final DateTime updated;
  @override
  final int count;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ScannedItem(id: $id, sectionId: $sectionId, barcode: $barcode, created: $created, updated: $updated, count: $count)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ScannedItem'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('sectionId', sectionId))
      ..add(DiagnosticsProperty('barcode', barcode))
      ..add(DiagnosticsProperty('created', created))
      ..add(DiagnosticsProperty('updated', updated))
      ..add(DiagnosticsProperty('count', count));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScannedItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sectionId, sectionId) ||
                other.sectionId == sectionId) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.updated, updated) || other.updated == updated) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, sectionId, barcode, created, updated, count);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScannedItemImplCopyWith<_$ScannedItemImpl> get copyWith =>
      __$$ScannedItemImplCopyWithImpl<_$ScannedItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScannedItemImplToJson(
      this,
    );
  }
}

abstract class _ScannedItem implements ScannedItem {
  const factory _ScannedItem(
      {required final int id,
      required final int sectionId,
      required final String barcode,
      required final DateTime created,
      required final DateTime updated,
      required final int count}) = _$ScannedItemImpl;

  factory _ScannedItem.fromJson(Map<String, dynamic> json) =
      _$ScannedItemImpl.fromJson;

  @override
  int get id;
  @override
  int get sectionId;
  @override
  String get barcode;
  @override
  DateTime get created;
  @override
  DateTime get updated;
  @override
  int get count;
  @override
  @JsonKey(ignore: true)
  _$$ScannedItemImplCopyWith<_$ScannedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
