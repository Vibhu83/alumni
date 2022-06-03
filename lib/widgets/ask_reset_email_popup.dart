import 'package:alumni/globals.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:alumni/widgets/my_alert_dialog.dart';
import 'package:flutter/material.dart';

class ResetEmailPopUp extends StatefulWidget {
  final String email;
  const ResetEmailPopUp({this.email = "", Key? key}) : super(key: key);

  @override
  State<ResetEmailPopUp> createState() => _ResetEmailPopUpState();
}

class _ResetEmailPopUpState extends State<ResetEmailPopUp> {
  late TextEditingController _email;
  String? _emailError;
  void Function()? _onPressed;

  @override
  void initState() {
    _email = TextEditingController(text: widget.email);
    super.initState();
  }

  void checkEmail(String email) {
    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (email.isEmpty || !emailExp.hasMatch(email)) {
      setState(() {
        _onPressed = null;
        _emailError = "Invalid Email";
      });
    } else {
      setState(() {
        _onPressed = () async {
          await auth!.sendPasswordResetEmail(email: email);
          Navigator.of(context).pop();
        };
        _emailError = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
        height: screenHeight * 0.1,
        actions: [
          TextButton(
              onPressed: _onPressed,
              child: const Text("Send password reset email"))
        ],
        title: const Text("Enter your email"),
        content: InputField(
          onChanged: (p0) {
            checkEmail(p0);
          },
          labelText: "Email",
          controller: _email,
          errorText: _emailError,
        ));
  }
}
