import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final List<Widget>? actions;
  final Widget? title;
  final Widget? content;
  final double height;
  const CustomAlertDialog(
      {required this.actions,
      required this.title,
      required this.content,
      this.height = 400,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Theme.of(context).canvasColor,
        titlePadding: EdgeInsets.zero,
        actions: actions != null
            ? [
                Container(
                  decoration: BoxDecoration(
                      border:
                          Border(top: BorderSide(color: Colors.grey.shade800))),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: actions!),
                )
              ]
            : null,
        title: title != null
            ? Container(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, top: 20, bottom: 10),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color:
                                Theme.of(context).appBarTheme.shadowColor!))),
                child: title)
            : null,
        content: SizedBox(
          height: height,
          width: double.maxFinite,
          child: SingleChildScrollView(child: content),
        ));
  }
}
