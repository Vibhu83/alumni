import 'package:flutter/material.dart';

class GroupBox extends StatelessWidget {
  final Widget child;
  final String title;
  final Color? titleBackground;
  final double width;
  final double? height;
  final String? errorText;
  final EdgeInsets padding;
  const GroupBox(
      {required this.child,
      required this.title,
      this.titleBackground,
      this.width = double.maxFinite,
      this.height,
      this.errorText,
      this.padding = const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color borderColor =
        Theme.of(context).inputDecorationTheme.enabledBorder!.borderSide.color;
    if (errorText != null) {
      borderColor = Colors.red.shade800;
    }
    List<Widget> stackChildren = <Widget>[
      Container(
        child: child,
        height: height,
        width: width,
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 30),
        padding: padding,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(5),
          shape: BoxShape.rectangle,
        ),
      ),
      Positioned(
          left: 9,
          top: 4,
          child: Container(
            padding: const EdgeInsets.only(bottom: 0, left: 2, right: 2),
            color: Theme.of(context).canvasColor,
            child: Text(
              title,
              style: TextStyle(
                  color: errorText == null ? borderColor : Colors.red,
                  fontSize: 12),
            ),
          )),
    ];

    if (errorText != null) {
      stackChildren.add(
        Positioned(
            left: 9,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.only(bottom: 0, left: 2, right: 2),
              // color: titleBackgroun,
              child: Text(
                errorText!,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            )),
      );
    }
    return Stack(children: stackChildren);
  }
}
