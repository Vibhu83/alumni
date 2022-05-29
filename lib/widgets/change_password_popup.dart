import 'package:alumni/globals.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:alumni/widgets/my_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePasswordPopUp extends StatefulWidget {
  const ChangePasswordPopUp({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPopUp> createState() => _ChangePasswordPopUpState();
}

class _ChangePasswordPopUpState extends State<ChangePasswordPopUp> {
  late TextEditingController _currentPassword = TextEditingController();
  late TextEditingController _newPassword = TextEditingController();

  double _strength = 0;
  String _displayText = "";

  @override
  void initState() {
    _currentPassword = TextEditingController();
    _newPassword = TextEditingController();
    super.initState();
  }

  InputField _buildCurrentPasswordField() {
    return InputField(
      autoCorrect: false,
      labelText: "Current Password",
      obscureText: true,
      controller: _currentPassword,
      textInputAction: TextInputAction.next,
    );
  }

  InputField _buildNewPasswordField() {
    return InputField(
      autoCorrect: false,
      labelText: "New Password*",
      obscureText: true,
      controller: _newPassword,
      onChanged: (value) => _checkPassword(value),
      textInputAction: TextInputAction.next,
    );
  }

  Column _buildPasswordStrengthProgress() {
    return Column(children: [
      LinearProgressIndicator(
        value: _strength,
        backgroundColor: Colors.grey[300],
        color: _strength <= 1 / 4
            ? Colors.red
            : _strength == 2 / 4
                ? Colors.orange
                : _strength == 3 / 4
                    ? Colors.yellow
                    : Colors.green,
        minHeight: 5,
      ),
      const SizedBox(
        height: 1,
      ),

      // The message about the strength of the entered password
      SizedBox(height: screenHeight * 0.005),
      Text(
        _displayText,
        style: TextStyle(
          fontSize: 12,
          color: _strength <= 1 / 4
              ? Colors.red.shade800
              : _strength == 2 / 4
                  ? Colors.orange
                  : _strength == 3 / 4
                      ? Colors.yellow
                      : Colors.green,
        ),
      ),
    ]);
  }

  void _checkPassword(String value) {
    RegExp numReg = RegExp(r".*[0-9].*");
    RegExp specialReg = RegExp(r".*[#$%_@&].*");
    String password = value.trim();
    double str = 0;
    String text = "";
    if (password.isEmpty) {
      str = 0;
      text = "Please enter your password";
    } else if (password.length < 8) {
      str = 1 / 4;
      text = "Password is too short";
    } else if (password.length < 16) {
      str = 2 / 4;
      text = "Acceptable but not strong";
    } else {
      if (!specialReg.hasMatch(password) || !numReg.hasMatch(password)) {
        str = 3 / 4;
        text = "Password is strong";
      } else {
        str = 1;
        text = "Your password is very strong";
      }
    }
    setState(() {
      _strength = str;
      _displayText = text;
    });
  }

  bool validate() {
    bool isValid = true;
    if (_currentPassword.text.isEmpty) {
      isValid = false;
    }
    if (_newPassword.text.isEmpty) {
      isValid = false;
    }
    return isValid;
  }

  Future<String> _changePassword() async {
    if (validate() == false) {
      return "";
    }
    String email = userData["email"];
    String password = _currentPassword.text;
    String newPassword = _newPassword.text;

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return await auth!.currentUser!.updatePassword(newPassword).then((_) {
        return "Successfully changed password";
      }).catchError((error) {
        return "Password can't be changed" + error.toString();
        //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return e.message.toString();
      }
    }
  }

  Widget _buildRegisteringDialog() {
    return AlertDialog(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      actions: [
        Container(
          padding: EdgeInsets.zero,
          child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Dismiss")),
        ),
      ],
      content: FutureBuilder(
        future: _changePassword(),
        builder: ((context, AsyncSnapshot<String?> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            if (snapshot.data == "Successfully changed password") {
              children = <Widget>[
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: screenWidth * 0.15,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    "Successfully changed password",
                    style: TextStyle(color: Colors.green),
                  ),
                )
              ];
              Navigator.of(context).pop(true);
            } else {
              children = <Widget>[
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: screenWidth * 0.15,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    snapshot.data!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              ];
            }
          } else {
            children = buildFutureLoading(snapshot, text: "Registering");
          }
          return Container(
            height: screenHeight * 0.325,
            width: screenWidth,
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 5),
            // decoration: BoxDecoration(color: Colors.grey.shade900),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
        height: screenHeight * 0.25,
        actions: [
          TextButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return _buildRegisteringDialog();
                    }).then((value) {
                  if (value == true) {
                    Navigator.of(context).pop(true);
                  }
                });
              },
              child: const Text("Submit"))
        ],
        title: const Text("Change Password"),
        content: Column(
          children: [
            _buildCurrentPasswordField(),
            _buildNewPasswordField(),
            _buildPasswordStrengthProgress()
          ],
        ));
  }
}
