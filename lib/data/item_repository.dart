import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models.dart';

part 'item_repository.g.dart';

@Riverpod(keepAlive: true)
ItemRepository itemRepository(ItemRepositoryRef ref) =>
    throw UnimplementedError();

abstract class ItemRepository {
  Future<List<Project>> getProjects({int? id});

  Future<int> createProject({required String name, String details = ''});

  Future<void> updateProject({required Project project});

  Future<void> deleteProject({required Project project});

  Future<List<Section>> getSections({required int projectId});

  Future<int> createSection(
      {required int projectId,
      required String name,
      String details,
      required String operatorName});

  Future<void> updateSection({required Section section});

  Future<void> deleteSection({required Section section});

  Future<List<ScannedItem>> getScans({required int sectionId});

  Future<int> addScan({required int sectionId, required ScannedItem scan});

  Future<void> updateScan(
      {required int scannedItemId, required ScannedItem scan});

  Future<void> deleteScan({required ScannedItem scan});

  // settings
  Future<int> getActiveProject();

  Future<void> setActiveProject(int projectId);

  Future<String> getLastOperator();

  Future<void> setLastOperator(String lastOperator);

  Future<String> getLastRecipient();

  Future<void> setLastRecipient(String lastRecipient);
}
