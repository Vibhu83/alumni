import 'package:alumni/ThemeData/dark_theme.dart';
import 'package:alumni/globals.dart';
import 'package:flutter/material.dart';

PreferredSize buildAppBar(
    {double? appBarHeight,
    Widget? leading,
    List<Widget>? actions,
    Widget? title}) {
  appBarHeight ??= screenHeight * 0.045;
  return PreferredSize(
    preferredSize: Size.fromHeight(appBarHeight),
    child: Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade800))),
      child: AppBar(
          title: title,
          shadowColor: Colors.transparent,
          backgroundColor: const Color(appBarColor),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))),
          leading: leading,
          actions: actions),
    ),
  );
}

IconButton buildAppBarIcon(
    {required void Function()? onPressed,
    required IconData icon,
    EdgeInsets padding = const EdgeInsets.fromLTRB(4, 4, 0, 4)}) {
  return IconButton(
    iconSize: 20,
    onPressed: onPressed,
    icon: Icon(icon),
    splashRadius: 1,
    padding: padding,
  );
}
