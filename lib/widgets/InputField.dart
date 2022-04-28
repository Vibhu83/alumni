import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String labelText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autoFocus;
  final bool autoCorrect;
  final bool obscureText;
  final int? maxLength;
  final double heightPadding;
  final TextEditingController? controller;
  final int maxLines;
  const InputField(
      {this.labelText = "",
      this.onChanged,
      this.onSubmitted,
      this.errorText,
      this.keyboardType,
      this.textInputAction,
      this.autoFocus = false,
      this.obscureText = false,
      this.autoCorrect = true,
      this.controller,
      this.maxLength,
      this.heightPadding = 16,
      this.maxLines = 1,
      Key? key})
      : super(key: key);

  String? getError() {
    return errorText;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: maxLength,
      controller: controller,
      autocorrect: autoCorrect,
      autofocus: autoFocus,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      maxLines: maxLines,
      decoration: InputDecoration(
        focusColor: Colors.blue,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 10, vertical: heightPadding),
        label: Text(
          labelText,
          textAlign: TextAlign.left,
        ),
        errorText: errorText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelAlignment: FloatingLabelAlignment.start,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
