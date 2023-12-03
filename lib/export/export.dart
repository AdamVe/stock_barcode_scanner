import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../data/item_repository.dart';
import '../domain/models.dart';

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

Future<String> exportAsJson(ExportSection exportData) async {
  final encoded = jsonEncode(exportData);
  final name =
      '${exportData.exportProject.project.name}_${exportData.section.name}_'
      '${exportData.section.operatorName}.json';
  final tempDir = await getTemporaryDirectory();
  final file = File(join(tempDir.path, name));
  file.writeAsString(encoded, flush: true);
  return file.path;
}

Future<String> exportAsCsv(ExportSection exportData) async {
  final name =
      '${exportData.exportProject.project.name}_${exportData.section.name}_'
      '${exportData.section.operatorName}.csv';
  final tempDir = await getTemporaryDirectory();
  final file = File(join(tempDir.path, name));

  String csvData =
      'Barcode,Name,Description,Quantity,Operator,Area,Notes,Date\n';
  for (var scannedItem in exportData.section.items) {
    csvData += '"${scannedItem.barcode}",'
        '"","","${scannedItem.count}",'
        '"${exportData.section.operatorName}",'
        '"${exportData.section.name}", "",'
        '"${scannedItem.updated.toLocal()}"\n';
  }
  file.writeAsString(csvData, flush: true);

  return file.path;
}

Future<void> export(WidgetRef ref, BuildContext context, Project project,
    int sectionIndex) async {
  final section = project.sections[sectionIndex];
  final exportData = ExportSection(project: project, section: section);
  final encoded = jsonEncode(exportData);

  final repository = ref.read(itemRepositoryProvider);
  final lastRecipient = await repository.getLastRecipient();

  if (!context.mounted) {
    return;
  }

  final recipient = await showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return _ExportDialog(project, section, lastRecipient);
      });

  if (recipient == null) {
    return;
  }
  await repository.setLastRecipient(recipient);

  String itemsTable = '';
  for (var element in section.items) {
    itemsTable += '${element.barcode}  /  ${element.count} / '
        '${section.name} / ${section.operatorName} / '
        '${element.updated.toLocal()} / id:${element.id}\n';
  }

  final jsonFilePath = await exportAsJson(exportData);
  final csvFilePath = await exportAsCsv(exportData);
  String body = 'Project: ${project.name}\n'
      'Section: ${section.name}\n'
      'Operated by: ${section.operatorName}\n'
      'Item count: ${section.items.length}\n'
      'Attached JSON: ${basename(jsonFilePath)}\n'
      'Attached CSV: ${basename(csvFilePath)}\n'
      '\n'
      'Data:\n'
      '$itemsTable\n';

  final MailOptions mailOptions = MailOptions(
    body: body,
    subject: '${project.name}_${section.name}_${section.operatorName}',
    recipients: [recipient],
    isHTML: false,
    attachments: [
      jsonFilePath,
      csvFilePath,
    ],
  );

  if (Platform.isAndroid) {
    await FlutterMailer.send(mailOptions);
  } else {
    if (kDebugMode) {
      print('Recipient: $recipient');
      print('Exported: ${mailOptions.body}');
      print('Encoded: $encoded');
    }
  }
}

class _ExportInfoSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ExportInfoSection(this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.normal)),
          Text(subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ExportDialog extends ConsumerStatefulWidget {
  final Project _project;
  final Section _section;
  final String _recipient;

  const _ExportDialog(this._project, this._section, this._recipient);

  @override
  ConsumerState<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<_ExportDialog> {
  late TextEditingController _controller;
  bool _exportEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              icon: const Icon(Icons.close)),
          title: const Text('Review export'),
          actions: [
            TextButton(
                onPressed: _exportEnabled
                    ? () {
                        Navigator.of(context).pop(_controller.text);
                      }
                    : null,
                child: const Text('Export'))
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Scan information',
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ExportInfoSection('Project', widget._project.name),
                      _ExportInfoSection('Section', widget._section.name),
                      _ExportInfoSection(
                          'Operator', widget._section.operatorName),
                      _ExportInfoSection(
                          'Items scanned', '${widget._section.items.length}'),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                    controller: _controller,
                    onChanged: (newValue) {
                      setState(() {
                        _exportEnabled = _controller.text.isNotEmpty;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Recipient',
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget._recipient);
    _exportEnabled = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
