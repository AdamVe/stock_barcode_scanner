
import 'package:sqlite3/common.dart';

class Project {
  final int id;
  final String name;
  final DateTime created;
  final String owner;
  final int priority;

  const Project(this.id, this.name, this.created, this.owner, this.priority);

  factory Project.fromRow(Row row) => Project(
      row['id'],
      row['name'],
      DateTime.fromMillisecondsSinceEpoch(row['created']),
      row['owner'],
      row['priority']);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'created': created.millisecondsSinceEpoch,
    'owner': owner,
    'priority': priority
  };
}

class Section {
  final int id;
  final int projectId;
  final String name;
  final String note;
  final DateTime created;

  Section(this.id, this.projectId, this.name, this.note, this.created);

  factory Section.fromRow(Row row) => Section(
      row['id'],
      row['project_id'],
      row['name'],
      row['note'],
      DateTime.fromMillisecondsSinceEpoch(row['created']));

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'name': name,
    'note': note,
    'created': created.millisecondsSinceEpoch
  };
}

class ScannedItem {
  final int id;
  final int sectionId;
  final String barcode;
  final DateTime created;
  final int count;

  ScannedItem(this.id, this.sectionId, this.barcode, this.created, this.count);

  factory ScannedItem.fromRow(Row row) => ScannedItem(
      row['id'],
      row['section_id'],
      row['barcode'],
      DateTime.fromMillisecondsSinceEpoch(row['created']),
      row['count']);

  ScannedItem.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        sectionId = json['sectionId'] as int,
        barcode = json['barcode'] as String,
        created = DateTime.fromMillisecondsSinceEpoch(json['created'] as int),
        count = json['count'] as int;

  Map<String, dynamic> toJson() => {
    'id': id,
    'sectionId': sectionId,
    'barcode': barcode,
    'created': created.millisecondsSinceEpoch,
    'count': count
  };
}