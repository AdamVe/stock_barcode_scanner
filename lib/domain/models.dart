import 'package:sqlite3/common.dart';

class Project {
  final int id;
  final String name;
  final String details;
  final DateTime created;
  final DateTime accessed;

  const Project(this.id, this.name, this.details, this.created, this.accessed);

  factory Project.fromRow(Row row) => Project(
        row['id'],
        row['name'],
        row['details'],
        DateTime.fromMillisecondsSinceEpoch(row['created_date']),
        DateTime.fromMillisecondsSinceEpoch(row['last_access_date']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'details': name,
        'created_date': created.millisecondsSinceEpoch,
        'last_access_date': accessed.millisecondsSinceEpoch
      };
}

class Section {
  final int id;
  final int projectId;
  final String name;
  final String details;
  final String operatorName;
  final DateTime created;

  Section(
    this.id,
    this.projectId,
    this.name,
    this.details,
    this.operatorName,
    this.created,
  );

  factory Section.fromRow(Row row) => Section(
      row['id'],
      row['project_id'],
      row['name'],
      row['details'],
      row['operator_name'],
      DateTime.fromMillisecondsSinceEpoch(row['created_date']));

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'name': name,
        'details': details,
        'operator_name': operatorName,
        'created_date': created.millisecondsSinceEpoch
      };
}

class ScannedItem {
  final int id;
  final int sectionId;
  final String barcode;
  final DateTime created;
  final DateTime updated;
  final int count;

  ScannedItem(
    this.id,
    this.sectionId,
    this.barcode,
    this.created,
    this.updated,
    this.count,
  );

  factory ScannedItem.fromRow(Row row) => ScannedItem(
      row['id'],
      row['section_id'],
      row['barcode'],
      DateTime.fromMillisecondsSinceEpoch(row['created_date']),
      DateTime.fromMillisecondsSinceEpoch(row['updated_date']),
      row['count']);

  ScannedItem.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        sectionId = json['section_id'] as int,
        barcode = json['barcode'] as String,
        created =
            DateTime.fromMillisecondsSinceEpoch(json['created_date'] as int),
        updated =
            DateTime.fromMillisecondsSinceEpoch(json['updated_date'] as int),
        count = json['count'] as int;

  Map<String, dynamic> toJson() => {
        'id': id,
        'section_id': sectionId,
        'barcode': barcode,
        'created_date': created.millisecondsSinceEpoch,
        'updated_date': updated.millisecondsSinceEpoch,
        'count': count
      };
}
