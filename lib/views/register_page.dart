import 'package:alumni/ThemeData/dark_theme.dart';
import 'package:alumni/classes/dark_picker_theme.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/login_page.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/group_box.dart';
import 'package:alumni/widgets/year_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class RegisterView extends StatefulWidget {
  final Function(String? email, String? password)? onSubmitted;

  const RegisterView({this.onSubmitted, Key? key}) : super(key: key);

  @override
  _RegisterView createState() => _RegisterView();
}

class _RegisterView extends State<RegisterView> {
  late TextEditingController _email, _password, _confirmPassword, _id, _name;
  String? courseValue;
  late bool switchValue;

  late String signUpAs;
  late String buttonText;
  String? emailError,
      passwordError,
      nameError,
      idError,
      batchYearError,
      courseError;

  late int? _batchYear;
  Function(String? email, String? password)? get onSubmitted =>
      widget.onSubmitted;

  double _strength = 0;
  String _displayText = "";

  @override
  void initState() {
    switchValue = false;
    signUpAs = "User";
    buttonText = "Sign Up";
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    _id = TextEditingController();
    _name = TextEditingController();
    _batchYear = null;

    emailError = null;
    passwordError = null;
    nameError = null;
    idError = null;
    batchYearError = null;

    super.initState();
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
      batchYearError = null;
      nameError = null;
      idError = null;
    });
  }

  bool validate() {
    resetErrorText();
    String? email, password, id, name, batchYear;

    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    bool isValid = true;
    if (_name.text.isEmpty) {
      name = "Please enter a name";
      isValid = false;
    }
    if (_id.text.isNotEmpty) {
      if (int.tryParse(_id.text) == null) {
        id = "ID must only have digits";
        isValid = false;
      } else if (_id.text.length < 6) {
        id = "ID must be of 6 digits";
        isValid = false;
      }
    }

    if (_email.text.isEmpty || !emailExp.hasMatch(_email.text)) {
      email = "Email is invalid";
      isValid = false;
    }

    if (_password.text.isEmpty || _confirmPassword.text.isEmpty) {
      password = "Please enter a password";
      isValid = false;
    } else if (_password.text != _confirmPassword.text) {
      password = "Passwords do not match";
      isValid = false;
    }
    setState(() {
      nameError = name;
      idError = id;
      emailError = email;
      passwordError = password;
      batchYearError = batchYear;
    });
    return isValid;
  }

  Future<String?> registerUserAndSaveDetails() async {
    String id = _id.text;
    String name = _name.text;
    String email = _email.text;
    String password = _password.text;
    String batchYear = _batchYear.toString();
    String accessLevel = "user";
    if (switchValue == true) {
      accessLevel = "alumni";
    }
    String? alumniDetails;
    if (switchValue == false) {
      alumniDetails = null;
    }
    String course;
    if (courseValue != null) {
      course = courseValue!;
    } else {
      course = "";
    }

    try {
      await auth!
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((userRecord) {
        var uid = userRecord.user?.uid;
        firestore!.collection("eventAttendanceStatus").doc(uid).set({});
        firestore!.collection("userVotes").doc(uid).set({});
        firestore!.collection("users").doc(uid).set({
          "uid": uid,
          "id": id,
          "name": name,
          "email": email,
          "batch": batchYear,
          "course": course,
          "alumni": switchValue,
          "alumni-details": alumniDetails,
          "accessLevel": accessLevel,
        }).then((value) {
          Navigator.of(context).popUntil(ModalRoute.withName(""));
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const MainPage();
          }));
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return const MainPage();
          // }));
        });
      });
      return "Registered";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Widget _buildRegisteringDialog() {
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      actions: [
        Container(
          padding: EdgeInsets.zero,
          child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Dismiss")),
        ),
      ],
      content: FutureBuilder(
        future: registerUserAndSaveDetails(),
        builder: ((context, AsyncSnapshot<String?> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            if (snapshot.data == "Registered") {
              children = <Widget>[
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: screenWidth * 0.15,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    "User Logged In",
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
            children = buildFutureLoading(snapshot, text: "Registering");
          }
          return Container(
            height: screenHeight * 0.325,
            width: screenWidth,
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 5),
            decoration: BoxDecoration(color: Colors.grey.shade900),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        }),
      ),
    );
  }

  void submit() {
    _checkPassword(_password.text);
    if (validate()) {
      showDialog(
          context: context,
          builder: (context) {
            return _buildRegisteringDialog();
          });
    }
  }

  String? nationalityChosen;
  bool? isNRI = null;

  @override
  Widget build(BuildContext context) {
    Widget otherNationalityInputField = const SizedBox();
    if (nationalityChosen == "Other") {
      otherNationalityInputField = const InputField(
        labelText: "Other Nationality",
      );
    }

    List<Widget> additionalDetails = [const SizedBox()];
    if (switchValue == true) {
      additionalDetails = [
        SizedBox(
          height: screenHeight * 0.02,
        ),
        const Text(
          "Additional Details",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        buildPadding(.04, context),
        const Text(
          "Personal Details",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        buildPadding(.01, context),
        const InputField(
          labelText: "Mother's Name*",
        ),
        const InputField(
          labelText: "Father's Name*",
        ),
        GroupBox(
            child: TextButton(
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      theme: getDarkDatePickerTheme());
                },
                child: RichText(
                    text: const TextSpan(
                        text: "Select date",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                        )))),
            title: "Data of Birth*",
            titleBackground: const Color(backgroundColor)),
        InputField(
          labelText: "Permanent/Correspondence Address*",
          maxLines: (screenHeight * 0.01).toInt(),
        ),
        _buildYearOfLeavingField(),
        GroupBox(
            height: screenHeight * 0.18,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 50,
                      width: screenWidth * 0.40,
                      child: Row(children: [
                        Radio<String>(
                          value: "Indian",
                          groupValue: nationalityChosen,
                          onChanged: (String? newValue) {
                            setState(() {
                              nationalityChosen = newValue;
                            });
                          },
                        ),
                        const Text("Indian")
                      ]),
                    ),
                    SizedBox(
                      height: 50,
                      width: screenWidth * 0.40,
                      child: Row(children: [
                        Radio<String>(
                          value: "Other",
                          groupValue: nationalityChosen,
                          onChanged: (String? newValue) {
                            setState(() {
                              nationalityChosen = newValue;
                            });
                          },
                        ),
                        const Text("Other")
                      ]),
                    ),
                  ],
                ),
                otherNationalityInputField
              ],
            ),
            title: "Nationality",
            titleBackground: const Color(backgroundColor)),
        GroupBox(
            height: screenHeight * 0.08,
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      height: 50,
                      width: screenWidth * 0.40,
                      child: Row(children: [
                        Radio<bool>(
                          value: true,
                          groupValue: isNRI,
                          onChanged: (bool? newValue) {
                            setState(() {
                              isNRI = newValue;
                            });
                          },
                        ),
                        const Text("Yes")
                      ]),
                    ),
                    SizedBox(
                      height: 50,
                      width: screenWidth * 0.40,
                      child: Row(children: [
                        Radio<bool>(
                          value: false,
                          groupValue: isNRI,
                          onChanged: (bool? newValue) {
                            setState(() {
                              isNRI = newValue;
                            });
                          },
                        ),
                        const Text("No")
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            title: "NRI*",
            titleBackground: const Color(backgroundColor)),
        const InputField(
          labelText: "Achievements & Awards",
        ),
        buildPadding(.04, context),
        const Text(
          "Spouse's Details",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        buildPadding(.01, context),
        const InputField(
          labelText: "Name of spouse",
        ),
        const InputField(
          labelText: "Name of spouse's organization",
        ),
        const InputField(
          labelText: "Designation",
        ),
        GroupBox(
            child: TextButton(
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      theme: getDarkDatePickerTheme());
                },
                child: const Text("Select date")),
            title: "Working since",
            titleBackground: const Color(backgroundColor)),
        const InputField(
          labelText: "Contact No.(Office)",
          keyboardType: TextInputType.phone,
        ),
        const InputField(
          labelText: "Contact No.(Mobile)*",
          keyboardType: TextInputType.phone,
        ),
        buildPadding(.04, context),
        const Text(
          "Current Organization",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        buildPadding(.01, context),
        const InputField(
          labelText: "Name of the current organization",
        ),
        const InputField(
          labelText: "Desigation",
        ),
        GroupBox(
            child: TextButton(
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      theme: getDarkDatePickerTheme());
                },
                child: const Text("Select date")),
            title: "Working since",
            titleBackground: const Color(backgroundColor)),
        const InputField(
          labelText: "Contact No.(Residence)",
          keyboardType: TextInputType.phone,
        ),
        const InputField(
          labelText: "Contact No.(Office)",
          keyboardType: TextInputType.phone,
        ),
        const InputField(
          labelText: "Contact No.(Mobile)*",
          keyboardType: TextInputType.phone,
        ),
        buildPadding(.04, context),
        const Text(
          "Previous Organization",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        buildPadding(.01, context),
        const InputField(
          labelText: "Name of the previous organization",
        ),
        const InputField(
          labelText: "Desigation",
        ),
        GroupBox(
            child: TextButton(
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      theme: getDarkDatePickerTheme());
                },
                child: const Text("Select date")),
            title: "Were working for since",
            titleBackground: const Color(backgroundColor)),
        const InputField(
          labelText: "Contact No.(Office)",
          keyboardType: TextInputType.phone,
        ),
      ];
    }
    List<Widget> form = [
      buildPadding(0.005, context),
      _buildRegisterTitle(),
      _buildIdField(_id),
      buildPadding(0.015, context),
      _buildNameField(_name),
      buildPadding(0.015, context),
      _buildEmailField(_email),
      buildPadding(0.015, context),
      _buildPasswordField(_password),
      buildPadding(0.005, context),
      _buildPasswordStrengthProgress(_strength),
      buildPadding(0.015, context),
      _buildConfirmPasswordField(_confirmPassword),
      buildPadding(0.015, context),
      _buildYearOfAdmissionField(),
      _buildCourseDropDown(),
      buildPadding(0.001, context),
      _buildSwitch(),
      buildPadding(0.015, context),
    ];
    form.addAll(additionalDetails);
    form.addAll([
      buildPadding(0.015, context),
      SizedBox(
        height: screenHeight * .065,
        width: double.maxFinite,
        child: TextButton(
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 100, 122, 177)),
            onPressed: submit),
      ),
      buildPadding(.01, context),
    ]);

    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      bottomNavigationBar: TextButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const LoginView();
          }));
        },
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            text: "I'm already a member, ",
            style: TextStyle(color: Colors.white),
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
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(backgroundColor)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Flexible(child: ListView(children: form)),
          ],
        ),
      ),
    );
  }

  SizedBox buildPadding(double size, BuildContext context) {
    return SizedBox(
      height: screenHeight * size,
    );
  }

  Column _buildRegisterTitle() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          color: Colors.white.withOpacity(.6),
        ),
      ),
      buildPadding(0.025, context),
    ]);
  }

  Widget _buildYearOfAdmissionField() {
    String text = "Select Year";
    if (_batchYear != null) {
      text = _batchYear.toString();
    }
    return GroupBox(
        errorText: batchYearError,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
        child: TextButton(
            style: TextButton.styleFrom(),
            onPressed: () {
              DatePicker.showPicker(context,
                      pickerModel: CustomYearPicker(
                        currentTime: DateTime.now(),
                        minYear: 1990,
                      ),
                      theme: getDarkDatePickerTheme())
                  .then((value) {
                setState(() {
                  if (value != null) {
                    _batchYear = value.year;
                  } else {
                    _batchYear = null;
                  }
                });
              });
            },
            child: RichText(
                text: TextSpan(
                    text: text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    )))),
        title: "Year of Admission*",
        titleBackground: const Color(backgroundColor));
  }

  Widget _buildYearOfLeavingField() {
    String text = "Select Year";
    return GroupBox(
        errorText: batchYearError,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
        child: TextButton(
            style: TextButton.styleFrom(),
            onPressed: () {
              DatePicker.showPicker(context,
                  pickerModel: CustomYearPicker(
                    currentTime: DateTime.now(),
                    minYear: 1990,
                  ),
                  theme: getDarkDatePickerTheme());
            },
            child: RichText(
                text: TextSpan(
                    text: text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    )))),
        title: "Year of Leaving*",
        titleBackground: const Color(backgroundColor));
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
      labelText: "ID(Optional)",
      controller: _id,
      maxLength: 6,
      keyboardType: TextInputType.number,
      errorText: idError,
    );
  }

  InputField _buildNameField(TextEditingController _name) {
    return InputField(
      autoCorrect: false,
      labelText: "Name*",
      errorText: nameError,
      controller: _name,
    );
  }

  InputField _buildPasswordField(TextEditingController _password) {
    return InputField(
      autoCorrect: false,
      labelText: "Password*",
      obscureText: true,
      controller: _password,
      onChanged: (value) => _checkPassword(value),
      textInputAction: TextInputAction.next,
    );
  }

  InputField _buildConfirmPasswordField(
      TextEditingController _confirmPassword) {
    return InputField(
      onSubmitted: (value) => submit(),
      labelText: "Confirm Password*",
      errorText: passwordError,
      obscureText: true,
      textInputAction: TextInputAction.done,
      controller: _confirmPassword,
    );
  }

  Widget _buildCourseDropDown() {
    return GroupBox(
      titleBackground: const Color(backgroundColor),
      title: "Course",
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButton(
            icon: null,
            underline: null,
            isExpanded: true,
            value: courseValue,
            style: const TextStyle(fontSize: 14),
            items: <String>[
              "B.A.",
              "B.Com",
              "B.Sc",
              "B.B.A.",
              "B.B.A.-MS",
              "B.C.A.",
              "B.Com-Hons.",
              "B.A.J.M.C",
              "B.Voc-Banking & Finance",
              "B.Voc-Software Development & E-Governance",
              "M.Com",
              "M.A.(Anthropology)",
              "M.A.(English)",
              "M.A.(Economics)",
              "M.A.(Geography)",
              "M.A. (Political Science)",
              "M.A.(Psychology)",
              "M.Voc-Banking, Stock, & Insurance",
              "M.Voc-Software & E-Governance"
            ]
                .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                          child: Text(value),
                          value: value,
                        ))
                .toList(),
            onChanged: (String? newValue) {
              setState(() {
                courseValue = newValue!;
              });
            }),
      ),
    );
  }

  Widget _buildSwitch() {
    return Row(
      children: [
        SizedBox(
          width: screenWidth * 0.35,
          child: Text(
            "Sign up as " + signUpAs,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Switch(
          activeColor: Colors.green,
          value: switchValue,
          onChanged: (value) {
            String temp1;
            String temp2;
            if (value == true) {
              temp1 = "Alumni";
              temp2 = "Next";
            } else {
              temp1 = "User";
              temp2 = "Sign Up";
            }
            setState(() {
              signUpAs = temp1;
              buttonText = temp2;
              switchValue = value;
            });
          },
        ),
      ],
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
        style: TextStyle(
          fontSize: 10,
          color: _strength <= 1 / 4
              ? Colors.red
              : _strength == 2 / 4
                  ? Colors.orange
                  : _strength == 3 / 4
                      ? Colors.yellow
                      : Colors.green,
        ),
      ),
    ]);
  }
}
