import 'package:alumni/globals.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final List<Widget>? actions;
  final Widget? title;
  final Widget? content;
  final double? height;
  final EdgeInsets titlePadding;
  const CustomAlertDialog(
      {required this.actions,
      required this.title,
      required this.content,
      this.titlePadding = EdgeInsets.zero,
      this.height,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height;
    this.height == null ? height = screenHeight * 0.5 : height = this.height!;
    return AlertDialog(
        backgroundColor: Theme.of(context).canvasColor,
        titlePadding: titlePadding,
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
