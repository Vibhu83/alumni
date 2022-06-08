import 'package:alumni/globals.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/group_box.dart';
import 'package:flutter/material.dart';

class UserFilterPopUp extends StatefulWidget {
  const UserFilterPopUp({Key? key}) : super(key: key);

  @override
  State<UserFilterPopUp> createState() => _UserFilterPopUpState();
}

class _UserFilterPopUpState extends State<UserFilterPopUp> {
  late bool _showAlumni;
  late bool _showStudents;
  late bool _showAdmins;
  late int _currentChoiceValue;
  late bool _isAscendingOrder;
  @override
  void initState() {
    _isAscendingOrder = true;
    _currentChoiceValue = 7;
    _showAdmins = true;
    _showAlumni = true;
    _showStudents = true;
    super.initState();
  }

  Future<bool> _getDesignations() async {
    if (designations == null) {
      designations = {};

      await firestore!.collection("users").get().then((value) {
        return value.docs.map((e) {
          String? currentDesignation = e.data()["currentDesignation"];
          if (currentDesignation != null) {
            if (designations![currentDesignation] == null) {
              designations![currentDesignation] = 1;
            } else {
              designations![currentDesignation] =
                  designations![currentDesignation]! + 1;
            }
          }
        });
      });
      return true;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getDesignations(),
        builder: (context, snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GroupBox(
                  titleBackground: Theme.of(context).canvasColor,
                  title: "By Type",
                  child: Container(
                    height: screenHeight * 0.075,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            bool nextValue = true;
                            int changeInChoiceValue = 0;
                            if (_showStudents == true) {
                              nextValue = false;
                              changeInChoiceValue = -1;
                            } else {
                              nextValue = true;
                              changeInChoiceValue = 1;
                            }
                            setState(() {
                              _showStudents = nextValue;
                              _currentChoiceValue += changeInChoiceValue;
                            });
                          },
                          child: Text(
                            "Students",
                            style: TextStyle(
                                fontSize: screenWidth * 0.025,
                                color: Theme.of(context)
                                    .appBarTheme
                                    .foregroundColor),
                          ),
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              onPrimary: Colors.transparent,
                              primary: _showStudents == true
                                  ? Colors.blueAccent.withOpacity(0.3)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .shadowColor!
                                      .withOpacity(0.2)),
                              fixedSize: Size(
                                  screenWidth * 0.15, screenHeight * 0.01)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            bool nextValue = true;
                            int changeInChoiceValue = 0;
                            if (_showAlumni == true) {
                              nextValue = false;
                              changeInChoiceValue = -2;
                            } else {
                              nextValue = true;
                              changeInChoiceValue = 2;
                            }
                            setState(() {
                              _showAlumni = nextValue;
                              _currentChoiceValue += changeInChoiceValue;
                            });
                          },
                          child: Text(
                            "Alumni",
                            style: TextStyle(
                                fontSize: screenWidth * 0.025,
                                color: Theme.of(context)
                                    .appBarTheme
                                    .foregroundColor),
                          ),
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              onPrimary: Colors.transparent,
                              primary: _showAlumni == true
                                  ? Colors.blueAccent.withOpacity(0.3)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .shadowColor!
                                      .withOpacity(0.2)),
                              fixedSize: Size(
                                  screenWidth * 0.15, screenHeight * 0.01)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            int changeInChoiceValue = 0;

                            bool nextValue = true;
                            if (_showAdmins == true) {
                              nextValue = false;
                              changeInChoiceValue = -4;
                            } else {
                              nextValue = true;
                              changeInChoiceValue = 4;
                            }
                            setState(() {
                              _showAdmins = nextValue;
                              _currentChoiceValue += changeInChoiceValue;
                            });
                          },
                          child: Text(
                            "Admins",
                            style: TextStyle(
                                fontSize: screenWidth * 0.027,
                                color: Theme.of(context)
                                    .appBarTheme
                                    .foregroundColor),
                          ),
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              onPrimary: Colors.transparent,
                              primary: _showAdmins == true
                                  ? Colors.blueAccent.withOpacity(0.3)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .shadowColor!
                                      .withOpacity(0.2)),
                              fixedSize: Size(
                                  screenWidth * 0.15, screenHeight * 0.01)),
                        ),
                        RotatedBox(
                          quarterTurns: 1,
                          child: IconButton(
                              color: _isAscendingOrder == false
                                  ? Theme.of(context)
                                      .appBarTheme
                                      .foregroundColor
                                  : Colors.grey,
                              splashRadius: 1,
                              onPressed: (() {
                                bool nextValue = true;
                                if (_isAscendingOrder) {
                                  nextValue = false;
                                }
                                setState(() {
                                  _isAscendingOrder = nextValue;
                                });
                              }),
                              icon: const Icon(Icons.compare_arrows_outlined)),
                        )
                      ],
                    ),
                  ),
                ),
                GroupBox(
                    child: const Text("By Course"),
                    title: "By Course",
                    titleBackground: Theme.of(context).canvasColor)
              ],
            );
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }
}
