import 'package:freezed_annotation/freezed_annotation.dart';

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
    required List<Section> sections,
  }) = _Project;

  factory Project.fromJson(Map<String, Object?> json) =>
      _$ProjectFromJson(json);
}

@freezed
class Section with _$Section {
  const factory Section({
    required int id,
    required String name,
    required String details,
    required String operatorName,
    required DateTime created,
    required List<ScannedItem> items,
  }) = _Section;

  factory Section.fromJson(Map<String, Object?> json) =>
      _$SectionFromJson(json);
}

@freezed
class ScannedItem with _$ScannedItem {
  const factory ScannedItem({
    required int id,
    required String barcode,
    required DateTime created,
    required DateTime updated,
    required int count,
  }) = _ScannedItem;

  factory ScannedItem.fromJson(Map<String, Object?> json) =>
      _$ScannedItemFromJson(json);
}
