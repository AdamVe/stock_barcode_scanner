import 'package:flutter/material.dart';
import 'package:stock_barcode_scanner/date_time_ext.dart';
import 'package:stock_barcode_scanner/db.dart';
import 'package:stock_barcode_scanner/project_dialog.dart';
import 'package:stock_barcode_scanner/sections_screen.dart';

enum ProjectAction { actionEditProject, actionDeleteProject }

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  static const routeName = '/projects';

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<Project>? projects;

  @override
  void initState() {
    super.initState();
    projects = DbConnector.getProjects();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _projectDialog(Project? originalProject) async {
    Project? project = await showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return ProjectDialog(project: originalProject);
        });

    if (originalProject != null && project != null) {
      DbConnector.updateProject(project);
    } else if (project != null) {
      DbConnector.addProject(project);
    }
    setState(() {
      projects = DbConnector.getProjects();
    });
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
                            DbConnector.deleteProject(project);
                            setState(() {
                              projects = DbConnector.getProjects();
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
                          'Owner: ${project.owner}\nCreated: ${project.created.format()}'),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          SectionsScreen.routeName,
                          arguments: SectionsScreenArguments(
                            project.id,
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
        onPressed: () async => await _projectDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
