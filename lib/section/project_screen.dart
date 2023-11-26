import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stock_barcode_scanner/confirmation_dialog.dart';
import 'package:stock_barcode_scanner/project/projects_screen.dart';
import 'package:stock_barcode_scanner/section/welcome_dialog.dart';

import '../data/item_repository.dart';
import '../date_time_ext.dart';
import '../domain/models.dart';
import '../export.dart';
import '../scanner/scanner_screen.dart';
import 'section_dialog.dart';

part 'project_screen.g.dart';

enum _ProjectScreenAction { actionEditSection, actionDeleteSection }

@Riverpod(keepAlive: true)
class ProjectId extends _$ProjectId {
  @override
  int build() => -1;

  void update(int newProjectId) {
    state = newProjectId;
  }
}

@riverpod
class _Controller extends _$Controller {
  Future<Project?> _read() async {
    final repository = ref.read(itemRepositoryProvider);
    final projectId = await repository.getActiveProject();
    if (kDebugMode) {
      print('Sections for project $projectId');
    }
    ref.read(projectIdProvider.notifier).update(projectId);
    final project = await repository.getProjects(id: projectId);
    return project.firstOrNull;
  }

  @override
  FutureOr<Project?> build() {
    ref.invalidate(itemRepositoryProvider);
    return _read();
  }

  Future<void> updateSection(Section section) async {
    await ref.read(itemRepositoryProvider).updateSection(section: section);
    await reload();
  }

  Future<void> createSection(int projectId, Section section) async {
    await ref.read(itemRepositoryProvider).createSection(
        projectId: projectId,
        name: section.name,
        details: section.details,
        operatorName: section.operatorName);
    await reload();
  }

  Future<void> deleteSection(Section section) async {
    await ref.read(itemRepositoryProvider).deleteSection(section: section);
    await reload();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _read());
  }
}

/// Project screen shows project information,
/// project sections and has actions for adding, updating and removing sections,
/// as well as exporting.
class ProjectScreen extends ConsumerWidget {
  const ProjectScreen({super.key});

  static const String routeName = '/projectScreen';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_controllerProvider);
    final hasProjects = state.hasValue && state.value != null;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            if (hasProjects)
              IconButton(
                icon: const Icon(Icons.folder_copy_outlined),
                tooltip: 'Manage projects',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, ProjectsScreen.routeName, (route) => false);
                },
              ),
          ],
          title: const Text('Sections'),
        ),
        body: SafeArea(
          child: state.when(
            error: (e, st) {
              return Center(child: Text('ERROR: $e'));
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            data: (project) => project != null
                ? _SectionList(project)
                : WelcomeDialog(onCreate: () {
                    ref.read(_controllerProvider.notifier).reload();
                  }),
          ),
        ),
        floatingActionButton: hasProjects
            ? FloatingActionButton.extended(
                onPressed: () async {
                  Section? section = await showAdaptiveDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SectionDialog(
                            projectId: ref.read(projectIdProvider));
                      });
                  if (section != null) {
                    ref
                        .read(_controllerProvider.notifier)
                        .createSection(state.value!.id, section);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('New section'),
              )
            : null);
  }
}

/// Shows list of sections in the [project]
class _SectionList extends ConsumerWidget {
  final Project project;

  const _SectionList(this.project);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
        itemCount: project.sections.length,
        itemBuilder: (BuildContext context, int index) {
          final section = project.sections.elementAt(index);
          return _SectionCard(
            section: section,
            onScan: () {
              ref.read(currentSectionProvider.notifier).update(section);
              Navigator.pushNamed(
                context,
                ScannerScreen.routeName,
              ).then((value) => ref.invalidate(_controllerProvider));
            },
            onDelete: () async {
              await showConfirmationDialog(
                  context,
                  'Delete section?',
                  'This will delete the section and all scanned items. '
                      'This cannot be undone.',
                  [
                    DialogAction('Cancel', () {}),
                    DialogAction('Delete', () {
                      ref
                          .read(_controllerProvider.notifier)
                          .deleteSection(section);
                    })
                  ]);
            },
            onEdit: () async {
              final originalSection = section;
              Section? editedSection = await showAdaptiveDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SectionDialog(section: originalSection);
                  });
              if (editedSection != null) {
                ref
                    .read(_controllerProvider.notifier)
                    .updateSection(editedSection);
              }
            },
            onExport: () async {
              await export(project, index);
            },
          );
        });
  }
}

/// Information about section wrapped in Material Card widget
class _SectionCard extends StatelessWidget {
  final Section section;
  final void Function()? onScan;
  final void Function()? onDelete;
  final void Function()? onEdit;
  final void Function()? onExport;

  const _SectionCard({
    required this.section,
    this.onScan,
    this.onExport,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 10,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.topLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      section.name,
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ButtonBar(
                  children: [
                    IconButton(
                        onPressed: () async => onExport?.call(),
                        icon: const Icon(Icons.ios_share)),
                    PopupMenuButton<_ProjectScreenAction>(
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<_ProjectScreenAction>(
                            value: _ProjectScreenAction.actionEditSection,
                            child: Text('Edit')),
                        const PopupMenuItem<_ProjectScreenAction>(
                            value: _ProjectScreenAction.actionDeleteSection,
                            child: Text('Delete'))
                      ],
                      onSelected: (_ProjectScreenAction sectionAction) async {
                        switch (sectionAction) {
                          case _ProjectScreenAction.actionEditSection:
                            onEdit?.call();
                          case _ProjectScreenAction.actionDeleteSection:
                            onDelete?.call();
                          default:
                        }
                      },
                    )
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description: ${section.details}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Operator: ${section.operatorName}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Scanned items: ${section.items.length}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    section.items.isEmpty
                        ? ''
                        : 'Latest update: ${section.items[0].created.format()}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                    onPressed: () async => onScan?.call(),
                    icon: const Icon(Icons.document_scanner_outlined),
                    label: const Text('Scan')),
              ],
            )
          ],
        ),
      ),
    );
  }
}
