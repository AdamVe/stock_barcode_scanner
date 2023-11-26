import '../data/db.dart';
import '../data/item_repository.dart';
import '../domain/models.dart';

class SqliteItemRepository extends ItemRepository {
  @override
  Future<int> createProject({required String name, String details = ''}) async {
    final createdAccessedDate = DateTime.now();
    return DbConnector.createProject(name, details, createdAccessedDate);
  }

  @override
  Future<int> addScan(
      {required int sectionId, required ScannedItem scan}) async {
    final createdDate = DateTime.now();
    return DbConnector.createScannedItem(
        sectionId, scan.barcode, createdDate, scan.count);
  }

  @override
  Future<int> createSection(
      {required int projectId,
      required String name,
      String details = '',
      required String operatorName}) async {
    final createdDate = DateTime.now();
    return DbConnector.createSection(
        projectId, name, details, operatorName, createdDate);
  }

  @override
  Future<void> deleteProject({required Project project}) async =>
      DbConnector.deleteProject(project.id);

  @override
  Future<void> deleteScan({required ScannedItem scan}) async =>
      DbConnector.deleteScannedItem(scan.id);

  @override
  Future<void> deleteSection({required Section section}) async =>
      DbConnector.deleteSection(section.id);

  @override
  Future<List<ScannedItem>> getScans({required int sectionId}) async =>
      DbConnector.getScannedItems(sectionId);

  @override
  Future<List<Section>> getSections({required int projectId}) async =>
      DbConnector.getSections(projectId);

  @override
  Future<List<Project>> getProjects({int? id}) async =>
      DbConnector.getProjects(id: id);

  @override
  Future<void> updateProject({required Project project}) async =>
      DbConnector.updateProject(
          projectId: project.id,
          projectName: project.name,
          projectDetails: project.details,
          lastAccessed: project.accessed);

  @override
  Future<void> updateScan(
          {required int scannedItemId, required ScannedItem scan}) async =>
      DbConnector.updateScannedItem(scannedItemId, scan);

  @override
  Future<void> updateSection({required Section section}) async =>
      DbConnector.updateSection(
          sectionId: section.id,
          sectionName: section.name,
          sectionDetails: section.details,
          operatorName: section.operatorName);

  @override
  Future<int> getActiveProject() async => DbConnector.getActiveProject();

  @override
  Future<void> setActiveProject(int projectId) async =>
      DbConnector.setActiveProject(projectId);

  @override
  Future<String> getLastOperator() async => DbConnector.getLastOperator();

  @override
  Future<void> setLastOperator(String lastOperator) async =>
      DbConnector.setLastOperator(lastOperator);
}
