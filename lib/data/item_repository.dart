import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  throw UnimplementedError();
});

abstract class ItemRepository {
  Future<List<Project>> getProjects();

  Future<int> addProject({required Project project});

  Future<void> updateProject({required Project project});

  Future<void> deleteProject({required Project project});

  Future<List<Section>> getSections({required int projectId});

  Future<int> addSection({required Section section});

  Future<void> updateSection({required Section section});

  Future<void> deleteSection({required Section section});

  Future<List<ScannedItem>> getScans({required int sectionId});

  Future<int> addScan({required ScannedItem scan});

  Future<void> updateScan({required ScannedItem scan});

  Future<void> deleteScan({required ScannedItem scan});

  // settings
  Future<int> getActiveProject();

  Future<void> setActiveProject({required int projectId});
}
