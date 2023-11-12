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
  final noteController = TextEditingController();
  bool enabled = false;

  @override
  void initState() {
    super.initState();

    if (widget.section != null) {
      noteController.text = widget.section!.note;
      sectionNameController.text = widget.section!.name;
    }
  }

  @override
  void dispose() {
    sectionNameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  bool _isEnabled() => widget.section != null
      ? sectionNameController.text != widget.section!.name ||
          noteController.text != widget.section!.note
      : sectionNameController.text.isNotEmpty && noteController.text.isNotEmpty;

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
                    final section = widget.section != null
                        ? Section(
                            widget.section!.id,
                            widget.section!.projectId,
                            sectionNameController.text,
                            noteController.text,
                            widget.section!.created,
                          )
                        : Section(
                            0,
                            widget.projectId!,
                            sectionNameController.text,
                            noteController.text,
                            DateTime.now(),
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
              controller: noteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Section note',
              )),
        ],
      ),
    );
  }
}
