import 'package:alumni/globals.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/ask_message_popup.dart';
import 'package:alumni/widgets/group_box.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:alumni/widgets/my_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({required this.uid, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> data = {};
  late TextEditingController _about;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> getUserDetails() async {
    if (userData["uid"] == widget.uid) {
      data = userData;
      return true;
    } else {
      var temp = await firestore!.collection("users").doc(widget.uid).get();
      Map<String, dynamic> userDataFromFirebase = temp.data()!;
      data = userDataFromFirebase;
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserDetails(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          _about = TextEditingController(text: data["about"]);
          List<Widget> appBarActions = [];
          Widget delUserButton = buildAppBarIcon(
              onPressed: () {
                print("deleting profile");
              },
              icon: Icons.delete_rounded);

          Widget editUserButton = buildAppBarIcon(
            onPressed: () {
              print("editing profile");
            },
            icon: Icons.edit_rounded,
          );

          Widget addToTopAlumniButton = buildAppBarIcon(
              onPressed: () {
                String about = "";
                showDialog(
                    context: context,
                    builder: (context) {
                      return CustomAlertDialog(
                        height: screenHeight * 0.5,
                        title: const Text("About this alumni"),
                        actions: [
                          TextButton(
                              onPressed: () {
                                firestore!
                                    .collection("topAlumni")
                                    .doc(data["uid"])
                                    .set(
                                        {"uid": data["uid"], "message": about});
                              },
                              child: const Text("Submit"))
                        ],
                        content: InputField(
                          onChanged: ((p0) {
                            about = p0;
                            print(about);
                          }),
                          labelText: "About(Optional)",
                          maxLines: (screenHeight * 0.024).toInt(),
                        ),
                      );
                    });
                // firestore!.collection("topAlumni").doc(data["uid"]).set({});
              },
              icon: Icons.notification_add_rounded);
          if (userData["uid"] == widget.uid) {
            appBarActions.add(editUserButton);
            appBarActions.add(delUserButton);
          } else if (userData["accessLevel"] == "admin") {
            if (data["accessLevel"] == "alumni") {
              appBarActions.add(addToTopAlumniButton);
            }
            appBarActions.add(delUserButton);
          }
          List<Widget> bottomBarWidgets = [];
          if (userData["uid"] != data["uid"] && userData["uid"] != null) {
            bottomBarWidgets.addAll([
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    chat!.createRoom(types.User(id: data["uid"]));
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
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: const Text(" See Posts"),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      primary: Colors.red,
                      fixedSize: Size(screenWidth * 0.45, screenHeight * 0.05)),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: const Text("See Events"),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      primary: Colors.green.shade700,
                      fixedSize: Size(screenWidth * 0.45, screenHeight * 0.05)),
                )
              ],
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
    String userType = data["accessLevel"];
    String accessLevel =
        userType.substring(0, 1).toUpperCase() + userType.substring(1);
    String occupation = "";
    String nationality = "";
    if (data["currentDesignation"] != null &&
        data["currentDesignation"] != "" &&
        data["currentOrgName"] != null &&
        data["currentOrgName"] != "") {
      occupation = data["currentDesignation"] + " at " + data["currentOrgName"];
    }

    if (data["nationality"] != null && data["nationality"] != "") {
      nationality = "In " + data["nationality"];
    }
    List<Widget> userDetails;
    userDetails = [
      Align(
        alignment: Alignment.centerLeft,
        child: CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage(data["profilePic"]),
        ),
      ),
      SizedBox(
        height: screenHeight * 0.0125,
      ),
      Text(
        data["name"],
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      SizedBox(height: screenHeight * 0.001),
      Text(
        accessLevel,
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
    // if (data["about"] != null && data["about"] != "") {
    userDetails.addAll([
      Padding(
        padding: EdgeInsets.only(top: screenHeight * 0.01),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: userData["uid"] == data["uid"]
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
            userData["uid"] != data["uid"]
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
                                          .doc(data["uid"])
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
                    Text(data["email"])
                  ],
                ),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                data["mobileContactNo"] != null && data["mobileContactNo"] != ""
                    ? Row(
                        children: [
                          const Icon(Icons.phone),
                          SizedBox(
                            width: screenWidth * 0.025,
                          ),
                          Text(data["mobileContactNo"])
                        ],
                      )
                    : const SizedBox()
              ],
            ),
          ),
        ]),
      )
    ]);

    String collegeTimeSpan = data["admissionYear"].toString();
    if (data["passingYear"] != null && data["passingYear"] != "") {
      collegeTimeSpan += " - " + data["passingYear"].toString();
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
                    Text(data["course"])
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
