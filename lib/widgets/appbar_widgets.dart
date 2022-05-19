import 'package:alumni/globals.dart';
import 'package:flutter/material.dart';

PreferredSize buildAppBar(
    {double? appBarHeight,
    double? leadingWidth,
    Color? background,
    Color? shadowColor,
    Widget? leading,
    List<Widget>? actions,
    Widget? title}) {
  appBarHeight ??= screenHeight * 0.045;
  return PreferredSize(
    preferredSize: Size.fromHeight(appBarHeight),
    child: AppBar(
        titleSpacing: null,
        centerTitle: true,
        leadingWidth: leadingWidth,
        flexibleSpace: SizedBox(
          height: appBarHeight,
        ),
        shadowColor: shadowColor,
        // foregroundColor: currentTheme!.appBarIconColor,
        backgroundColor: background,
        title: title,
        // shadowColor: currentTheme!.appBarBorderColor,
        elevation: 1,
        leading: leading,
        actions: actions),
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
