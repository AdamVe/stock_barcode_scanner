import 'package:flutter/material.dart';
import 'package:stock_barcode_scanner/date_time_ext.dart';
import 'package:stock_barcode_scanner/db.dart';
import 'package:stock_barcode_scanner/scanner_screen.dart';
import 'package:stock_barcode_scanner/section_dialog.dart';

import 'export.dart';

enum SectionAction {
  actionEditSection,
  actionDeleteSection,
  actionExportSection
}

class SectionsScreenArguments {
  final int projectId;

  const SectionsScreenArguments(this.projectId);
}

class SectionsScreen extends StatelessWidget {
  const SectionsScreen({super.key});

  static const String routeName = '/sections';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as SectionsScreenArguments;
    return _SectionsScreenChild(args.projectId);
  }
}

class _SectionsScreenChild extends StatefulWidget {
  final int _projectId;

  const _SectionsScreenChild(this._projectId);

  @override
  State<_SectionsScreenChild> createState() => _SectionsScreenChildState();
}

class _SectionsScreenChildState extends State<_SectionsScreenChild> {
  List<Section>? sections;

  @override
  void initState() {
    super.initState();
    sections = DbConnector.getSections(widget._projectId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _sectionDialog(Section? originalSection) async {
    Section? section = await showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return SectionDialog(
              section: originalSection, projectId: widget._projectId);
        });

    if (originalSection != null && section != null) {
      DbConnector.updateSection(section);
    } else if (section != null) {
      DbConnector.addSection(section);
    }

    setState(() {
      sections = DbConnector.getSections(widget._projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Sections'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: sections != null ? sections!.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    final section = sections!.elementAt(index);
                    return SectionCard(
                      section: section,
                      onScan: () {
                        Navigator.pushNamed(
                          context,
                          ScannerScreen.routeName,
                          arguments: ScannerScreenArguments(
                            section,
                          ),
                        );
                      },
                      onDelete: () {
                        DbConnector.deleteSection(section);
                        setState(() {
                          sections = DbConnector.getSections(widget._projectId);
                        });
                      },
                      onEdit: () async {
                        await _sectionDialog(section);
                      },
                      onExport: () async {
                        await export(section);
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async => await _sectionDialog(null),
        icon: const Icon(Icons.add),
        label: const Text('New section'),
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final Section section;
  final void Function()? onScan;
  final void Function()? onDelete;
  final void Function()? onEdit;
  final void Function()? onExport;

  const SectionCard({
    required this.section,
    this.onScan,
    this.onExport,
    this.onDelete,
    this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final exportSection = ExportSection(section);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 10,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Stack(
        fit: StackFit.loose,
        alignment: AlignmentDirectional.topEnd,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.name,
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description: ${section.note}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        'Scanned items: ${exportSection.items.length}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        exportSection.items.isEmpty
                            ? ''
                            : 'Latest update: ${exportSection.items[0].created.format()}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () async => onScan?.call(),
                        icon: const Icon(Icons.document_scanner_outlined),
                        label: const Text('Scan')),
                  ],
                )
              ],
            ),
          ),
          ButtonBar(
            children: [
              IconButton(
                  onPressed: () async => onExport?.call(),
                  icon: const Icon(Icons.ios_share)),
              PopupMenuButton<SectionAction>(
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<SectionAction>(
                      value: SectionAction.actionEditSection,
                      child: Text('Edit')),
                  const PopupMenuItem<SectionAction>(
                      value: SectionAction.actionDeleteSection,
                      child: Text('Delete'))
                ],
                onSelected: (SectionAction sectionAction) async {
                  switch (sectionAction) {
                    case SectionAction.actionEditSection:
                      onEdit?.call();
                    case SectionAction.actionDeleteSection:
                      onDelete?.call();
                    default:
                  }
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
