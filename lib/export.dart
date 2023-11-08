import 'dart:convert';
import 'dart:io';

import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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

  final MailOptions mailOptions = MailOptions(
    body: '<b>Project:</b> ${exportSection.project.name}<br>'
        '<b>Section:</b> ${exportSection.section.name}<p>'
        'Scanned by ${exportSection.project.owner}<br>'
        'Item count: ${exportSection.items.length}<p>--<p>'
        'Attachment file name: $name',
    subject: 'Scan for `${exportSection.project.name}`',
    // recipients: ['example@example.com'],
    isHTML: true,
    attachments: [
      file.path,
    ],
  );

  await FlutterMailer.send(mailOptions);
}
