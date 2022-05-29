import 'package:alumni/firebase_options.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/views/register_page.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  /// Callback for when this form is submitted successfully. Parameters are (email, password)
  final Function(String? email, String? password)? onSubmitted;

  const LoginView({this.onSubmitted, Key? key}) : super(key: key);
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late TextEditingController _email, _password;
  String? emailError, passwordError;
  Function(String? email, String? password)? get onSubmitted =>
      widget.onSubmitted;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    emailError = null;
    passwordError = null;
    super.initState();
  }

  void resetErrorText() {
    setState(() {
      emailError = null;
      passwordError = null;
    });
  }

  bool validate() {
    resetErrorText();
    String email = _email.text;
    String password = _password.text;
    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    bool isValid = true;
    if (email.isEmpty || !emailExp.hasMatch(email)) {
      setState(() {
        emailError = "Email is invalid";
      });
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() {
        passwordError = "Please enter a password";
      });
      isValid = false;
    }

    return isValid;
  }

  Future<String?> loginUser() async {
    String email = _email.text;
    String password = _password.text;
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    try {
      await auth!
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        var temp = await firestore!
            .collection("users")
            .doc(value.user!.uid)
            .get()
            .then((value) {
          if (value.data() == null) {
            return false;
          } else {
            return true;
          }
        });
        if (temp == false) {
          return "User deleted";
        }
        emailPopUpShown = false;
        Navigator.of(context).popUntil(ModalRoute.withName(""));
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return const MainPage();
        }));
      });
      return "Logged In";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  void submit() {
    if (validate()) {
      showDialog(
          context: context,
          builder: (context) {
            return _buildLoginDialog();
          });
    }
  }

  Widget _buildLoginDialog() {
    return AlertDialog(
      // backgroundColor: Colors.grey.shade900,
      actions: [
        Container(
          padding: EdgeInsets.zero,
          child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Dismiss")),
        ),
      ],
      content: FutureBuilder(
        future: loginUser(),
        builder: ((context, AsyncSnapshot<String?> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            if (snapshot.data == "Logged In") {
              children = <Widget>[
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: screenWidth * 0.15,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    "User Registered",
                    style: TextStyle(color: Colors.green),
                  ),
                )
              ];
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
            children = buildFutureLoading(snapshot, text: "Logging you in");
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
    return Scaffold(
      // backgroundColor: const Color(backgroundColor),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            SizedBox(height: screenHeight * .12),
            const Text(
              "Welcome,",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * .01),
            const Text(
              "Sign in to continue!",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: screenHeight * .12),
            _buildEmailField(_email),
            SizedBox(height: screenHeight * .025),
            _buildPasswordField(_password),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(
                      // color: Colors.white,
                      ),
                ),
              ),
            ),
            SizedBox(
              height: screenHeight * .075,
            ),
            SizedBox(
              height: screenHeight * .065,
              width: double.maxFinite,
              child: TextButton(
                  child: const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 100, 122, 177)),
                  onPressed: submit),
            ),
            SizedBox(
              height: screenHeight * .15,
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterView(),
                ),
              ),
              child: RichText(
                text: TextSpan(
                  text: "I'm a new user, ",
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: const [
                    TextSpan(
                      text: "Sign Up",
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

  InputField _buildEmailField(TextEditingController _email) {
    return InputField(
      autoCorrect: false,
      labelText: "Email",
      controller: _email,
      errorText: emailError,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autoFocus: false,
    );
  }

  InputField _buildPasswordField(TextEditingController _password) {
    return InputField(
      autoCorrect: false,
      labelText: "Password",
      obscureText: true,
      controller: _password,
      textInputAction: TextInputAction.next,
    );
  }
}
