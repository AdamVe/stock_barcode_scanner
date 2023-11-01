import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class Project {
  final int id;
  final String name;
  final DateTime created;
  final String owner;
  final int priority;

  const Project(this.id, this.name, this.created, this.owner, this.priority);
}

class DbConnector {
  final Database _db;

  static const kTableProject = 'project';

  static Future<DbConnector> getConnector() async {
    final applicationDocumentsDirectory =
        await getApplicationDocumentsDirectory();
    final dbFile = join(applicationDocumentsDirectory.path, 'sbs.sqlite');
    final db = sqlite3.open(dbFile,
        mode: OpenMode.readWriteCreate, uri: false, mutex: true);
    db.execute('''
      CREATE TABLE IF NOT EXISTS $kTableProject (
        id INTEGER NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        created DATE NOT NULL,
        owner TEXT NOT NULL,
        priority INTEGER NOT NULL
      );
    ''');
    return DbConnector._(db);
  }

  const DbConnector._(this._db);

  void close() {
    _db.dispose();
  }

  List<Project> getProjects() {
    List<Project> projects = [];
    final projectsResultSet =
        _db.select('SELECT * FROM $kTableProject ORDER BY priority');

    for (final Row row in projectsResultSet) {
      projects.add(Project(
          row['id'],
          row['name'],
          DateTime.fromMillisecondsSinceEpoch(row['created']),
          row['owner'],
          row['priority']));
    }

    return projects;
  }

  void addProject(Project project) {
    _db.execute('''
      INSERT INTO $kTableProject (name, created, owner, priority) 
      VALUES('${project.name}', ${project.created.millisecondsSinceEpoch}, '${project.owner}', ${project.priority})
    ''');
  }

  void deleteProject(Project project) {
    _db.execute('''
      DELETE FROM $kTableProject
      WHERE id = ${project.id}
    ''');
  }
}
