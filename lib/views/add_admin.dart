import 'dart:io';

import 'package:alumni/classes/date_picker_theme.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/login_page.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/group_box.dart';
import 'package:alumni/widgets/custom_alert_dialog.dart';
import 'package:alumni/widgets/year_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class AddAdmin extends StatefulWidget {
  final Function(String? email, String? password)? onSubmitted;

  const AddAdmin({this.onSubmitted, Key? key}) : super(key: key);

  @override
  _AddAdmin createState() => _AddAdmin();
}

class _AddAdmin extends State<AddAdmin> {
  XFile? _profilePic;

  late TextEditingController _email,
      _password,
      _confirmPassword,
      _rollNo,
      _name,
      _fatherName,
      _motherName,
      _address,
      _currentOrgName,
      _currentDesignation,
      _previousOrgName,
      _previousDesignation,
      _residenceContactNo,
      _currentOfficeContactNo,
      _mobileContactNo,
      _previousOfficeContactNo,
      _achievements,
      _spouseName,
      _spouseOrgName,
      _spouseDesignation,
      _spouseMobileContactNo,
      _spouseOfficeContactNo;

  DateTime? _inCurrentOrgSince,
      _wereInPreviousOrgSince,
      _spouseWorkingInOrgSince,
      _dob;

  String? _courseValue;

  bool? _isIndian;
  String? _nationality;

  bool? _isNRI;

  late bool _isAnAlumni;

  late String _signUpAs;

  String? _emailError,
      _passwordError,
      _nameError,
      _idError,
      _addmissionYearError,
      _courseError,
      _fatherNameError,
      _motherNameError,
      _dobError,
      _addressError,
      _passingYearError,
      _nationalityError,
      _nriError,
      _mobileContactError;

  late int? _addmissionYear, _passingYear;
  Function(String? email, String? password)? get onSubmitted =>
      widget.onSubmitted;

  double _strength = 0;
  String _displayText = "";

