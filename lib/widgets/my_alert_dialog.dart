import 'package:flutter/material.dart';

Widget buildAlertDialog(
    {required List<Widget>? actions,
    required Widget? title,
    required Widget? content,
    double height = 400}) {
  if (title != null) {
    title = Container(
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade800))),
        child: title);
  }
  if (actions != null) {
    actions = [
      Container(
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade800))),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: actions),
      )
    ];
  }

  return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 25, 33, 36),
      titlePadding: EdgeInsets.zero,
      actions: actions,
      title: title,
      content: SizedBox(
        height: height,
        width: double.maxFinite,
        child: SingleChildScrollView(child: content),
      ));
}
