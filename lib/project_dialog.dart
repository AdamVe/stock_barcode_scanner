import 'package:flutter/material.dart';

import 'db.dart';

class ProjectDialog extends StatefulWidget {
  final Project? project;

  const ProjectDialog({super.key, this.project});

  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  final projectNameController = TextEditingController();
  final ownerController = TextEditingController();
  bool enabled = false;

  @override
  void initState() {
    super.initState();

    if (widget.project != null) {
      ownerController.text = widget.project!.owner;
      projectNameController.text = widget.project!.name;
    }
  }

  @override
  void dispose() {
    projectNameController.dispose();
    ownerController.dispose();
    super.dispose();
  }

  bool _isEnabled() => widget.project != null
      ? projectNameController.text != widget.project!.name ||
          ownerController.text != widget.project!.owner
      : projectNameController.text.isNotEmpty &&
          ownerController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.project != null
          ? const Text('Edit project')
          : const Text('New project'),
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
                    Navigator.of(context).pop(Project(
                      0,
                      projectNameController.text,
                      DateTime.now(),
                      ownerController.text,
                      0,
                    ));
                  },
            child: widget.project != null
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
              controller: projectNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Project name',
              )),
          const SizedBox(height: 16),
          TextFormField(
              onChanged: (String value) {
                setState(() {
                  enabled = _isEnabled();
                });
              },
              controller: ownerController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Owner',
              )),
        ],
      ),
    );
  }
}
