import 'package:flutter/material.dart';

SizedBox buildPadding(height, context) {
  double screenHeight = MediaQuery.of(context).size.height;
  return SizedBox(height: screenHeight * height);
}
