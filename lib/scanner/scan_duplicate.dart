import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../domain/models.dart';

class ScanDuplicate extends StatefulWidget {
  final ScannedItem scannedItem;
  final Function(ScannedItem) onUpdate;
  final Function() onClose;

  const ScanDuplicate(
      {required this.scannedItem,
      required this.onUpdate,
      required this.onClose,
      super.key});

  @override
  State<ScanDuplicate> createState() => _ScanDuplicateState();
}

class _ScanDuplicateState extends State<ScanDuplicate> {
  int _currentValue = 0;
  int _originalValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.scannedItem.count;
    _originalValue = _currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 64),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ColoredBox(
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: const Text('Duplicate'),
                            leading: Icon(
                              Symbols.question_mark_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                'The code ${widget.scannedItem.barcode} has been '
                                'recently scanned. To avoid duplicates, adjust '
                                'number of same codes manually.'),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text('Or scan a new item.'),
                          )
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 56, 8, 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FilledButton.tonal(
                        onPressed: () => _updateCount(1),
                        child: const Icon(Symbols.add),
                      ),
                      Text(
                        '$_currentValue',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      FilledButton.tonal(
                        onPressed: () => _currentValue > _originalValue
                            ? _updateCount(-1)
                            : null,
                        child: const Icon(Symbols.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _currentValue == _originalValue
                    ? TextButton(
                        onPressed: widget.onClose,
                        child: const Text('Close'),
                      )
                    : TextButton.icon(
                        onPressed: widget.onClose,
                        label: const Text('Apply'),
                        icon: const Icon(Symbols.check_rounded))
              ],
            )
          ],
        ),
      ),
    );
  }

  void _updateCount(int amount) {
    setState(() {
      _currentValue += amount;
    });

    widget.onUpdate(widget.scannedItem
        .copyWith(count: _currentValue, updated: DateTime.now()));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
