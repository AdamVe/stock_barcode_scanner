import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stock_barcode_scanner/project/projects_screen.dart';
import 'package:stock_barcode_scanner/section/first_scan_dialog.dart';

import '../data/item_repository.dart';
import '../date_time_ext.dart';
import '../domain/models.dart';
import '../export.dart';
import '../scanner/scanner_screen.dart';
import 'section_dialog.dart';

part 'sections_screen.g.dart';

enum _SectionAction { actionEditSection, actionDeleteSection }

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
  Future<List<ExportSection>?> _read() async {
    final repository = ref.read(itemRepositoryProvider);
    final projectId = await repository.getActiveProject();
    ref.read(projectIdProvider.notifier).update(projectId);
    // does project exist?
    final projects = await repository.getProjects();
    final projectExists =
        projects.where((project) => project.id == projectId).isNotEmpty;

    if (!projectExists) {
      return null;
    }
    final sections = (await repository.getSections(projectId: projectId))
        .map((e) => ExportSection(e))
        .toList(growable: false);
    sections.sort((s1, s2) {
      if (s1.section.created == s2.section.created) {
        return s1.items.length - s2.items.length;
      }
      return s2.section.created.millisecondsSinceEpoch -
          s1.section.created.millisecondsSinceEpoch;
    });
    return sections;
  }

  @override
  FutureOr<List<ExportSection>?> build() {
    ref.invalidate(itemRepositoryProvider);
    return _read();
  }

  Future<void> updateSection(Section section) async {
    await ref.read(itemRepositoryProvider).updateSection(section: section);
    await loadSections();
  }

  Future<void> addSection(Section section) async {
    await ref.read(itemRepositoryProvider).addSection(section: section);
    await loadSections();
  }

  Future<void> deleteSection(Section section) async {
    await ref.read(itemRepositoryProvider).deleteSection(section: section);
    await loadSections();
  }

  Future<void> loadSections() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _read());
  }
}

class SectionsScreen extends ConsumerWidget {
  const SectionsScreen({super.key});

  static const String routeName = '/sections';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_controllerProvider);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.folder_copy_outlined),
              tooltip: 'Manage projects',
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    ProjectsScreen.routeName, (route) => false);
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
            data: (sections) => sections != null
                ? _SectionList(sections)
                : FirstScanDialog(after: () {
                    ref.read(_controllerProvider.notifier).loadSections();
                  }),
          ),
        ),
        floatingActionButton: state.whenOrNull(
            data: (sections) => sections == null
                ? null
                : FloatingActionButton.extended(
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
                            .addSection(section);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('New section'),
                  )));
  }
}

class _SectionList extends ConsumerWidget {
  final List<ExportSection> sections;

  const _SectionList(this.sections);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
        itemCount: sections.length,
        itemBuilder: (BuildContext context, int index) {
          final section = sections.elementAt(index);
          return SectionCard(
            exportSection: section,
            onScan: () {
              ref.read(currentSectionProvider.notifier).update(section.section);
              Navigator.pushNamed(
                context,
                ScannerScreen.routeName,
              ).then((value) => ref.invalidate(_controllerProvider));
            },
            onDelete: () {
              ref
                  .read(_controllerProvider.notifier)
                  .deleteSection(section.section);
            },
            onEdit: () async {
              final originalSection = sections.elementAt(index).section;
              Section? section = await showAdaptiveDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SectionDialog(section: originalSection);
                  });
              if (section != null) {
                ref.read(_controllerProvider.notifier).updateSection(section);
              }
            },
            onExport: () async {
              await export(section.section);
            },
          );
        });
  }
}

class SectionCard extends StatelessWidget {
  final ExportSection exportSection;
  final void Function()? onScan;
  final void Function()? onDelete;
  final void Function()? onEdit;
  final void Function()? onExport;

  const SectionCard({
    required this.exportSection,
    this.onScan,
    this.onExport,
    this.onDelete,
    this.onEdit,
    super.key,
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
                      exportSection.section.name,
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
                    PopupMenuButton<_SectionAction>(
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<_SectionAction>(
                            value: _SectionAction.actionEditSection,
                            child: Text('Edit')),
                        const PopupMenuItem<_SectionAction>(
                            value: _SectionAction.actionDeleteSection,
                            child: Text('Delete'))
                      ],
                      onSelected: (_SectionAction sectionAction) async {
                        switch (sectionAction) {
                          case _SectionAction.actionEditSection:
                            onEdit?.call();
                          case _SectionAction.actionDeleteSection:
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
                    'Description: ${exportSection.section.details}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Operator: ${exportSection.section.operatorName}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Scanned items: ${exportSection.items.length}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    exportSection.items.isEmpty
                        ? ''
                        : 'Latest update: ${exportSection.items[0].created.format()}',
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
