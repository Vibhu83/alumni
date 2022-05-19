// import 'package:alumni/ThemeData/dark_theme.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/login_page.dart';
import 'package:alumni/views/register_page.dart';
import 'package:flutter/material.dart';

class LoginRegisterPopUp extends StatelessWidget {
  const LoginRegisterPopUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context).appBarTheme.shadowColor!))),
          alignment: Alignment.center,
          child: TextButton(
              onPressed: (() {
                Navigator.of(context).pop();
              }),
              child: const Text("Dismiss")),
        )
      ],
      contentPadding:
          const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16),
      backgroundColor: Theme.of(context).canvasColor,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "You are not logged in!",
            style: TextStyle(
              color: Theme.of(context).appBarTheme.foregroundColor!,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 3),
          Text(
            "Login or Register to access all the features",
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context)
                  .appBarTheme
                  .foregroundColor!
                  .withOpacity(0.75),
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginView(),
                ),
              );
            },
            child: Container(
              width: double.maxFinite / 2,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xff2E933C),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterView(),
                ),
              );
            },
            child: Container(
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(
                vertical: 13,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(
                    8,
                  ),
                ),
                border: Border.all(
                  color: Theme.of(context).appBarTheme.shadowColor!,
                  width: 1,
                ),
              ),
              child: Text(
                'Register now',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).appBarTheme.foregroundColor!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
