import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/item_repository.dart';
import '../date_time_ext.dart';
import '../domain/models.dart';
import '../export.dart';
import '../scanner/scanner_screen.dart';
import 'section_dialog.dart';

part 'sections_screen.g.dart';

enum _SectionAction { actionEditSection, actionDeleteSection }

final projectIdProvider = StateProvider<int>((ref) => 0);

@riverpod
class _Controller extends _$Controller {
  Future<List<ExportSection>> _read() async {
    final projectId = ref.watch(projectIdProvider);
    final sections = (await ref
            .read(itemRepositoryProvider)
            .getSections(projectId: projectId))
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
  FutureOr<List<ExportSection>> build() {
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
        title: const Text('Sections'),
      ),
      body: SafeArea(
        child: state.when(
            error: (e, st) => Text('ERROR: $st'),
            loading: () => const Center(child: CircularProgressIndicator()),
            data: (sections) => _SectionList(sections)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Section? section = await showAdaptiveDialog(
              context: context,
              builder: (BuildContext context) {
                return SectionDialog(projectId: ref.read(projectIdProvider));
              });
          if (section != null) {
            ref.read(_controllerProvider.notifier).addSection(section);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New section'),
      ),
    );
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
              Navigator.pushNamed(
                context,
                ScannerScreen.routeName,
                arguments: ScannerScreenArguments(
                  section.section,
                ),
              );
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
      child: Stack(
        fit: StackFit.loose,
        alignment: AlignmentDirectional.topEnd,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exportSection.section.name,
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description: ${exportSection.section.note}',
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
    );
  }
}