  @override
  void initState() {
    _profilePic = null;

    _isAnAlumni = false;
    _signUpAs = "User";

    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    _rollNo = TextEditingController();
    _name = TextEditingController();
    _fatherName = TextEditingController();
    _motherName = TextEditingController();
    _address = TextEditingController();
    _currentOrgName = TextEditingController();
    _currentDesignation = TextEditingController();
    _previousOrgName = TextEditingController();
    _previousDesignation = TextEditingController();
    _residenceContactNo = TextEditingController();
    _currentOfficeContactNo = TextEditingController();
    _mobileContactNo = TextEditingController();
    _previousOfficeContactNo = TextEditingController();
    _achievements = TextEditingController();
    _spouseName = TextEditingController();
    _spouseOrgName = TextEditingController();
    _spouseDesignation = TextEditingController();
    _spouseMobileContactNo = TextEditingController();
    _spouseOfficeContactNo = TextEditingController();

    _dob = null;
    _wereInPreviousOrgSince = null;
    _wereInPreviousOrgSince = null;
    _spouseWorkingInOrgSince = null;

    _addmissionYear = null;
    _passingYear = null;

    _courseValue = null;
    _isIndian = null;

    _isNRI = null;

    _emailError = null;
    _passwordError = null;
    _nameError = null;
    _idError = null;
    _addmissionYearError = null;
    _courseError = null;
    _fatherNameError = null;
    _motherNameError = null;
    _dobError = null;
    _addressError = null;
    _passingYearError = null;
    _nationalityError = null;
    _nriError = null;
    _mobileContactError = null;

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _rollNo.dispose();
    _name.dispose();
    _fatherName.dispose();
    _motherName.dispose();
    _address.dispose();
    _currentOrgName.dispose();
    _currentDesignation.dispose();
    _previousOrgName.dispose();
    _previousDesignation.dispose();
    _residenceContactNo.dispose();
    _currentOfficeContactNo.dispose();
    _mobileContactNo.dispose();
    _previousOfficeContactNo.dispose();
    _achievements.dispose();
    _spouseName.dispose();
    _spouseOrgName.dispose();
    _spouseDesignation.dispose();
    _spouseMobileContactNo.dispose();
    _spouseOfficeContactNo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> additionalDetailsWidgets = [const SizedBox()];
    if (_isAnAlumni == true) {
      additionalDetailsWidgets = getAdditionalDetailsWidget();
    }
    List<Widget> form = [
      _buildPadding(0.005),
      _buildHeading("Create Account,"),
      _buildPadding(.01),
      _buildSubHeading("Sign up to get started!"),
      _buildPadding(0.025),
      _buildProfilePicField(),
      _buildRollNoField(),
      _buildNameField(),
      _buildEmailField(),
      _buildPasswordField(),
      _buildPasswordStrengthProgress(),
      _buildConfirmPasswordField(),
      _buildYearOfAdmissionField(),
      _buildCourseDropDown(),
      _buildAlumniToggle(),
    ];
    form.addAll(additionalDetailsWidgets);
    form.addAll([
      _buildPadding(0.015),
      _buildSubmitButton(),
      _buildPadding(.01),
    ]);

    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color:
                Theme.of(context).appBarTheme.backgroundColor!.withOpacity(0.3),
            border: Border(
                top: BorderSide(
                    color: Theme.of(context)
                        .appBarTheme
                        .shadowColor!
                        .withOpacity(0.25)))),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return const LoginView();
            }));
          },
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "I'm already a member, ",
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color),
              children: const [
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
      ),
      body: Container(
        // decoration: const BoxDecoration(color: Color(backgroundColor)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Flexible(child: ListView(children: form)),
          ],
        ),
      ),
    );
  }

  List<Widget> getAdditionalDetailsWidget() {
    return [
      _buildPadding(0.02),
      _buildHeading("Additional Details"),
      _buildPadding(
        .04,
      ),
      //
      //
      _buildSubHeading("Personal Details"),
      _buildPadding(
        .01,
      ),
      //
      _buildMotherNameField(),
      _buildFatherNameField(),
      _buildDateOfBirthField(),
      _buildAddressField(),
      _buildYearOfLeavingField(),
      _buildNationalityField(),
      _buildNriField(),
      _buildAchievementField(),
      //
      //
      _buildPadding(.04),
      _buildSubHeading("Spouse's Details"),
      _buildPadding(.01),
      //
      _buildSpouseNameField(),
      _buildSpouseOrganisationField(),
      _buildSpouseDesignationField(),
      _buildSpouseWorkingSinceField(),
      _buildSpouseOfficeContactField(),
      _buildSpouseMobileContactField(),
      //
      //
      _buildPadding(.04),
      _buildSubHeading("Current Organization"),
      _buildPadding(.01),
      //
      _buildCurrentOrgNameField(),
      _buildCurrentDesignationField(),
      _buildWorkingInCurrentOrgSinceField(),
      _buildResidenceContactField(),
      _buildCurrentOfficeContactField(),
      _buildCurrentMobileContactField(),
      //
      //
      _buildPadding(.04),
      _buildSubHeading("Previous Organization"),
      _buildPadding(.01),
      //
      _buildPreviousOrgNameField(),
      _buildPreviousDesignationField(),
      _buildWereWorkingInPreviousOrgSinceField(),
      _buildPreviousOfficeContactField()
    ];
  }

  Widget _buildMotherNameField() {
    return InputField(
      controller: _motherName,
      errorText: _motherNameError,
      labelText: "Mother's Name*",
    );
  }

  Widget _buildFatherNameField() {
    return InputField(
      controller: _fatherName,
      errorText: _fatherNameError,
      labelText: "Father's Name*",
    );
  }

  Widget _buildDateOfBirthField() {
    String fieldText = "Select a date";
    if (_dob != null) {
      fieldText = formatDateTime(_dob!, showTime: false);
    }
    return GroupBox(
      titleBackground: Theme.of(context).canvasColor,
      errorText: _dobError,
      title: "Data of Birth*",
      // titleBackground: const Color(backgroundColor),
      child: TextButton(
          onPressed: () {
            DatePicker.showDatePicker(
              context,
              theme: Theme.of(context).brightness == Brightness.dark
                  ? getDarkDatePickerTheme()
                  : getLightPickerTheme(),
            ).then((value) {
              if (value != null) {
                setState(() {
                  _dob = value;
                });
              }
            });
          },
          child: Text(fieldText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ))),
    );
  }

  Widget _buildAddressField() {
    return InputField(
      controller: _address,
      errorText: _addressError,
      labelText: "Permanent/Correspondence Address*",
      maxLines: (screenHeight * 0.01).toInt(),
    );
  }

  Widget _buildNationalityField() {
    Widget otherNationalityInputField = const SizedBox();
    if (_isIndian == false) {
      otherNationalityInputField = InputField(
        onChanged: ((newValue) {
          setState(() {
            _nationality = newValue;
          });
        }),
        labelText: "Other Nationality*",
      );
    }

    return GroupBox(
      titleBackground: Theme.of(context).canvasColor,
      errorText: _nationalityError,
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
                    groupValue: _isIndian,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _isIndian = newValue;
                        _nationality = "Indian";
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
                  Radio<bool>(
                    value: false,
                    groupValue: _isIndian,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _isIndian = newValue;
                        _nationality = null;
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
      title: "Nationality*",
      // titleBackground: const Color(backgroundColor)
    );
  }

  Widget _buildNriField() {
    return GroupBox(
      titleBackground: Theme.of(context).canvasColor,
      errorText: _nriError,
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
                    groupValue: _isNRI,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _isNRI = newValue;
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
                    groupValue: _isNRI,
                    onChanged: (bool? newValue) {
                      setState(() {
                        _isNRI = newValue;
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
      // titleBackground: const Color(backgroundColor)
    );
  }

  Widget _buildAchievementField() {
    return InputField(
      controller: _achievements,
      labelText: "Achievements & Awards",
    );
  }

  Widget _buildSpouseNameField() {
    return InputField(
      controller: _spouseName,
      labelText: "Spouse's Name",
    );
  }

  Widget _buildSpouseOrganisationField() {
    return InputField(
      controller: _spouseOrgName,
      labelText: "Name of spouse's organization",
    );
  }

  Widget _buildSpouseDesignationField() {
    return InputField(
      controller: _spouseDesignation,
      labelText: "Spouse's Designation",
    );
  }

  Widget _buildSpouseWorkingSinceField() {
    String fieldText = "Select a date";
    if (_spouseWorkingInOrgSince != null) {
      fieldText = formatDateTime(_spouseWorkingInOrgSince!, showTime: false);
    }
    return GroupBox(
      titleBackground: Theme.of(context).canvasColor,
      child: TextButton(
          onPressed: () {
            DatePicker.showDatePicker(
              context,
              theme: Theme.of(context).brightness == Brightness.dark
                  ? getDarkDatePickerTheme()
                  : getLightPickerTheme(),
            ).then((value) {
              if (value != null) {
                setState(() {
                  _spouseWorkingInOrgSince = value;
                });
              }
            });
          },
          child: Text(fieldText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ))),
      title: "Working since",
      // titleBackground: const Color(backgroundColor)
    );
  }

  Widget _buildSpouseOfficeContactField() {
    return InputField(
      maxLength: 10,
      controller: _spouseOfficeContactNo,
      labelText: "Contact No.(Office)",
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildSpouseMobileContactField() {
    return InputField(
      maxLength: 10,
      controller: _spouseMobileContactNo,
      labelText: "Contact No.(Mobile)",
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildCurrentOrgNameField() {
    return InputField(
      controller: _currentOrgName,
      labelText: "Name of the current organization",
    );
  }

  Widget _buildCurrentDesignationField() {
    return InputField(
      controller: _currentDesignation,
      labelText: "Designation",
    );
  }

  Widget _buildWorkingInCurrentOrgSinceField() {
    String fieldText = "Select a date";
    if (_inCurrentOrgSince != null) {
      fieldText = formatDateTime(_inCurrentOrgSince!, showTime: false);
    }
    return GroupBox(
      titleBackground: Theme.of(context).canvasColor,
      child: TextButton(
          onPressed: () {
            DatePicker.showDatePicker(
              context,
              theme: Theme.of(context).brightness == Brightness.dark
                  ? getDarkDatePickerTheme()
                  : getLightPickerTheme(),
            ).then((value) {
              if (value != null) {
                setState(() {
                  _inCurrentOrgSince = value;
                });
              }
            });
          },
          child: Text(fieldText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ))),
      title: "Working since",
      // titleBackground: const Color(backgroundColor)
    );
  }

  Widget _buildResidenceContactField() {
    return InputField(
      maxLength: 10,
      controller: _residenceContactNo,
      labelText: "Contact No.(Residence)",
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildCurrentOfficeContactField() {
    return InputField(
      maxLength: 10,
      controller: _currentOfficeContactNo,
      labelText: "Contact No.(Office)",
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildCurrentMobileContactField() {
    return InputField(
      maxLength: 10,
      errorText: _mobileContactError,
      controller: _mobileContactNo,
      labelText: "Contact No.(Mobile)*",
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildPreviousOrgNameField() {
    return InputField(
      controller: _previousOrgName,
      labelText: "Name of the previous organization",
    );
  }

  Widget _buildPreviousDesignationField() {
    return InputField(
      controller: _previousDesignation,
      labelText: "Desigation",
    );
  }

  Widget _buildWereWorkingInPreviousOrgSinceField() {
    String fieldText = "Select a date";
    if (_wereInPreviousOrgSince != null) {
      fieldText = formatDateTime(_wereInPreviousOrgSince!, showTime: false);
    }
    return GroupBox(
      titleBackground: Theme.of(context).canvasColor,
      child: TextButton(
          onPressed: () {
            DatePicker.showDatePicker(
              context,
              theme: Theme.of(context).brightness == Brightness.dark
                  ? getDarkDatePickerTheme()
                  : getLightPickerTheme(),
            ).then((value) {
              if (value != null) {
                _wereInPreviousOrgSince = value;
              }
            });
          },
          child: Text(fieldText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ))),
      title: "Were working for since",
      // titleBackground: const Color(backgroundColor)
    );
  }

  Widget _buildPreviousOfficeContactField() {
    return InputField(
      maxLength: 10,
      controller: _previousOfficeContactNo,
      labelText: "Contact No.(Office)",
      keyboardType: TextInputType.phone,
    );
  }

  SizedBox _buildPadding(double size) {
    return SizedBox(
      height: screenHeight * size,
    );
  }

  Widget _buildHeading(String heading) {
    return Text(
      heading,
      style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).appBarTheme.foregroundColor),
    );
  }

  Widget _buildSubHeading(String subHeading) {
    return Text(
      subHeading,
      style: TextStyle(
          fontSize: 20,
          color:
              Theme.of(context).appBarTheme.foregroundColor!.withOpacity(0.8)),
    );
  }

  void resetErrorText() {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _nameError = null;
      _idError = null;
      _addmissionYearError = null;
      _courseError = null;
      _fatherNameError = null;
      _motherNameError = null;
      _dobError = null;
      _addressError = null;
      _passingYearError = null;
      _nationalityError = null;
      _nriError = null;
      _mobileContactError = null;
    });
  }

  bool validate() {
    resetErrorText();
    String? newEmailError,
        newPasswordError,
        newIdError,
        newNameError,
        newAddmissionError,
        newCourseError;

    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

    bool isValid = true;
    if (_name.text.isEmpty) {
      newNameError = "Invalid name";
      isValid = false;
    }
    if (_rollNo.text.isNotEmpty) {
      if (int.tryParse(_rollNo.text) == null) {
        newIdError = "ID must only have digits";
        isValid = false;
      } else if (_rollNo.text.length < 6) {
        newIdError = "ID must be of 6 digits";
        isValid = false;
      }
    }

    if (_email.text.isEmpty || !emailExp.hasMatch(_email.text)) {
      newEmailError = "Email is invalid";
      isValid = false;
    }

    if (_password.text.isEmpty || _confirmPassword.text.isEmpty) {
      newPasswordError = "Invalid Password";
      isValid = false;
    } else if (_password.text != _confirmPassword.text) {
      newPasswordError = "Passwords do not match";
      isValid = false;
    }
    if (_courseValue == null) {
      newCourseError = "Invalid course";
      isValid = false;
    }
    if (_addmissionYear == null) {
      newAddmissionError = "Invalid year";
      isValid = false;
    }

    if (_isAnAlumni) {
      isValid = validateAdditionalDetails();
    }

    setState(() {
      _nameError = newNameError;
      _idError = newIdError;
      _emailError = newEmailError;
      _passwordError = newPasswordError;
      _addmissionYearError = newAddmissionError;
      _courseError = newCourseError;
    });
    return isValid;
  }

  bool validateAdditionalDetails() {
    String? newFatherNameError,
        newMotherNameError,
        newDobError,
        newAddressError,
        newPassingYearError,
        newNationalityError,
        newNriError,
        newMobileContactError;

    bool validity = true;

    if (_motherName.text.isEmpty) {
      newMotherNameError = "Invalid Name";
      validity = false;
    }
    if (_fatherName.text.isEmpty) {
      newFatherNameError = "Invalid Name";
      validity = false;
    }
    if (_dob == null) {
      newDobError = "Invalid date";
      validity = false;
    }
    if (_address.text.isEmpty) {
      newAddressError = "Invalid address";
      validity = false;
    }
    if (_passingYear == null) {
      newPassingYearError = "Invalid year";
      validity = false;
    }
    if (_nationality == null || _nationality == "") {
      newNationalityError = "Invalid nationality";
      validity = false;
    }
    if (_isNRI == null) {
      newNriError = "Invalid selection";
      validity = false;
    }
    if (_mobileContactNo.text.isEmpty) {
      newMobileContactError = "Invalid Number";
      validity = false;
    } else {
      if (isNumerical(_mobileContactNo.text) != true ||
          _mobileContactNo.text.length < 10) {
        validity = false;
        newMobileContactError = "Invalid Number";
      }
    }
    setState(() {
      _fatherNameError = newFatherNameError;
      _motherNameError = newMotherNameError;
      _dobError = newDobError;
      _addressError = newAddressError;
      _passingYearError = newPassingYearError;
      _nationalityError = newNationalityError;
      _nriError = newNriError;
      _mobileContactError = newMobileContactError;
    });
    return validity;
  }

  String? ifStringEmptyReturnNull(String str) {
    if (str.isEmpty) {
      return null;
    } else {
      return str;
    }
  }

  Future<String?> registerUserAndSaveDetails() async {
    Map<String, dynamic> data = {};
    final String rollNo = _rollNo.text;
    final String name = _name.text;
    final String email = _email.text;
    final String password = _password.text;
    final int addmissionYear = _addmissionYear!;
    late final String userType;
    List<String> firstLastName = name.split(" ");
    //
    //
    final String previousOrgOfficeContactNo = _previousOfficeContactNo.text;
    if (_isAnAlumni == true) {
      userType = "alumni";
    } else {
      userType = "student";
    }
    final String course;
    if (_courseValue != null) {
      course = _courseValue!;
    } else {
      course = "";
    }
    try {
      await auth!
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((userRecord) async {
        var uid = userRecord.user!.uid;
        String? profilePicUrl;
        if (_profilePic != null) {
          profilePicUrl = await uploadFileAndGetLink(
              _profilePic!.path, uid.toString() + "/profilePicture", context);
        }
        chat!.createUserInFirestore(types.User(
            id: uid,
            firstName: firstLastName[0],
            lastName: firstLastName[1],
            imageUrl: profilePicUrl));
        firestore!.collection("userVotes").doc(uid).set({});
        firestore!.collection("eventAttendanceStatus").doc(uid).set({});
        firestore!.collection("users").doc(uid).set({
          "profilePic": profilePicUrl,
          "uid": uid,
          "rollNo": rollNo,
          "name": name,
          "firstName": firstLastName[0],
          "lastName": firstLastName[1],
          "email": email,
          "admissionYear": addmissionYear,
          "course": course,
          "isAnAlumni": _isAnAlumni,
          "userType": userType,
          "noticesDismissed": [""],
          "verified": null,
          "eventsBookmarked": [""],
          "postsBookmarked": [""]
        }, SetOptions(merge: true)).then((value) {
          data = {
            "profilePic": profilePicUrl,
            "uid": uid,
            "rollNo": rollNo,
            "name": name,
            "firstName": firstLastName[0],
            "lastName": firstLastName[1],
            "email": email,
            "admissionYear": addmissionYear,
            "course": course,
            "isAnAlumni": _isAnAlumni,
            "hasAdminAccess": false,
            "userType": userType,
            "noticesDismissed": [""],
            "verified": null,
            "eventsBookmarked": [""],
            "postsBookmarked": [""]
          };
          if (_isAnAlumni) {
            final String motherName = _motherName.text;
            final String fatherName = _fatherName.text;
            final Timestamp dob = Timestamp.fromDate(_dob!);
            final String address = _address.text;
            final int passingYear = _passingYear!;
            final String nationality = _nationality!;
            final bool isNRI = _isNRI!;
            final String achievements = _achievements.text;
            //
            //
            final String spouseName = _spouseName.text;
            final String spouseOrgName = _spouseOrgName.text;
            final String spouseDesignation = _spouseDesignation.text;
            late final Timestamp? spouseWorkingSince;

            if (_spouseWorkingInOrgSince != null) {
              Timestamp.fromDate(_spouseWorkingInOrgSince!);
            } else {
              spouseWorkingSince = null;
            }
            final String spouseOfficeContactNo = _spouseOfficeContactNo.text;
            final String spouseMobileContactNo = _spouseMobileContactNo.text;
            //
            //
            final String currentOrgName = _currentOrgName.text;
            final String currentDesignation = _currentDesignation.text;
            late final Timestamp? workingInCurrentOrgSince;
            if (_inCurrentOrgSince != null) {
              workingInCurrentOrgSince =
                  Timestamp.fromDate(_inCurrentOrgSince!);
            } else {
              workingInCurrentOrgSince = null;
            }
            final String residenceContactNo = _residenceContactNo.text;
            final String currentOfficeContactNo = _currentOfficeContactNo.text;
            final String mobileContactNo = _mobileContactNo.text;
            //
            //
            final String previousOrgName = _previousOrgName.text;
            final String previousDesignation = _previousDesignation.text;
            late final Timestamp? wereInPreviousOrgSince;
            if (_wereInPreviousOrgSince != null) {
              wereInPreviousOrgSince =
                  Timestamp.fromDate(_wereInPreviousOrgSince!);
            } else {
              wereInPreviousOrgSince = null;
            }
            firestore!.collection("users").doc(uid).set({
              "motherName": motherName,
              "fatherName": fatherName,
              "dateOfBirth": dob,
              "permanentAddress": address,
              "passingYear": passingYear,
              "nationality": nationality,
              "isNRI": isNRI,
              "achievements": achievements,
              //
              "spouseName": spouseName,
              "spouseOrgName": spouseOrgName,
              "spouseDesignation": spouseDesignation,
              "spouseWorkingInOrgSince": spouseWorkingSince,
              "spouseOfficeContactNo": spouseOfficeContactNo,
              "spouseMobileContactNo": spouseMobileContactNo,
              //
              "currentOrgName": currentOrgName,
              "currentDesignation": currentDesignation,
              "inCurrentOrgSince": workingInCurrentOrgSince,
              "residenceContactNo": residenceContactNo,
              "currentOfficeContactNo": currentOfficeContactNo,
              "mobileContactNo": mobileContactNo,
              //
              "previousOrgName": previousOrgName,
              "previousDesignation": previousDesignation,
              "wereInPreviousSince": wereInPreviousOrgSince,
              "previousOrgOfficeContactNo": previousOrgOfficeContactNo,
            }, SetOptions(merge: true)).then((value) {
              data.addAll({
                "motherName": motherName,
                "fatherName": fatherName,
                "dateOfBirth": dob,
                "permanentAddress": address,
                "passingYear": passingYear,
                "nationality": nationality,
                "isNRI": isNRI,
                "achievements": achievements,
                //
                "spouseName": spouseName,
                "spouseOrgName": spouseOrgName,
                "spouseDesignation": spouseDesignation,
                "spouseWorkingInOrgSince": spouseWorkingSince,
                "spouseOfficeContactNo": spouseOfficeContactNo,
                "spouseMobileContactNo": spouseMobileContactNo,
                //
                "currentOrgName": currentOrgName,
                "currentDesignation": currentDesignation,
                "inCurrentOrgSince": workingInCurrentOrgSince,
                "residenceContactNo": residenceContactNo,
                "currentOfficeContactNo": currentOfficeContactNo,
                "mobileContactNo": mobileContactNo,
                //
                "previousOrgName": previousOrgName,
                "previousDesignation": previousDesignation,
                "wereInPreviousSince": wereInPreviousOrgSince,
                "previousOrgOfficeContactNo": previousOrgOfficeContactNo,
              });
            });
          }
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return const MainPage();
          // }));
        });
      });
      await setUserLoginStatus(data: data);
      Navigator.of(context).popUntil(ModalRoute.withName(""));
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return const MainPage();
      }));
      return "Registered";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Widget _buildRegisteringDialog() {
    return CustomAlertDialog(
      height: screenHeight * 0.4,
      title: null,
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

  Widget _buildYearOfAdmissionField() {
    String text = "Select Year";
    if (_addmissionYear != null) {
      text = _addmissionYear.toString();
    }
    return GroupBox(
      titleBackground: Theme.of(context).canvasColor,
      errorText: _addmissionYearError,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
      child: TextButton(
          style: TextButton.styleFrom(),
          onPressed: () {
            DatePicker.showPicker(
              context,
              pickerModel: CustomYearPicker(
                currentTime: DateTime.now(),
                minYear: 1990,
              ),
              theme: Theme.of(context).brightness == Brightness.dark
                  ? getDarkDatePickerTheme()
                  : getLightPickerTheme(),
            ).then((value) {
              setState(() {
                if (value != null) {
                  _addmissionYear = value.year;
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
      // titleBackground: const Color(backgroundColor)
    );
  }

  Widget _buildYearOfLeavingField() {
    String text = "Select Year";
    if (_passingYear != null) {
      text = _passingYear.toString();
    }
    return GroupBox(
      titleBackground: Theme.of(context).canvasColor,
      errorText: _passingYearError,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
      child: TextButton(
          style: TextButton.styleFrom(),
          onPressed: () {
            DatePicker.showPicker(
              context,
              pickerModel: CustomYearPicker(
                currentTime: DateTime.now(),
                minYear: 1990,
              ),
              theme: Theme.of(context).brightness == Brightness.dark
                  ? getDarkDatePickerTheme()
                  : getLightPickerTheme(),
            ).then((value) {
              if (value != null) {
                setState(() {
                  _passingYear = value.year;
                });
              }
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
      title: "Year of Leaving*",
      // titleBackground: const Color(backgroundColor)
    );
  }

  InputField _buildEmailField() {
    return InputField(
      autoCorrect: false,
      labelText: "Email*",
      controller: _email,
      errorText: _emailError,
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

  Widget _buildProfilePicField() {
    return GroupBox(
      titleBackground: Theme.of(context).canvasColor,
      title: "Profile Picture",
      // titleBackground: const Color(backgroundColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: ListTile(
          trailing: _profilePic == null
              ? null
              : IconButton(
                  splashRadius: 1,
                  iconSize: 20,
                  onPressed: () {
                    setState(() {
                      _profilePic = null;
                    });
                  },
                  icon: const Icon(Icons.close)),
          title: _profilePic == null
              ? IconButton(
                  onPressed: () {
                    ImagePicker()
                        .pickImage(source: ImageSource.gallery)
                        .then((value) {
                      if (value != null) {
                        setState(() {
                          _profilePic = value;
                        });
                      }
                    });
                  },
                  icon: const Icon(Icons.add))
              : _buildImage(
                  _profilePic == null
                      ? () {}
                      : () {
                          ImagePicker()
                              .pickImage(source: ImageSource.gallery)
                              .then((value) {
                            if (value != null) {
                              setState(() {
                                _profilePic = value;
                              });
                            }
                          });
                        },
                  Image.file(File(_profilePic!.path))),
          onTap: _profilePic == null
              ? () {}
              : () {
                  ImagePicker()
                      .pickImage(source: ImageSource.gallery)
                      .then((value) {
                    if (value != null) {
                      setState(() {
                        _profilePic = value;
                      });
                    }
                  });
                },
        ),
      ),
    );
  }

  Widget _buildImage(void Function()? onClicked, Image image) {
    var imageProvider = image.image;
    // return AspectRatio(
    //   aspectRatio: 1,
    //   child: SizedBox(
    //     height: 64,
    //     width: 64,
    //     child: ClipRRect(
    //       borderRadius: BorderRadius.circular(360),
    //       child: Material(
    //         color: Colors.transparent,
    //         child: Ink.image(
    //           image: imageProvider,
    //           fit: BoxFit.cover,
    //           child: InkWell(
    //             onTap: onClicked,
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    return GestureDetector(
      onTap: onClicked,
      child: CircleAvatar(
        radius: 64,
        backgroundImage: imageProvider,
      ),
    );
  }

  InputField _buildRollNoField() {
    return InputField(
      autoCorrect: false,
      labelText: "College Roll No.",
      controller: _rollNo,
      maxLength: 6,
      keyboardType: TextInputType.number,
      errorText: _idError,
    );
  }

  InputField _buildNameField() {
    return InputField(
      autoCorrect: false,
      labelText: "Name*",
      errorText: _nameError,
      controller: _name,
    );
  }

  InputField _buildPasswordField() {
    return InputField(
      autoCorrect: false,
      labelText: "Password*",
      obscureText: true,
      controller: _password,
      onChanged: (value) => _checkPassword(value),
      textInputAction: TextInputAction.next,
    );
  }

  InputField _buildConfirmPasswordField() {
    return InputField(
      labelText: "Confirm Password*",
      errorText: _passwordError,
      obscureText: true,
      textInputAction: TextInputAction.done,
      controller: _confirmPassword,
    );
  }

  Widget _buildCourseDropDown() {
    return GroupBox(
      titleBackground: Theme.of(context).canvasColor,
      errorText: _courseError,
      // titleBackground: const Color(backgroundColor),
      title: "Course*",
      child: ButtonTheme(
        alignedDropdown: true,
        child: DropdownButton(
            icon: null,
            underline: const SizedBox(),
            isExpanded: true,
            value: _courseValue,
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
                          child: Text(value,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .foregroundColor)),
                          value: value,
                        ))
                .toList(),
            onChanged: (String? newValue) {
              setState(() {
                _courseValue = newValue!;
              });
            }),
      ),
    );
  }

  Widget _buildAlumniToggle() {
    return Row(
      children: [
        SizedBox(
          width: screenWidth * 0.35,
          child: Text(
            "Sign up as " + _signUpAs,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        Switch(
          activeColor: Colors.green,
          value: _isAnAlumni,
          onChanged: (value) {
            String nextSignUpAs;
            if (value == true) {
              nextSignUpAs = "Alumni";
            } else {
              nextSignUpAs = "User";
            }
            setState(() {
              _signUpAs = nextSignUpAs;
              _isAnAlumni = value;
            });
          },
        ),
      ],
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
      _buildPadding(0.005),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      height: screenHeight * .065,
      width: double.maxFinite,
      child: TextButton(
          child: const Text(
            "Submit",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 100, 122, 177)),
          onPressed: submit),
    );
  }
}
