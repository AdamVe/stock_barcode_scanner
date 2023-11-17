import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sqlite3/common.dart';

part 'models.freezed.dart';

part 'models.g.dart';

@freezed
class Project with _$Project {
  const factory Project({
    required int id,
    required String name,
    required String details,
    required DateTime created,
    required DateTime accessed,
  }) = _Project;

  factory Project.fromJson(Map<String, Object?> json) =>
      _$ProjectFromJson(json);
}

@freezed
class Section with _$Section {
  const factory Section({
    required int id,
    required int projectId,
    required String name,
    required String details,
    required String operatorName,
    required DateTime created,
  }) = _Section;

  factory Section.fromJson(Map<String, Object?> json) =>
      _$SectionFromJson(json);
}

@freezed
class ScannedItem with _$ScannedItem {
  const factory ScannedItem({
    required int id,
    required int sectionId,
    required String barcode,
    required DateTime created,
    required DateTime updated,
    required int count,
  }) = _ScannedItem;

  factory ScannedItem.fromJson(Map<String, Object?> json) =>
      _$ScannedItemFromJson(json);
}

class ProjectDbHelper {
  static Project projectFromRow(Row row) => Project(
        id: row['id'],
        name: row['name'],
        details: row['details'],
        created: DateTime.fromMillisecondsSinceEpoch(row['created_date']),
        accessed: DateTime.fromMillisecondsSinceEpoch(row['last_access_date']),
      );

  static Section sectionFromRow(Row row) => Section(
      id: row['id'],
      projectId: row['project_id'],
      name: row['name'],
      details: row['details'],
      operatorName: row['operator_name'],
      created: DateTime.fromMillisecondsSinceEpoch(row['created_date']));

  static ScannedItem scannedItemFromRow(Row row) => ScannedItem(
      id: row['id'],
      sectionId: row['section_id'],
      barcode: row['barcode'],
      created: DateTime.fromMillisecondsSinceEpoch(row['created_date']),
      updated: DateTime.fromMillisecondsSinceEpoch(row['updated_date']),
      count: row['count']);
}
