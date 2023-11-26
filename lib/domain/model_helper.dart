

import 'package:sqlite3/common.dart';

import 'models.dart';

class ProjectDbHelper {
  static Project projectFromRow(Row row, List<Section> sections) => Project(
      id: row['id'],
      name: row['name'],
      details: row['details'],
      created: DateTime.fromMillisecondsSinceEpoch(row['created_date']),
      accessed: DateTime.fromMillisecondsSinceEpoch(row['last_access_date']),
      sections: sections);

  static Section sectionFromRow(Row row, List<ScannedItem> items) =>
      Section(
          id: row['id'],
          name: row['name'],
          details: row['details'],
          operatorName: row['operator_name'],
          created: DateTime.fromMillisecondsSinceEpoch(row['created_date']),
          items: items);

  static ScannedItem scannedItemFromRow(Row row) => ScannedItem(
      id: row['id'],
      barcode: row['barcode'],
      created: DateTime.fromMillisecondsSinceEpoch(row['created_date']),
      updated: DateTime.fromMillisecondsSinceEpoch(row['updated_date']),
      count: row['count']);
}
