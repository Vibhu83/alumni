// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:alumni/widgets/InputField.dart';
import 'package:alumni/widgets/PaddingBox.dart';

import '../widgets/FormButton.dart';

class RegisterView extends StatefulWidget {
  /// Callback for when this form is submitted successfully. Parameters are (email, password)
  final Function(String? email, String? password)? onSubmitted;

  const RegisterView({this.onSubmitted, Key? key}) : super(key: key);

  @override
  _RegisterView createState() => _RegisterView();
}

class _RegisterView extends State<RegisterView> {
  late TextEditingController _email, _password, _confirmPassword, _id, _name;

  String? emailError, passwordError, nameError, idError;
  Function(String? email, String? password)? get onSubmitted =>
      widget.onSubmitted;

  double _strength = 0;
  String _displayText = "";

  @override
  void initState() {
    super.initState();

    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    _id = TextEditingController();
    _name = TextEditingController();

    emailError = null;
    passwordError = null;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _id.dispose();
    _name.dispose();

    super.dispose();
  }

  void resetErrorText() {
    setState(() {
      emailError = null;
      passwordError = null;
    });
  }

  bool validate() {
    resetErrorText();
    late String email, password, confirmPassword;

    email = _email.text;
    password = _password.text;
    confirmPassword = _confirmPassword.text;
    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    bool isValid = true;
    if (email.isEmpty || !emailExp.hasMatch(email)) {
      setState(() {
        emailError = "Email is invalid";
      });
      isValid = false;
    }

    if (password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        passwordError = "Please enter a password";
      });
      isValid = false;
    }
    if (password != confirmPassword) {
      setState(() {
        passwordError = "Passwords do not match";
      });
      isValid = false;
    }
    return isValid;
  }

  void submit() {
    if (validate()) {
      if (onSubmitted != null) {
        onSubmitted!(_email.text, _password.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            _buildRegisterTitle(),
            _buildIdField(_id),
            buildPadding(.005, context),
            _buildNameField(_name),
            buildPadding(0.025, context),
            _buildEmailField(_email),
            buildPadding(.025, context),
            _buildPasswordField(_password),
            buildPadding(.01, context),
            _buildPasswordStrengthProgress(_strength),
            buildPadding(.01, context),
            _buildConfirmPasswordField(_confirmPassword),
            buildPadding(.075, context),
            //const BatchYearPicker(),
            FormButton(
              text: "Sign Up",
              onPressed: submit,
            ),
            buildPadding(.125, context),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: RichText(
                text: const TextSpan(
                  text: "I'm already a member, ",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Sign In",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Column _buildRegisterTitle() {
    return Column(children: [
      buildPadding(.03, context),
      const Text(
        "Create Account,",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      buildPadding(.01, context),
      Text(
        "Sign up to get started!",
        style: TextStyle(
          fontSize: 18,
          color: Colors.black.withOpacity(.6),
        ),
      ),
      buildPadding(0.06, context),
    ]);
  }

  InputField _buildEmailField(TextEditingController _email) {
    return InputField(
      autoCorrect: false,
      labelText: "Email",
      controller: _email,
      errorText: emailError,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autoFocus: false,
      heightPadding: 4,
    );
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

  InputField _buildIdField(TextEditingController _id) {
    return InputField(
      autoCorrect: false,
      labelText: "ID",
      controller: _id,
      maxLength: 6,
      keyboardType: TextInputType.number,
      heightPadding: 4,
      errorText: idError,
    );
  }

  InputField _buildNameField(TextEditingController _name) {
    return InputField(
      autoCorrect: false,
      labelText: "Name",
      errorText: nameError,
      controller: _name,
      heightPadding: 4,
    );
  }

  InputField _buildPasswordField(TextEditingController _password) {
    return InputField(
      autoCorrect: false,
      labelText: "Password",
      obscureText: true,
      controller: _password,
      onChanged: (value) => _checkPassword(value),
      textInputAction: TextInputAction.next,
      heightPadding: 4,
    );
  }

  InputField _buildConfirmPasswordField(
      TextEditingController _confirmPassword) {
    return InputField(
      onSubmitted: (value) => submit(),
      labelText: "Confirm Password",
      errorText: passwordError,
      obscureText: true,
      textInputAction: TextInputAction.done,
      controller: _confirmPassword,
      heightPadding: 4,
    );
  }

  Column _buildPasswordStrengthProgress(double _strength) {
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
      Text(
        _displayText,
        style: const TextStyle(fontSize: 10),
      ),
    ]);
  }
}
