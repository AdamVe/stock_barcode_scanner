import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'db.dart';

class ExportSection {
  final Section section;
  late final Project project;
  late final List<ScannedItem> items;

  ExportSection(this.section) {
    project = DbConnector.getProjects()
        .where((project) => project.id == section.projectId)
        .first;
    items = DbConnector.getScannedItems(section.id);
  }

  Map<String, dynamic> toJson() =>
      {'project': project, 'section': section, 'items': items};
}

Future<void> export(Section section) async {
  final exportSection = ExportSection(section);
  final encoded = jsonEncode(exportSection);

  final name = '${exportSection.project.name}_${section.name} by '
      '${exportSection.project.owner}.json';
  final tempDir = await getTemporaryDirectory();
  final file = File(join(tempDir.path, name));
  file.writeAsString(encoded);
  XFile xFile = XFile(file.path);
  await Share.shareXFiles([xFile],
      text: 'Export section', subject: 'Export section');
}
