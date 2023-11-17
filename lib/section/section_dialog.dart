import 'package:flutter/material.dart';

import '../domain/models.dart';

class SectionDialog extends StatefulWidget {
  final Section? section;
  final int? projectId;

  const SectionDialog({super.key, this.section, this.projectId});

  @override
  State<SectionDialog> createState() => _SectionDialogState();
}

class _SectionDialogState extends State<SectionDialog> {
  final sectionNameController = TextEditingController();
  final detailsController = TextEditingController();
  final operatorNameController = TextEditingController();
  bool enabled = false;

  @override
  void initState() {
    super.initState();

    if (widget.section != null) {
      detailsController.text = widget.section!.details;
      sectionNameController.text = widget.section!.name;
      operatorNameController.text = widget.section!.operatorName;
    }
  }

  @override
  void dispose() {
    sectionNameController.dispose();
    detailsController.dispose();
    operatorNameController.dispose();
    super.dispose();
  }

  bool _isEnabled() => widget.section != null
      ? sectionNameController.text != widget.section!.name ||
          operatorNameController.text != widget.section!.operatorName ||
          detailsController.text != widget.section!.details
      : sectionNameController.text.isNotEmpty &&
          operatorNameController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.section != null
          ? const Text('Edit section')
          : const Text('New section'),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop(null);
            },
            child: const Text('Cancel')),
        TextButton(
            onPressed: !enabled
                ? null
                : () {
                    final section = Section(
                      id: widget.section?.id ?? 0,
                      projectId: widget.section?.projectId ?? widget.projectId!,
                      name: sectionNameController.text,
                      details: detailsController.text,
                      operatorName: operatorNameController.text,
                      created: widget.section?.created ?? DateTime.now(),
                    );
                    Navigator.of(context).pop(section);
                  },
            child: widget.section != null
                ? const Text('Update')
                : const Text('Create'))
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
              onChanged: (String value) {
                setState(() {
                  enabled = _isEnabled();
                });
              },
              controller: sectionNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Section name',
              )),
          const SizedBox(height: 16),
          TextFormField(
              onChanged: (String value) {
                setState(() {
                  enabled = _isEnabled();
                });
              },
              controller: detailsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Section details',
              )),
          const SizedBox(height: 16),
          TextFormField(
              onChanged: (String value) {
                setState(() {
                  enabled = _isEnabled();
                });
              },
              controller: operatorNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Operator',
              )),
        ],
      ),
    );
  }
}
