import 'package:flutter/material.dart';

class GroupBox extends StatelessWidget {
  final Widget child;
  final String title;
  final Color titleBackground;
  final double width;
  final double? height;
  final String? errorText;
  const GroupBox(
      {required this.child,
      required this.title,
      required this.titleBackground,
      this.width = double.maxFinite,
      this.height,
      this.errorText,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> stackChildren = <Widget>[
      Container(
        child: child,
        height: height,
        width: width,
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 16),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade700, width: 1),
          borderRadius: BorderRadius.circular(5),
          shape: BoxShape.rectangle,
        ),
      ),
      Positioned(
          left: 16,
          top: 4,
          child: Container(
            padding: const EdgeInsets.only(bottom: 0, left: 2, right: 2),
            color: titleBackground,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          )),
    ];

    if (errorText != null) {
      stackChildren.add(
        Positioned(
            left: 4,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 2, left: 2, right: 2),
              color: titleBackground,
              child: Text(
                errorText!,
                style: const TextStyle(color: Colors.deepOrange, fontSize: 12),
              ),
            )),
      );
    }
    return Stack(children: stackChildren);
  }
}
