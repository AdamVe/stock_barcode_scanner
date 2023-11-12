
import 'package:stock_barcode_scanner/data/db.dart';
import 'package:stock_barcode_scanner/data/item_repository.dart';
import 'package:stock_barcode_scanner/domain/models.dart';

class SqliteItemRepository extends ItemRepository {
  @override
  Future<int> addProject({required Project project}) async {
    return DbConnector.addProject(project);
  }

  @override
  Future<int> addScan({required ScannedItem scan}) async {
    return DbConnector.addScannedItem(scan);
  }

  @override
  Future<int> addSection({required Section section}) async {
    return DbConnector.addSection(section);
  }

  @override
  Future<void> deleteProject({required Project project}) async {
    DbConnector.deleteProject(project);
  }

  @override
  Future<void> deleteScan({required ScannedItem scan}) async {
    DbConnector.deleteScannedItem(scan);
  }

  @override
  Future<void> deleteSection({required Section section}) async {
    DbConnector.deleteSection(section);
  }

  @override
  Future<List<Project>> getProjects() async {
    final projects =  DbConnector.getProjects();
    return projects;
  }

  @override
  Future<List<ScannedItem>> getScans({required int sectionId}) async {
    return DbConnector.getScannedItems(sectionId);
  }

  @override
  Future<List<Section>> getSections({required int projectId}) async {
    return DbConnector.getSections(projectId);
  }

  @override
  Future<void> updateProject({required Project project}) async {
    DbConnector.updateProject(project);
  }

  @override
  Future<void> updateScan({required ScannedItem scan}) async {
    DbConnector.updateScannedItem(scan);
  }

  @override
  Future<void> updateSection({required Section section}) async {
    DbConnector.updateSection(section);
  }
}
