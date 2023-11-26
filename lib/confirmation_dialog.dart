import 'package:flutter/material.dart';

class DialogAction {
  final String name;
  final void Function()? action;
  final int? id;

  DialogAction(this.name, this.action, [this.id]);
}

Future<void> showConfirmationDialog(BuildContext context, String title,
    String message, List<DialogAction>? actions) async {
  return await showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            icon: const Icon(Icons.delete_outline_outlined),
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
