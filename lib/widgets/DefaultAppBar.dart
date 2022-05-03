import 'package:flutter/material.dart';

PreferredSize buildAppBar(
    {required double appBarHeight,
    Widget? leading,
    List<Widget>? actions,
    Widget? title}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(appBarHeight),
    child: Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade800))),
      child: AppBar(
          title: title,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))),
          leading: leading,
          actions: actions),
    ),
  );
}
