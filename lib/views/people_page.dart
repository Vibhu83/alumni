import 'package:alumni/globals.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:flutter/material.dart';

class PeoplePage extends StatefulWidget {
  final bool isInSelectionMode;
  const PeoplePage({this.isInSelectionMode = false, Key? key})
      : super(key: key);

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
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
    if (widget.isInSelectionMode) {
      currentChoiceValue = 6;
      showAdmins = true;
      showAlumni = true;
      showStudents = false;
    }
    super.initState();
  }

  Future<List<Map<String, dynamic>>> getUserData() async {
    List<Map<String, dynamic>> allUsersData;

    switch (currentChoiceValue) {
      case 0:
        allUsersData = [];
        break;

      case 1:
        allUsersData = await firestore!
            .collection("users")
            .where("accessLevel", isEqualTo: "student")
            .get()
            .then((value) {
          return value.docs.map((e) {
            return e.data();
          }).toList();
        });
        break;

      case 2:
        allUsersData = await firestore!
            .collection("users")
            .where("accessLevel", isEqualTo: "alumni")
            .get()
            .then((value) {
          return value.docs.map((e) {
            return e.data();
          }).toList();
        });
        break;

      case 3:
        allUsersData = await firestore!
            .collection("users")
            .where("accessLevel", isNotEqualTo: "admin")
            .get()
            .then((value) {
          return value.docs.map((e) {
            return e.data();
          }).toList();
        });
        break;

      case 4:
        allUsersData = await firestore!
            .collection("users")
            .where("accessLevel", isEqualTo: "admin")
            .get()
            .then((value) {
          return value.docs.map((e) {
            return e.data();
          }).toList();
        });
        break;

      case 5:
        allUsersData = await firestore!
            .collection("users")
            .where("accessLevel", isNotEqualTo: "alumni")
            .get()
            .then((value) {
          return value.docs.map((e) {
            return e.data();
          }).toList();
        });
        break;

      case 6:
        allUsersData = await firestore!
            .collection("users")
            .where("accessLevel", isNotEqualTo: "student")
            .get()
            .then((value) {
          return value.docs.map((e) {
            return e.data();
          }).toList();
        });
        break;
      default:
        allUsersData = await firestore!
            .collection("users")
            .orderBy("name")
            .get()
            .then((value) {
          return value.docs.map((e) {
            return e.data();
          }).toList();
        });
        break;
    }

    allUsersData.sort((a, b) {
      String nameA = a["name"];
      String nameB = b["name"];
      if (isAscendingOrder) {
        return nameA.compareTo(nameB);
      } else {
        return nameB.compareTo(nameA);
      }
    });

    return allUsersData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserData(),
        builder:
            ((context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            List<Map<String, dynamic>> allUserData = snapshot.data!;
            print(snapshot.data);
            return ListView.builder(
                itemCount: allUserData.length + 1,
                itemBuilder: ((context, index) {
                  index--;
                  if (index == -1) {
                    return _buildFilterBar();
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 12),
                      child: _buildUserCard(
                          allUserData[index], widget.isInSelectionMode),
                    );
                  }
                }));
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        }));
  }

  Widget _buildFilterBar() {
    return Container(
      height: screenHeight * 0.075,
      decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          border: Border(
              bottom: BorderSide(
                  color: Theme.of(context)
                      .appBarTheme
                      .shadowColor!
                      .withOpacity(0.2)))),
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
                  color: Theme.of(context).appBarTheme.foregroundColor),
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
                fixedSize: Size(screenWidth * 0.15, screenHeight * 0.01)),
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
                  color: Theme.of(context).appBarTheme.foregroundColor),
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
                fixedSize: Size(screenWidth * 0.15, screenHeight * 0.01)),
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
                  color: Theme.of(context).appBarTheme.foregroundColor),
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
                fixedSize: Size(screenWidth * 0.15, screenHeight * 0.01)),
          ),
          RotatedBox(
            quarterTurns: 1,
            child: IconButton(
                color: isAscendingOrder == false
                    ? Theme.of(context).appBarTheme.foregroundColor
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
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isInSelectionMode) {
    print(user);
    String subTitle = user["accessLevel"];
    subTitle = subTitle.substring(0, 1).toUpperCase() + subTitle.substring(1);
    String? currentDesignation = user["currentDesignation"];
    currentDesignation ??= "";
    String? currentOrg = user["currentOrgName"];
    currentOrg ??= "";
    if (currentDesignation != "" && currentOrg != "") {
      subTitle = currentDesignation + " at " + currentOrg;
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 4, top: 4),
      shadowColor: Theme.of(context).appBarTheme.shadowColor!.withOpacity(0.5),
      elevation: 1,
      child: ListTile(
        onTap: isInSelectionMode
            ? () {
                String name = user["name"];
                String uid = user["uid"];
                String? description;
                if (user["currentDesignation"] != null &&
                    user["currentDesignation"] != "" &&
                    user["currentOrgName"] != null &&
                    user["currentOrgName"] != "") {
                  description = user["currentDesignation"] +
                      " at " +
                      user["currentOrgName"];
                }
                Navigator.of(context).pop(
                    {"uid": uid, "name": name, "description": description});
              }
            : () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ProfilePage(uid: user["uid"])));
              },
        minLeadingWidth: 56,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: CircleAvatar(
          radius: 56,
          backgroundImage: NetworkImage(user["imageUrl"]),
        ),
        title: Text(
          user["name"],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subTitle,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}
