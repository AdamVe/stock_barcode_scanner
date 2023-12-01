import 'package:flutter/material.dart';

class DialogAction {
  final String name;
  final void Function()? action;
  final int? id;

  DialogAction(this.name, this.action, [this.id]);
}

Future<void> showConfirmationDialog(
  BuildContext context,
  String title,
  String message, {
  List<DialogAction>? actions,
  Icon? icon,
}) async {
  return await showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            icon: icon,
            title: Text(title),
            content: Text(message),
            actions: actions
                    ?.map((a) => TextButton(
                          onPressed: () {
                            a.action?.call();
                            Navigator.of(context).pop(a.id);
                          },
                          child: Text(a.name),
                        ))
                    .toList(growable: false) ??
                [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Close'),
                  )
                ]);
      });
}
