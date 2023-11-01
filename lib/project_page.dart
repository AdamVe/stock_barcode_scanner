import 'package:flutter/material.dart';
import 'package:stock_barcode_scanner/db.dart';
import 'package:stock_barcode_scanner/project_dialog.dart';

enum ProjectAction { actionEditProject, actionDeleteProject }

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  DbConnector? _connector;
  List<Project>? projects;

  @override
  void initState() {
    super.initState();
    DbConnector.getConnector().then((value) {
      setState(() {
        _connector = value;
        projects = _connector?.getProjects();
      });
    });
  }

  @override
  void dispose() {
    _connector?.close();
    super.dispose();
  }

  Future<void> _projectDialog(Project? originalProject) async {
    Project? project = await showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return ProjectDialog(project: originalProject);
        });

    if (project != null) {
      setState(() {
        _connector?.addProject(project);
        projects = _connector?.getProjects();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Projects'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: projects != null ? projects!.length : 0,
                  itemBuilder: (BuildContext context, int index) {
                    final project = projects!.elementAt(index);
                    return ListTile(
                      leading: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.insert_drive_file_outlined),
                        ],
                      ),
                      trailing: PopupMenuButton<ProjectAction>(
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<ProjectAction>(
                              value: ProjectAction.actionEditProject,
                              child: Text('Edit')),
                          const PopupMenuItem<ProjectAction>(
                              value: ProjectAction.actionDeleteProject,
                              child: Text('Delete'))
                        ],
                        onSelected: (ProjectAction projectAction) async {
                          if (projectAction ==
                              ProjectAction.actionDeleteProject) {
                            _connector?.deleteProject(project);
                            setState(() {
                              projects = _connector?.getProjects();
                            });
                          } else if (projectAction ==
                              ProjectAction.actionEditProject) {
                            await _projectDialog(project);
                          }
                        },
                      ),
                      title: Text(project.name),
                      isThreeLine: true,
                      subtitle: Text(
                          'Owner: ${project.owner}\nCreated: ${project.created.toLocal()}'),

                      onTap: () {},
                    );
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => await _projectDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
