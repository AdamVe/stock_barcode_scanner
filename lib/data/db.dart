import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../domain/models.dart';

class DbConnector {
  static late Database _db;

  static Future<void> init() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final dbFile = join(docDir.path, 'sbs.sqlite');
      _db = sqlite3.open(dbFile,
          mode: OpenMode.readWriteCreate, uri: false, mutex: true);
      _db.execute('''
      CREATE TABLE IF NOT EXISTS $kTableProject (
        id INTEGER NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        details TEXT NOT NULL,
        created_date DATE NOT NULL,
        last_access_date DATE NOT NULL
      );
      
      CREATE TABLE IF NOT EXISTS $kTableSection (
        id INTEGER NOT NULL PRIMARY KEY,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        details TEXT NOT NULL,
        operator_name TEXT NOT NULL,
        created_date DATE NOT NULL
      );

      CREATE TABLE IF NOT EXISTS $kTableScannedItem (
        id INTEGER NOT NULL PRIMARY KEY,
        section_id INTEGER NOT NULL,
        barcode TEXT NOT NULL,
        created_date DATE NOT NULL,
        updated_date DATE NOT NULL,
        count INTEGER NOT NULL
      );
      
      CREATE TABLE IF NOT EXISTS $kTableValues (
        active_project_id INTEGER NOT NULL,
        last_operator_name TEXT NOT NULL
      );
      
      INSERT INTO $kTableValues (active_project_id, last_operator_name)
      SELECT -1, ''
      WHERE NOT EXISTS (SELECT 1 FROM $kTableValues);
    ''');
    } catch (e) {
      // ignored
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static const kTableProject = 'project';
  static const kTableSection = 'section';
  static const kTableScannedItem = 'scanned_item';
  static const kTableValues = 'preferences';

  static void close() {
    _db.dispose();
  }

  static List<Project> getProjects() {
    final rs = _db.select('''
      SELECT * FROM $kTableProject ORDER BY last_access_date DESC
    ''');
    return rs.map((row) => Project.fromRow(row)).toList();
  }

  static int addProject(Project project) {
    final date = project.created.millisecondsSinceEpoch;
    _db.execute('''
      INSERT INTO $kTableProject 
      (name, details, created_date, last_access_date) 
      VALUES('${project.name}', '${project.details}', $date, $date)
    ''');
    return _db.lastInsertRowId;
  }

  static void updateProject(Project project) {
    _db.execute('''
      UPDATE $kTableProject 
      SET name = '${project.name}',
          details = '${project.details}',
          created_date = ${project.created.millisecondsSinceEpoch},
          last_access_date = ${project.accessed.millisecondsSinceEpoch}
      WHERE
          id = ${project.id}
    ''');
  }

  static void deleteProject(Project project) {
    _db.execute('''
      DELETE FROM $kTableProject
      WHERE id = ${project.id}
    ''');
  }

  static List<Section> getSections(int projectId) {
    final rs = _db.select('''
      SELECT * FROM $kTableSection where project_id = $projectId 
      ORDER BY created_date
    ''');
    return rs.map((row) => Section.fromRow(row)).toList();
  }

  static int addSection(Section section) {
    final date = section.created.millisecondsSinceEpoch;
    _db.execute('''
      INSERT INTO $kTableSection 
      (project_id, name, details, operator_name, created_date) 
      VALUES(${section.projectId}, '${section.name}', '${section.details}',
        '${section.operatorName}', $date)
    ''');
    return _db.lastInsertRowId;
  }

  static void updateSection(Section section) {
    _db.execute('''
      UPDATE $kTableSection
      SET project_id = ${section.projectId},
          name = '${section.name}',
          details = '${section.details}',
          operator_name = '${section.operatorName}',
          created_date = ${section.created.millisecondsSinceEpoch} 
      WHERE
          id = ${section.id}
    ''');
  }

  static void deleteSection(Section section) {
    _db.execute('''
      DELETE FROM $kTableSection
      WHERE id = ${section.id}
    ''');
  }

  static List<ScannedItem> getScannedItems(int sectionId) {
    final rs = _db.select(
        'SELECT * FROM $kTableScannedItem where section_id = $sectionId '
        'ORDER BY created_date DESC');
    return rs.map((row) => ScannedItem.fromRow(row)).toList();
  }

  static int addScannedItem(ScannedItem scannedItem) {
    _db.execute('''
      INSERT INTO $kTableScannedItem 
      (section_id, barcode, created_date, updated_date, count)
      VALUES(${scannedItem.sectionId}, '${scannedItem.barcode}',
       ${scannedItem.created.millisecondsSinceEpoch}, 
       ${scannedItem.updated.millisecondsSinceEpoch}, 
       '${scannedItem.count}')
    ''');

    return _db.lastInsertRowId;
  }

  static void updateScannedItem(ScannedItem scannedItem) {
    _db.execute('''
      UPDATE $kTableScannedItem
      SET section_id = ${scannedItem.sectionId},
          barcode = '${scannedItem.barcode}',
          created_date = ${scannedItem.created.millisecondsSinceEpoch},
          updated_date = ${scannedItem.updated.millisecondsSinceEpoch},
          count = ${scannedItem.count}
      WHERE
          id = ${scannedItem.id}
    ''');
  }

  static void deleteScannedItem(ScannedItem scannedItem) {
    _db.execute('''
      DELETE FROM $kTableScannedItem
      WHERE id = ${scannedItem.id}
    ''');
  }

  static int getActiveProject() {
    final rs = _db.select('SELECT active_project_id FROM $kTableValues');
    return rs[0]['active_project_id'];
  }

  static void setActiveProject(int projectId) {
    _db.execute('''
      UPDATE $kTableValues
      SET active_project_id = $projectId
    ''');
  }

  static int getLastOperator() {
    final rs = _db.select('SELECT last_operator_name FROM $kTableValues');
    return rs[0]['last_operator_name'];
  }

  static void setLastOperator(String lastOperator) {
    _db.execute('''
      UPDATE $kTableValues
      SET last_operator_name = $lastOperator
    ''');
  }
}
