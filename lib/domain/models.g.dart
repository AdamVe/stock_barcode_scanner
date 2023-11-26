// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProjectImpl _$$ProjectImplFromJson(Map<String, dynamic> json) =>
    _$ProjectImpl(
      id: json['id'] as int,
      name: json['name'] as String,
      details: json['details'] as String,
      created: DateTime.parse(json['created'] as String),
      accessed: DateTime.parse(json['accessed'] as String),
      sections: (json['sections'] as List<dynamic>)
          .map((e) => Section.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ProjectImplToJson(_$ProjectImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'details': instance.details,
      'created': instance.created.toIso8601String(),
      'accessed': instance.accessed.toIso8601String(),
      'sections': instance.sections,
    };

_$SectionImpl _$$SectionImplFromJson(Map<String, dynamic> json) =>
    _$SectionImpl(
      id: json['id'] as int,
      name: json['name'] as String,
      details: json['details'] as String,
      operatorName: json['operatorName'] as String,
      created: DateTime.parse(json['created'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => ScannedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$SectionImplToJson(_$SectionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'details': instance.details,
      'operatorName': instance.operatorName,
      'created': instance.created.toIso8601String(),
      'items': instance.items,
    };

_$ScannedItemImpl _$$ScannedItemImplFromJson(Map<String, dynamic> json) =>
    _$ScannedItemImpl(
      id: json['id'] as int,
      barcode: json['barcode'] as String,
      created: DateTime.parse(json['created'] as String),
      updated: DateTime.parse(json['updated'] as String),
      count: json['count'] as int,
    );

Map<String, dynamic> _$$ScannedItemImplToJson(_$ScannedItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'barcode': instance.barcode,
      'created': instance.created.toIso8601String(),
      'updated': instance.updated.toIso8601String(),
      'count': instance.count,
    };
