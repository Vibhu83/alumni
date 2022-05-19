import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

getDarkDatePickerTheme({
  TextStyle cancelStyle =
      const TextStyle(color: Colors.deepOrange, fontSize: 16),
  TextStyle doneStyle = const TextStyle(color: Colors.blue, fontSize: 16),
  TextStyle itemStyle = const TextStyle(color: Colors.white, fontSize: 18),
  Color backgroundColor = const Color(0xff1F1F1F),
  Color? headerColor,
  double containerHeight = 210.0,
  double titleHeight = 44.0,
  double itemHeight = 36.0,
}) {
  return DatePickerTheme(
      cancelStyle: cancelStyle,
      doneStyle: doneStyle,
      itemStyle: itemStyle,
      backgroundColor: backgroundColor,
      headerColor: headerColor,
      containerHeight: containerHeight,
      titleHeight: titleHeight,
      itemHeight: itemHeight);
}

getLightPickerTheme({
  TextStyle cancelStyle =
      const TextStyle(color: Colors.deepOrange, fontSize: 16),
  TextStyle doneStyle = const TextStyle(color: Colors.blue, fontSize: 16),
  TextStyle itemStyle = const TextStyle(color: Colors.black, fontSize: 18),
  Color? backgroundColor,
  Color? headerColor,
  double containerHeight = 210.0,
  double titleHeight = 44.0,
  double itemHeight = 36.0,
}) {
  backgroundColor ??= Colors.teal.shade50;
  return DatePickerTheme(
      cancelStyle: cancelStyle,
      doneStyle: doneStyle,
      itemStyle: itemStyle,
      backgroundColor: backgroundColor,
      headerColor: headerColor,
      containerHeight: containerHeight,
      titleHeight: titleHeight,
      itemHeight: itemHeight);
}
