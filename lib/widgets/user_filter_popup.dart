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
  late bool showAlumni;
  late bool showStudents;
  late bool showAdmins;
  late int currentChoiceValue;
  late bool isAscendingOrder;
  @override
  void initState() {
    isAscendingOrder = true;
    currentChoiceValue = 7;
    showAdmins = true;
    showAlumni = true;
    showStudents = true;
    super.initState();
  }

  Future<bool> getDesignations() async {
    if (designations == null) {
      print(designations);
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
        future: getDesignations(),
        builder: (context, snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            print(designations);
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
                            if (showStudents == true) {
                              nextValue = false;
                              changeInChoiceValue = -1;
                            } else {
                              nextValue = true;
                              changeInChoiceValue = 1;
                            }
                            setState(() {
                              showStudents = nextValue;
                              currentChoiceValue += changeInChoiceValue;
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
                              primary: showStudents == true
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
                            if (showAlumni == true) {
                              nextValue = false;
                              changeInChoiceValue = -2;
                            } else {
                              nextValue = true;
                              changeInChoiceValue = 2;
                            }
                            setState(() {
                              showAlumni = nextValue;
                              currentChoiceValue += changeInChoiceValue;
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
                              primary: showAlumni == true
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
                            if (showAdmins == true) {
                              nextValue = false;
                              changeInChoiceValue = -4;
                            } else {
                              nextValue = true;
                              changeInChoiceValue = 4;
                            }
                            setState(() {
                              showAdmins = nextValue;
                              currentChoiceValue += changeInChoiceValue;
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
                              primary: showAdmins == true
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
                              color: isAscendingOrder == false
                                  ? Theme.of(context)
                                      .appBarTheme
                                      .foregroundColor
                                  : Colors.grey,
                              splashRadius: 1,
                              onPressed: (() {
                                bool nextValue = true;
                                if (isAscendingOrder) {
                                  nextValue = false;
                                }
                                setState(() {
                                  isAscendingOrder = nextValue;
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
