import 'package:flutter/material.dart';
import 'package:stock_barcode_scanner/date_time_ext.dart';
import 'package:stock_barcode_scanner/data/db.dart';
import 'package:stock_barcode_scanner/scanner/scanner_screen.dart';
import 'package:stock_barcode_scanner/section/section_dialog.dart';

import '../export.dart';
import '../domain/models.dart';

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
  List<ExportSection>? sections;

  void _readSections() {
    sections = DbConnector.getSections(widget._projectId)
        .map((e) => ExportSection(e))
        .toList(growable: false);
    sections?.sort((s1, s2) {
      if (s1.section.created == s2.section.created) {
        return s1.items.length - s2.items.length;
      }
      return s2.section.created.millisecondsSinceEpoch -
          s1.section.created.millisecondsSinceEpoch;
    });
  }

  @override
  void initState() {
    super.initState();
    _readSections();
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
      _readSections();
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
                      exportSection: section,
                      onScan: () {
                        Navigator.pushNamed(
                          context,
                          ScannerScreen.routeName,
                          arguments: ScannerScreenArguments(
                            section.section,
                          ),
                        );
                      },
                      onDelete: () {
                        DbConnector.deleteSection(section.section);
                        setState(() {
                          _readSections();
                        });
                      },
                      onEdit: () async {
                        await _sectionDialog(section.section);
                      },
                      onExport: () async {
                        await export(section.section);
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
  final ExportSection exportSection;
  final void Function()? onScan;
  final void Function()? onDelete;
  final void Function()? onEdit;
  final void Function()? onExport;

  const SectionCard({
    required this.exportSection,
    this.onScan,
    this.onExport,
    this.onDelete,
    this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                  exportSection.section.name,
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
                        'Description: ${exportSection.section.note}',
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
