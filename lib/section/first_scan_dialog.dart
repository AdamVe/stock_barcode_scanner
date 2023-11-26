import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stock_barcode_scanner/data/item_repository.dart';
import 'package:stock_barcode_scanner/scanner/scanner_screen.dart';

class FirstScanDialog extends ConsumerStatefulWidget {
  final int? projectId;

  final void Function() onCreate;

  const FirstScanDialog({super.key, this.projectId, required this.onCreate});

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
                          labelText: 'Operator',
                        )),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            onPressed: enabled
                                ? () async {
                                    final repository =
                                        ref.read(itemRepositoryProvider);
                                    final projectId =
                                        await repository.createProject(
                                            name: projectNameController.text);
                                    await repository
                                        .setActiveProject(projectId);
                                    final sectionId =
                                        await repository.createSection(
                                      projectId: projectId,
                                      name: sectionIdController.text,
                                      details: sectionDetailsController.text,
                                      operatorName: operatorNameController.text,
                                    );
                                    final newSection = (await repository
                                            .getSections(projectId: projectId))
                                        .where((section) =>
                                            section.id == sectionId)
                                        .first;
                                    ref
                                        .read(currentSectionProvider.notifier)
                                        .update(newSection);

                                    widget.onCreate.call();
                                  }
                                : null,
                            child: const Text('Create project')),
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
