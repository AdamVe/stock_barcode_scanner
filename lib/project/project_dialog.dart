import 'package:flutter/material.dart';

import '../domain/models.dart';

class ProjectDialog extends StatefulWidget {
  final Project? project;

  const ProjectDialog({this.project, super.key});

  @override
  State<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends State<ProjectDialog> {
  final projectNameController = TextEditingController();
  final projectDetailsController = TextEditingController();
  bool enabled = false;

  @override
  void initState() {
    super.initState();

    if (widget.project != null) {
      projectDetailsController.text = widget.project!.details;
      projectNameController.text = widget.project!.name;
    }
  }

  @override
  void dispose() {
    projectNameController.dispose();
    projectDetailsController.dispose();
    super.dispose();
  }

  bool _isEnabled() => widget.project != null
      ? projectNameController.text != widget.project!.name ||
          projectDetailsController.text != widget.project!.details
      : projectNameController.text.isNotEmpty;

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
                    final accessedDate = DateTime.now();
                    final createdDate = widget.project?.created ?? accessedDate;

                    Navigator.of(context).pop(Project(
                      id: widget.project?.id ?? 0,
                      name: projectNameController.text,
                      details: projectDetailsController.text,
                      created: createdDate, // created
                      accessed: accessedDate, // accessed
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
              controller: projectDetailsController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Details',
              )),
        ],
      ),
    );
  }
}
