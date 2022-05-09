import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class CustomYearPicker extends CommonPickerModel {
  String digits(int value, int length) {
    return '$value'.padLeft(length, "0");
  }

  int minYear;
  CustomYearPicker(
      {required DateTime currentTime,
      required this.minYear,
      LocaleType locale = LocaleType.en})
      : super(locale: locale) {
    this.currentTime = currentTime;
    setLeftIndex(this.currentTime.hour);
    setMiddleIndex(this.currentTime.year);
    setRightIndex(this.currentTime.second);
  }

  @override
  String? leftStringAtIndex(int index) {
    return null;
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= minYear && index < currentTime.year) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    return null;
  }

  @override
  String leftDivider() {
    return "";
  }

  @override
  String rightDivider() {
    return "";
  }

  @override
  List<int> layoutProportions() {
    return [1, 10, 1];
  }

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(currentMiddleIndex())
        : DateTime(currentMiddleIndex());
  }
}
