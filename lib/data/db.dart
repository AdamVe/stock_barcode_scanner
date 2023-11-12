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
        created DATE NOT NULL,
        owner TEXT NOT NULL,
        priority INTEGER NOT NULL
      );
      
      CREATE TABLE IF NOT EXISTS $kTableSection (
        id INTEGER NOT NULL PRIMARY KEY,
        project_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        note TEXT NOT NULL,
        created DATE NOT NULL
      );

      CREATE TABLE IF NOT EXISTS $kTableScannedItem (
        id INTEGER NOT NULL PRIMARY KEY,
        section_id INTEGER NOT NULL,
        barcode TEXT NOT NULL,
        created DATE NOT NULL,
        count INTEGER NOT NULL
      );
    ''');
    } catch (e) {
      // ignored
    }
  }

  static const kTableProject = 'project';
  static const kTableSection = 'section';
  static const kTableScannedItem = 'scanned_item';

  static void close() {
    _db.dispose();
  }

  static List<Project> getProjects() {
    final rs = _db.select('SELECT * FROM $kTableProject ORDER BY priority');
    return rs.map((row) => Project.fromRow(row)).toList();
  }

  static int addProject(Project project) {
    _db.execute('''
      INSERT INTO $kTableProject (name, created, owner, priority) 
      VALUES('${project.name}', ${project.created.millisecondsSinceEpoch}, 
      '${project.owner}', ${project.priority})
    ''');
    return _db.lastInsertRowId;
  }

  static void updateProject(Project project) {
    _db.execute('''
      UPDATE $kTableProject 
      SET name = '${project.name}',
          created = ${project.created.millisecondsSinceEpoch},
          owner = '${project.owner}',
          priority = ${project.priority}
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
    final rs = _db.select(
        'SELECT * FROM $kTableSection where project_id = $projectId ORDER BY created');
    return rs.map((row) => Section.fromRow(row)).toList();
  }

  static int addSection(Section section) {
    _db.execute('''
      INSERT INTO $kTableSection (project_id, name, note, created) 
      VALUES(${section.projectId}, '${section.name}', '${section.note}',
       ${section.created.millisecondsSinceEpoch})
    ''');
    return _db.lastInsertRowId;
  }

  static void updateSection(Section section) {
    _db.execute('''
      UPDATE $kTableSection
      SET project_id = ${section.projectId},
          name = '${section.name}',
          note = '${section.note}',
          created = ${section.created.millisecondsSinceEpoch} 
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
        'ORDER BY created DESC');
    return rs.map((row) => ScannedItem.fromRow(row)).toList();
  }

  static int addScannedItem(ScannedItem scannedItem) {
    _db.execute('''
      INSERT INTO $kTableScannedItem (section_id, barcode, created, count)
      VALUES(${scannedItem.sectionId}, '${scannedItem.barcode}',
       ${scannedItem.created.millisecondsSinceEpoch}, '${scannedItem.count}')
    ''');

    return _db.lastInsertRowId;
  }

  static void updateScannedItem(ScannedItem scannedItem) {
    _db.execute('''
      UPDATE $kTableScannedItem
      SET section_id = ${scannedItem.sectionId},
          barcode = '${scannedItem.barcode}',
          created = ${scannedItem.created.millisecondsSinceEpoch},
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
}
