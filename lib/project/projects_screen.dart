import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stock_barcode_scanner/data/item_repository.dart';
import 'package:stock_barcode_scanner/date_time_ext.dart';
import 'package:stock_barcode_scanner/project/project_dialog.dart';
import 'package:stock_barcode_scanner/section/project_screen.dart';

import '../domain/models.dart';

part 'projects_screen.g.dart';

enum ProjectAction { actionEditProject, actionDeleteProject }

@riverpod
class _Controller extends _$Controller {
  Future<List<Project>> _read() async {
    return ref.read(itemRepositoryProvider).getProjects();
  }

  @override
  FutureOr<List<Project>> build() {
    ref.invalidate(itemRepositoryProvider);
    return _read();
  }

  Future<void> updateProject(Project project) async {
    await ref.read(itemRepositoryProvider).updateProject(project: project);
    await loadProjects();
  }

  Future<void> addProject(Project project) async {
    await ref
        .read(itemRepositoryProvider)
        .createProject(name: project.name, details: project.details);
    await loadProjects();
  }

  Future<void> deleteProject(Project project) async {
    await ref.read(itemRepositoryProvider).deleteProject(project: project);
    await loadProjects();
  }

  Future<void> loadProjects() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _read());
  }
}

class _ProjectList extends ConsumerWidget {
  final List<Project> projects;

  const _ProjectList(this.projects);

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListView.builder(
      itemCount: projects.length,
      itemBuilder: (BuildContext context, int index) {
        final project = projects.elementAt(index);
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
                  value: ProjectAction.actionEditProject, child: Text('Edit')),
              const PopupMenuItem<ProjectAction>(
                  value: ProjectAction.actionDeleteProject,
                  child: Text('Delete'))
            ],
            onSelected: (ProjectAction projectAction) async {
              if (projectAction == ProjectAction.actionDeleteProject) {
                ref.read(_controllerProvider.notifier).deleteProject(project);
              } else if (projectAction == ProjectAction.actionEditProject) {
                final updatedProject = await showAdaptiveDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ProjectDialog(project: project);
                    });
                if (updatedProject != null) {
                  ref
                      .read(_controllerProvider.notifier)
                      .updateProject(updatedProject);
                }
              }
            },
          ),
          title: Text(project.name),
          isThreeLine: true,
          subtitle: Text(
              'Details: ${project.details}\nCreated: ${project.created.format()}'),
          onTap: () async {
            ref.read(itemRepositoryProvider).setActiveProject(project.id);

            ref
                .read(_controllerProvider.notifier)
                .updateProject(project.copyWith(accessed: DateTime.now()));

            Navigator.pushNamedAndRemoveUntil(
                context, ProjectScreen.routeName, (route) => false);
          },
        );
      });
}

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  static const routeName = '/projects';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_controllerProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Projects'),
      ),
      body: SafeArea(
        child: state.when(
          error: (e, st) => Text('ERROR: $st'),
          loading: () => const CircularProgressIndicator(),
          data: (projects) => _ProjectList(projects),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newProject = await showAdaptiveDialog(
              context: context,
              builder: (BuildContext context) {
                return const ProjectDialog();
              });
          if (newProject != null) {
            ref.read(_controllerProvider.notifier).addProject(newProject);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
