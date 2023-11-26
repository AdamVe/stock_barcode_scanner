import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'domain/models.dart';

class ExportProject {
  final Project project;

  const ExportProject({required this.project});

  Map<String, dynamic> toJson() =>
      {'name': project.name, 'details': project.details};
}

class ExportSection {
  final ExportProject exportProject;
  final Section section;

  ExportSection({required project, required this.section})
      : exportProject = ExportProject(project: project);

  Map<String, dynamic> toJson() =>
      {'project': exportProject, 'section': section};
}

Future<void> export(Project project, int sectionIndex) async {
  final section = project.sections[sectionIndex];
  final exportData = ExportSection(project: project, section: section);
  final encoded = jsonEncode(exportData);

  final name = '${project.name}_${section.name} by '
      '${section.operatorName}.json';
  final tempDir = await getTemporaryDirectory();
  final file = File(join(tempDir.path, name));
  file.writeAsString(encoded);

  final MailOptions mailOptions = MailOptions(
    body: '<b>Project:</b> ${project.name}<br>'
        '<b>Section:</b> ${section.name}<p>'
        'Scanned by ${section.operatorName}<br>'
        'Item count: ${section.items.length}<p>--<p>'
        'Attachment file name: $name',
    subject: 'Scan for `${project.name}`',
    // recipients: ['example@example.com'],
    isHTML: true,
    attachments: [
      file.path,
    ],
  );

  if (Platform.isAndroid) {
    await FlutterMailer.send(mailOptions);
  } else {
    if (kDebugMode) {
      print('Exported: ${mailOptions.body}');
      print('Encoded: $encoded');
    }
  }
}
