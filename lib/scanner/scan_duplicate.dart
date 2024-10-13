import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:stock_barcode_scanner/theme.dart';

import '../domain/models.dart';

class ScanDuplicate extends ConsumerStatefulWidget {
  final ScannedItem scannedItem;
  final Function(ScannedItem) onUpdate;
  final Function() onClose;

  const ScanDuplicate(
      {required this.scannedItem,
      required this.onUpdate,
      required this.onClose,
      super.key});

  @override
  ConsumerState<ScanDuplicate> createState() => _ScanDuplicateState();
}

class _ScanDuplicateState extends ConsumerState<ScanDuplicate> {
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
    return Theme(
      data: ref.watch(themeDataProvider(Brightness.dark)),
      child: BottomSheet(
        onClosing: () {},
        builder: (context) {
          final textStyle = Theme.of(context).textTheme.bodyMedium;
          final colorTheme = Theme.of(context).colorScheme;
          final primaryColor = colorTheme.primary;
          final baseTextStyle =
              textStyle?.copyWith(color: colorTheme.onSurface);
          final codeTextStyle =
              TextStyle(color: primaryColor, fontWeight: FontWeight.bold);
          return Padding(
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
                                  color: primaryColor,
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RichText(
                                      text: TextSpan(
                                          text: 'The code ',
                                          style: baseTextStyle,
                                          children: [
                                        TextSpan(
                                            text: widget.scannedItem.barcode,
                                            style: codeTextStyle),
                                        const TextSpan(
                                            text: ' has been '
                                                'recently scanned. To avoid duplicates, adjust '
                                                'number of same codes manually.\n\nOr scan a new item.'),
                                      ])))
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
          );
        },
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
