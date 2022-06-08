import 'package:alumni/globals.dart';
import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final List<Widget>? actions;
  final Widget? title;
  final Widget? content;
  final double? height;
  final EdgeInsets titlePadding;
  final MainAxisAlignment actionsMainAxisAlignment;
  const CustomAlertDialog(
      {required this.actions,
      required this.title,
      required this.content,
      this.titlePadding = EdgeInsets.zero,
      this.actionsMainAxisAlignment = MainAxisAlignment.center,
      this.height,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double height;
    this.height == null ? height = screenHeight * 0.5 : height = this.height!;
    return AlertDialog(
        elevation: 1,
        backgroundColor: Theme.of(context).cardColor,
        titlePadding: titlePadding,
        actions: actions != null
            ? [
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color:
                                  Theme.of(context).appBarTheme.shadowColor!))),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: actionsMainAxisAlignment,
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
        content: content != null
            ? SizedBox(
                height: height,
                width: double.maxFinite,
                child: SingleChildScrollView(child: content),
              )
            : null);
  }
}
