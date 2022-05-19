import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String labelText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onTap;
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
  final bool readOnly;
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
      this.readOnly = false,
      this.onTap,
      Key? key})
      : super(key: key);

  String? getError() {
    return errorText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 1),
      child: TextField(
        onTap: onTap,
        readOnly: readOnly,
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
          labelStyle: TextStyle(
              color: errorText == null
                  ? Theme.of(context)
                      .inputDecorationTheme
                      .enabledBorder!
                      .borderSide
                      .color
                  : Colors.red),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade800, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
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
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
