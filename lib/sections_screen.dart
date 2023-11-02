import 'package:flutter/material.dart';
import 'package:stock_barcode_scanner/db.dart';
import 'package:stock_barcode_scanner/scanner_screen.dart';
import 'package:stock_barcode_scanner/section_dialog.dart';

enum SectionAction { actionEditSection, actionDeleteSection }

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
                    return ListTile(
                      leading: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.insert_drive_file_outlined),
                        ],
                      ),
                      trailing: PopupMenuButton<SectionAction>(
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<SectionAction>(
                              value: SectionAction.actionEditSection,
                              child: Text('Edit')),
                          const PopupMenuItem<SectionAction>(
                              value: SectionAction.actionDeleteSection,
                              child: Text('Delete'))
                        ],
                        onSelected: (SectionAction sectionAction) async {
                          if (sectionAction ==
                              SectionAction.actionDeleteSection) {
                            DbConnector.deleteSection(section);
                            setState(() {
                              sections =
                                  DbConnector.getSections(widget._projectId);
                            });
                          } else if (sectionAction ==
                              SectionAction.actionEditSection) {
                            await _sectionDialog(section);
                          }
                        },
                      ),
                      title: Text(section.name),
                      isThreeLine: true,
                      subtitle: Text(
                          'Note: ${section.note}\nCreated: ${section.created.toLocal()}'),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          ScannerScreen.routeName,
                          arguments: ScannerScreenArguments(
                            section,
                          ),
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => await _sectionDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
