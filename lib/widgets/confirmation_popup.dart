import 'package:alumni/globals.dart';
import 'package:alumni/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';

class ConfirmationPopUp extends StatelessWidget {
  final String title;
  const ConfirmationPopUp({this.title = "Are you sure?", Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
        actionsMainAxisAlignment: MainAxisAlignment.spaceEvenly,
        height: screenHeight * 0.01,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("No")),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Yes")),
        ],
        title: Text(title),
        content: null);
  }
}
