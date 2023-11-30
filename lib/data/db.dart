import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../domain/model_helper.dart';
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
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        details TEXT NOT NULL,
        created_date DATE NOT NULL,
        last_access_date DATE NOT NULL
      );
      
      CREATE TABLE IF NOT EXISTS $kTableSection (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        details TEXT NOT NULL,
        operator_name TEXT NOT NULL,
        created_date DATE NOT NULL
      );

      CREATE TABLE IF NOT EXISTS $kTableScannedItem (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        section_id INTEGER NOT NULL,
        barcode TEXT NOT NULL,
        created_date DATE NOT NULL,
        updated_date DATE NOT NULL,
        count INTEGER NOT NULL
      );
      
      CREATE TABLE IF NOT EXISTS $kTableValues (
        active_project_id INTEGER NOT NULL,
        last_operator_name TEXT NOT NULL,
        last_recipient_name TEXT NOT_NULL
      );
      
      INSERT INTO $kTableValues (active_project_id, last_operator_name, last_recipient_name)
      SELECT -1, '', ''
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

  static ResultSet _getProjectEntities({int? id}) {
    final query =
        'SELECT * FROM $kTableProject ${(id != null) ? 'WHERE id = $id' : ''} '
        'ORDER BY last_access_date DESC';
    return _db.select(query);
  }

  static List<Project> getProjects({int? id}) {
    final projects = _getProjectEntities(id: id);
    return projects.map((row) {
      final sections = getSections(row['id']);
      return ProjectDbHelper.projectFromRow(row, sections);
    }).toList(growable: false);
  }

  static int createProject(String name, String details, DateTime createDate) {
    final date = createDate.millisecondsSinceEpoch;
    _db.execute('''
      INSERT INTO $kTableProject 
      (name, details, created_date, last_access_date) 
      VALUES('$name', '$details', $date, $date)
    ''');
    return _db.lastInsertRowId;
  }

  static void updateProject(
      {required int projectId,
      required String projectName,
      required String projectDetails,
      required DateTime lastAccessed}) {
    _db.execute('''
      UPDATE $kTableProject 
      SET name = '$projectName',
          details = '$projectDetails',
          last_access_date = ${lastAccessed.millisecondsSinceEpoch}
      WHERE
          id = $projectId
    ''');
  }

  static void deleteProject(int projectId) {
    _db.execute('''
      DELETE FROM $kTableProject
      WHERE id = $projectId
    ''');
  }

  static List<Section> getSections(int projectId) {
    final rs = _db.select('''
      SELECT * FROM $kTableSection where project_id = $projectId 
      ORDER BY created_date
    ''');
    return rs.map((row) {
      final items = getScannedItems(row['id']);
      return ProjectDbHelper.sectionFromRow(row, items);
    }).toList(growable: false);
  }

  static int createSection(int projectId, String name, String details,
      String operatorName, DateTime createDate) {
    final date = createDate.millisecondsSinceEpoch;
    _db.execute('''
      INSERT INTO $kTableSection 
      (project_id, name, details, operator_name, created_date) 
      VALUES($projectId, '$name', '$details', '$operatorName', $date)
    ''');
    return _db.lastInsertRowId;
  }

  static void updateSection(
      {required int sectionId,
      required String sectionName,
      required String sectionDetails,
      required String operatorName}) {
    _db.execute('''
      UPDATE $kTableSection
      SET name = '$sectionName',
          details = '$sectionDetails',
          operator_name = '$operatorName' 
      WHERE
          id = $sectionId
    ''');
  }

  static void deleteSection(int sectionId) {
    _db.execute('''
      DELETE FROM $kTableScannedItem
      WHERE section_id = $sectionId
    ''');

    _db.execute('''
      DELETE FROM $kTableSection
      WHERE id = $sectionId
    ''');
  }

  static List<ScannedItem> getScannedItems(int sectionId) {
    final rs = _db.select(
        'SELECT * FROM $kTableScannedItem where section_id = $sectionId '
        'ORDER BY created_date DESC');
    return rs.map((row) => ProjectDbHelper.scannedItemFromRow(row)).toList();
  }

  static int createScannedItem(
      int sectionId, String barcode, DateTime createDate, int count) {
    final date = createDate.millisecondsSinceEpoch;
    _db.execute('''
      INSERT INTO $kTableScannedItem 
      (section_id, barcode, created_date, updated_date, count)
      VALUES($sectionId, '$barcode', $date, $date, $count)
    ''');

    return _db.lastInsertRowId;
  }

  static void updateScannedItem(int scannedItemId, ScannedItem scannedItem) {
    final updatedDate = scannedItem.updated.millisecondsSinceEpoch;
    _db.execute('''
      UPDATE $kTableScannedItem
      SET barcode = '${scannedItem.barcode}',
          updated_date = $updatedDate,
          count = ${scannedItem.count}
      WHERE
          id = $scannedItemId
    ''');
  }

  static void deleteScannedItem(int scannedItemId) {
    _db.execute('''
      DELETE FROM $kTableScannedItem
      WHERE id = $scannedItemId
    ''');
  }

  static int getActiveProject() {
    final values =
        _db.select('SELECT active_project_id FROM $kTableValues').firstOrNull;

    int activeProjectId = values?['active_project_id'] ?? -1;

    return activeProjectId != -1
        ? activeProjectId
        : _getProjectEntities().firstOrNull?['id'] ?? -1;
  }

  static void setActiveProject(int projectId) {
    _db.execute('UPDATE $kTableValues SET active_project_id = $projectId');
  }

  static String getLastOperator() {
    final values =
        _db.select('SELECT last_operator_name FROM $kTableValues').firstOrNull;

    return values?['last_operator_name'] ?? '';
  }

  static void setLastOperator(String lastOperator) {
    _db.execute('UPDATE $kTableValues SET last_operator_name = $lastOperator');
  }

  static String getLastRecipient() {
    final values =
        _db.select('SELECT last_recipient_name FROM $kTableValues').firstOrNull;

    return values?['last_recipient_name'] ?? '';
  }

  static void setLastRecipient(String lastRecipient) {
    _db.execute(
        'UPDATE $kTableValues SET last_recipient_name = \'$lastRecipient\'');
  }
}
