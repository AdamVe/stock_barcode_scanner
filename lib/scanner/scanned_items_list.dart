import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../confirmation_dialog.dart';
import '../data/item_repository.dart';
import '../date_time_ext.dart';
import '../domain/models.dart';
import 'scanner_screen.dart';

part 'scanned_items_list.g.dart';

const _scannedItemListHeight = 250.0;

@riverpod
class _Controller extends _$Controller {
  Future<List<ScannedItem>> _read() async {
    final sectionId =
        ref.watch(currentSectionProvider.select((section) => section.id));
    return ref.watch(itemRepositoryProvider
        .select((repository) => repository.getScans(sectionId: sectionId)));
  }

  @override
  FutureOr<List<ScannedItem>> build() {
    return _read();
  }

  Future<void> updateScannedItem(ScannedItem scannedItem) async {
    await ref
        .read(itemRepositoryProvider)
        .updateScan(scannedItemId: scannedItem.id, scan: scannedItem);
    await loadScannedItems();
  }

  Future<int> addScannedItem(int sectionId, ScannedItem scannedItem) async {
    int id = await ref
        .read(itemRepositoryProvider)
        .addScan(sectionId: sectionId, scan: scannedItem);
    await loadScannedItems();
    return id;
  }

  Future<ScannedItem?> getLatest(int sectionId) async {
    // TODO: optimize this
    final allScans =
        await ref.read(itemRepositoryProvider).getScans(sectionId: sectionId);
    return allScans.firstOrNull;
  }

  Future<void> deleteScannedItem(ScannedItem scannedItem) async {
    await ref.read(itemRepositoryProvider).deleteScan(scan: scannedItem);
    await loadScannedItems();
  }

  Future<void> loadScannedItems() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _read());
  }
}

class _ScannedItemListError extends StatelessWidget {
  const _ScannedItemListError();

  @override
  Widget build(BuildContext context) => const Column(children: [
        ListTile(
          leading: Icon(Symbols.document_scanner),
          title: Text('Items'),
          subtitle: Text('Error loading data'),
        ),
        SizedBox(
          height: _scannedItemListHeight,
        )
      ]);
}

class _ScannedItemListLoading extends StatelessWidget {
  const _ScannedItemListLoading();

  @override
  Widget build(BuildContext context) => const Column(children: [
        ListTile(
          leading: Icon(Symbols.document_scanner),
          title: Text('Items'),
          subtitle: Text('Loading'),
        ),
        SizedBox(
          height: _scannedItemListHeight,
        )
      ]);
}

class ScannedItemList extends ConsumerWidget {
  const ScannedItemList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Builder(builder: (context) {
      final state = ref.watch(_controllerProvider);
      return state.when(
          error: (e, st) => const _ScannedItemListError(),
          loading: () => const _ScannedItemListLoading(),
          data: (scannedItems) => Column(
                children: [
                  ListTile(
                    leading: const Icon(Symbols.document_scanner),
                    title: Text('${scannedItems.length} items'),
                  ),
                  SizedBox(
                    height: _scannedItemListHeight,
                    child: ListView.builder(
                        itemCount: scannedItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          final scannedItem = scannedItems[index];
                          final count = scannedItem.count;
                          final sum = scannedItems
                              .where((i) => i.barcode == scannedItem.barcode)
                              .fold(
                                  0,
                                  (previousValue, i) =>
                                      previousValue + i.count);
                          final textTheme = Theme.of(context).textTheme;
                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: () async {
                                await showConfirmationDialog(
                                    context,
                                    'Delete scan?',
                                    'This will remove the scan with the count. This action cannot be undone.',
                                    actions: [
                                      DialogAction('Cancel', () {}),
                                      DialogAction('Delete', () async {
                                        await ref
                                            .read(_controllerProvider.notifier)
                                            .deleteScannedItem(scannedItem);
                                      })
                                    ],
                                    icon: const Icon(Symbols.delete_outline));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Builder(builder: (context) {
                                      return FittedBox(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('$count \u00d7 ',
                                                  style: textTheme.bodyLarge
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                              Text(scannedItem.barcode,
                                                  style:
                                                      textTheme.displayMedium),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Scanned: ',
                                            style: textTheme.bodyLarge
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        Text(scannedItem.created.format()),
                                        const SizedBox(
                                          width: 32,
                                        ),
                                        Text('Sum: ',
                                            style: textTheme.bodyLarge
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        Text('$sum'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ));
    });
  }
}
