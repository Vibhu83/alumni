import 'package:alumni/globals.dart';
import 'package:alumni/views/edit_profile.dart';
import 'package:alumni/views/posts_by_id.dart';
import 'package:alumni/widgets/add_alumni_popup.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/confirmation_popup.dart';
import 'package:alumni/widgets/group_box.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:alumni/widgets/custom_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_initicon/flutter_initicon.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({required this.uid, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> _user = {};
  late TextEditingController _about;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _getUserDetails() async {
    if (userData["uid"] == widget.uid) {
      _user = userData;
      return true;
    } else {
      var temp = await firestore!.collection("users").doc(widget.uid).get();
      Map<String, dynamic> userDataFromFirebase = temp.data()!;
      _user = userDataFromFirebase;
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getUserDetails(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          _about = TextEditingController(text: _user["about"]);
          List<Widget> appBarActions = [];
          Widget delUserButton = buildAppBarIcon(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return const ConfirmationPopUp(
                        title: "Add to Admin Team?",
                      );
                    }).then((value) {
                  if (value == true) {
                    firestore!.collection("users").doc(_user["uid"]).delete();
                    deleteStorageFolder(_user["uid"]);
                    firestore!
                        .collection("eventAttendanceStatus")
                        .doc(_user["uid"])
                        .delete();
                    firestore!
                        .collection("userVotes")
                        .doc(_user["uid"])
                        .delete();
                    firestore!
                        .collection("topAlumni")
                        .doc(_user["uid"])
                        .delete();
                    firestore!
                        .collection("chatRooms")
                        .where("userIds", arrayContains: _user["uid"])
                        .get()
                        .then((value) {
                      for (var e in value.docs) {
                        firestore!.collection("chatRooms").doc(e.id).delete();
                      }
                    });
                    if (_user["uid"] == userData["uid"]) {
                      auth!.signOut();
                    }
                    Navigator.of(context).pop(-1);
                  }
                });
              },
              icon: Icons.delete_rounded);

          Widget editUserButton = buildAppBarIcon(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: ((context) => const EditProfilePage())))
                  .then((value) {
                setState(() {});
              });
            },
            icon: Icons.edit_rounded,
          );

          Widget addToTopAlumniButton = buildAppBarIcon(
              onPressed: () {
                String about = "";
                showDialog(
                    context: context,
                    builder: (context) {
                      return AddAlumniPopUp(
                        uid: _user["uid"],
                      );
                    });
                // firestore!.collection("topAlumni").doc(_user["uid"]).set({});
              },
              icon: Icons.notification_add_rounded);
          Widget addToAdminTeamButton = buildAppBarIcon(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return const ConfirmationPopUp(
                        title: "Are you sure?",
                      );
                    }).then((value) {
                  if (value == true) {
                    firestore!
                        .collection("users")
                        .doc(_user["uid"])
                        .update({"hasAdminAccess": true, "userType": "admin"});
                    lastUserWasMadeAdmin = true;
                    setState(() {
                      _user["hasAdminAccess"] = true;
                      _user["userType"] = "admin";
                    });
                  }
                });
              },
              icon: Icons.add_moderator);
          if (userData["uid"] == widget.uid) {
            appBarActions.add(editUserButton);
            appBarActions.add(delUserButton);
          } else if (userData["hasAdminAccess"] == true) {
            if (_user["isAnAlumni"] == true) {
              appBarActions.add(addToTopAlumniButton);
            }
            if (_user["hasAdminAccess"] != true) {
              appBarActions.add(addToAdminTeamButton);

              appBarActions.add(delUserButton);
            }
          }
          List<Widget> bottomBarWidgets = [];
          if (userData["uid"] != _user["uid"] && userData["uid"] != null) {
            bottomBarWidgets.addAll([
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    chat!.createRoom(types.User(id: _user["uid"]));
                  },
                  child: const Text("Chat"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue.shade900,
                      fixedSize: Size(screenWidth * 0.95, screenHeight * 0.06)),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
            ]);
          }
          bottomBarWidgets.addAll([
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: ((context) {
                  return PostsByIDPage(uid: _user["uid"]);
                })));
              },
              child: const Text(" See Posts"),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32)),
                  primary: Colors.red,
                  fixedSize: Size(screenWidth * 0.95, screenHeight * 0.05)),
            ),
          ]);
          Widget bottomBar = Container(
            decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(
                        color: Theme.of(context)
                            .appBarTheme
                            .shadowColor!
                            .withOpacity(0.2))),
                color: Theme.of(context)
                    .appBarTheme
                    .backgroundColor!
                    .withOpacity(0.5)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: bottomBarWidgets,
            ),
          );
          return Scaffold(
              backgroundColor: Theme.of(context).canvasColor,
              bottomNavigationBar: bottomBar,
              appBar: buildAppBar(
                actions: appBarActions,
                leading: IconButton(
                  splashRadius: 0.1,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              body: SingleChildScrollView(
                child: _buildProfileSummary(),
              ));
        } else if (snapshot.hasError) {
          children = <Widget>[
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Error: ${snapshot.error}'),
            )
          ];
        } else {
          children = const <Widget>[
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            ),
          ];
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: children,
          ),
        );
      },
    );
  }

  Widget _buildProfileSummary() {
    String userType = _user["userType"];
    userType = userType.substring(0, 1).toUpperCase() + userType.substring(1);
    String occupation = "";
    String nationality = "";
    if (_user["currentDesignation"] != null &&
        _user["currentDesignation"] != "" &&
        _user["currentOrgName"] != null &&
        _user["currentOrgName"] != "") {
      occupation =
          _user["currentDesignation"] + " at " + _user["currentOrgName"];
    }

    if (_user["nationality"] != null && _user["nationality"] != "") {
      nationality = _user["nationality"];
    }
    List<Widget> userDetails;
    userDetails = [
      Align(
        alignment: Alignment.centerLeft,
        child: _user["profilePic"] != null
            ? CircleAvatar(
                radius: 48,
                backgroundImage: NetworkImage(_user["profilePic"]),
              )
            : Initicon(
                size: 96,
                text: _user["name"],
              ),
      ),
      SizedBox(
        height: screenHeight * 0.0125,
      ),
      Text(
        _user["name"],
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      SizedBox(height: screenHeight * 0.001),
      Text(
        userType,
        style: TextStyle(
            color: Theme.of(context)
                .appBarTheme
                .foregroundColor!
                .withOpacity(0.75),
            fontStyle: FontStyle.italic),
      )
    ];

    if (occupation != "") {
      userDetails.add(Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.007),
            Flexible(
              child: Text(
                occupation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .appBarTheme
                        .foregroundColor!
                        .withOpacity(0.9)),
              ),
            ),
            Flexible(
              child: Text(
                nationality,
                softWrap: false,
                style: TextStyle(
                    color: Theme.of(context)
                        .appBarTheme
                        .foregroundColor!
                        .withOpacity(0.9)),
              ),
            ),
          ]));
    }
    // if (_user["about"] != null && _user["about"] != "") {
    userDetails.addAll([
      Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.01),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: userData["uid"] == _user["uid"]
                  ? screenWidth * 0.79
                  : screenWidth * 0.91,
              child: GroupBox(
                  titleBackground: Colors.transparent,
                  margin: const EdgeInsets.only(bottom: 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  color: Theme.of(context)
                      .appBarTheme
                      .foregroundColor!
                      .withOpacity(0.5),
                  child: Text(
                    _about.text,
                    style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .appBarTheme
                            .foregroundColor!
                            .withOpacity(0.9)),
                  ),
                  title: ""),
            ),
            userData["uid"] != _user["uid"]
                ? const SizedBox()
                : IconButton(
                    splashRadius: 1,
                    iconSize: 20,
                    onPressed: () async {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return CustomAlertDialog(
                              height: screenHeight * 0.58,
                              title: const Text("About You"),
                              content: InputField(
                                controller: _about,
                                maxLines: (screenHeight * 0.028).toInt(),
                                keyboardType: TextInputType.multiline,
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      firestore!
                                          .collection("users")
                                          .doc(_user["uid"])
                                          .set({"about": _about.text},
                                              SetOptions(merge: true));
                                      userData["about"] = _about.text;
                                      Navigator.of(context).pop(_about.text);
                                    },
                                    child: const Center(child: Text("Submit")))
                              ],
                            );
                          }).then((value) {
                        setState(() {
                          _about = TextEditingController(text: value);
                        });
                      });
                    },
                    icon: const Icon(Icons.edit),
                  ),
          ],
        ),
      ),
      SizedBox(
        height: screenHeight * 0.025,
      ),
    ]);

    userDetails = [
      Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Theme.of(context)
                        .appBarTheme
                        .shadowColor!
                        .withOpacity(0.5)))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: userDetails,
        ),
      )
    ];
    userDetails.addAll([
      Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Theme.of(context)
                        .appBarTheme
                        .shadowColor!
                        .withOpacity(0.5)))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Contact at: ",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.email),
                    SizedBox(
                      width: screenWidth * 0.025,
                    ),
                    Text(_user["email"])
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                _user["mobileContactNo"] != null &&
                        _user["mobileContactNo"] != ""
                    ? Row(
                        children: [
                          const Icon(Icons.phone),
                          SizedBox(
                            width: screenWidth * 0.025,
                          ),
                          Text(_user["mobileContactNo"])
                        ],
                      )
                    : const SizedBox()
              ],
            ),
          ),
        ]),
      )
    ]);

    String collegeTimeSpan = _user["admissionYear"].toString();
    if (_user["passingYear"] != null && _user["passingYear"] != "") {
      collegeTimeSpan += " - " + _user["passingYear"].toString();
    } else {
      collegeTimeSpan += " - Now ";
    }

    userDetails.addAll([
      Container(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.025),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Theme.of(context)
                        .appBarTheme
                        .shadowColor!
                        .withOpacity(0.5)))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Education: ",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.timeline),
                    SizedBox(
                      width: screenWidth * 0.025,
                    ),
                    Text(collegeTimeSpan)
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.008,
                ),
                Row(
                  children: [
                    const Icon(Icons.school),
                    SizedBox(
                      width: screenWidth * 0.025,
                    ),
                    Text(_user["course"])
                  ],
                )
              ],
            ),
          ),
        ]),
      )
    ]);

    return Container(
      padding: EdgeInsets.fromLTRB(
          14, screenHeight * 0.025, 14, screenHeight * 0.025),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: userDetails,
      ),
    );
  }
}
