import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_barcode_scanner/data/item_repository.dart';
import 'package:stock_barcode_scanner/scanner/scanner_screen.dart';

import '../domain/models.dart';

class FirstScanDialog extends ConsumerStatefulWidget {
  final int? projectId;

  final void Function() after;

  const FirstScanDialog({super.key, this.projectId, required this.after});

  @override
  ConsumerState<FirstScanDialog> createState() => _FirstScanDialogState();
}

class _FirstScanDialogState extends ConsumerState<FirstScanDialog> {
  final projectNameController = TextEditingController();
  final sectionIdController = TextEditingController();
  final sectionDetailsController = TextEditingController();
  final operatorNameController = TextEditingController();
  bool enabled = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    projectNameController.dispose();
    sectionIdController.dispose();
    sectionDetailsController.dispose();
    operatorNameController.dispose();
    super.dispose();
  }

  bool _isEnabled() =>
      projectNameController.text.isNotEmpty &&
      sectionIdController.text.isNotEmpty &&
      operatorNameController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    //Text('This is the first time you use the app and we need to do a quick setup. Please fill in the following information:', style: Theme.of(context).textTheme.bodyLarge,),
                    Text(
                      'Please fill in following:',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                        onChanged: (_) {
                          setState(() {
                            enabled = _isEnabled();
                          });
                        },
                        controller: projectNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Project name',
                        )),
                    // Text('For example "Shop Summer 2023 inventarization." This will be used for export naming and can be changed later.', style: Theme.of(context).textTheme.bodySmall,),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                              onChanged: (_) {
                                setState(() {
                                  enabled = _isEnabled();
                                });
                              },
                              controller: sectionIdController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Section',
                              )),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                              onChanged: (_) {
                                setState(() {
                                  enabled = _isEnabled();
                                });
                              },
                              controller: sectionDetailsController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Section description',
                              )),
                        ),
                      ],
                    ),
                    // Text('Section should be a short string ( A, X, RT ...) which identifies the section/area of current scanning. Use section description for more info. Sections can be added later.', style: Theme.of(context).textTheme.bodySmall,),
                    const SizedBox(height: 16),
                    TextFormField(
                        onChanged: (_) {
                          setState(() {
                            enabled = _isEnabled();
                          });
                        },
                        controller: operatorNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Author',
                        )),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            onPressed: enabled
                                ? () async {
                                    final createdAccessedDate = DateTime.now();
                                    final repository =
                                        ref.read(itemRepositoryProvider);
                                    final projectId =
                                        await repository.addProject(
                                            project: Project(
                                      id: 0,
                                      name: projectNameController.text,
                                      details: '',
                                      created: createdAccessedDate,
                                      accessed: createdAccessedDate,
                                    ));
                                    await repository.setActiveProject(
                                        projectId: projectId);
                                    final sectionId =
                                        await repository.addSection(
                                            section: Section(
                                                id: 0,
                                                projectId: projectId,
                                                name: sectionIdController.text,
                                                details:
                                                    sectionDetailsController
                                                        .text,
                                                operatorName:
                                                    operatorNameController.text,
                                                created: DateTime.now()));
                                    final newSection = (await repository
                                            .getSections(projectId: projectId))
                                        .where((section) =>
                                            section.id == sectionId)
                                        .first;
                                    ref.read(sectionProvider.notifier).state =
                                        newSection;
                                    if (mounted) {
                                      await Navigator.pushNamed(
                                        context,
                                        ScannerScreen.routeName,
                                      );
                                      widget.after.call();
                                    }
                                  }
                                : null,
                            child: const Text('Create project & Scan')),
                      ],
                    )
                    // Text('Name of the person who is scanning the section.', style: Theme.of(context).textTheme.bodySmall,),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
