import 'package:alumni/globals.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';

class PeoplePage extends StatefulWidget {
  final bool isInSelectionMode;
  const PeoplePage({this.isInSelectionMode = false, Key? key})
      : super(key: key);

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
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
    if (widget.isInSelectionMode) {
      _currentChoiceValue = 6;
      _showAdmins = true;
      _showAlumni = true;
      _showStudents = false;
    }
    super.initState();
  }

  Future<List<Map<String, dynamic>>> _getUserData() async {
    List<Map<String, dynamic>> allUsersData;

    switch (_currentChoiceValue) {
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
      if (_isAscendingOrder) {
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
        future: _getUserData(),
        builder:
            ((context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            List<Map<String, dynamic>> allUserData = snapshot.data!;
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
                      child: widget.isInSelectionMode == false
                          ? UserCard(
                              user: allUserData[index],
                              isInSelectionMode: widget.isInSelectionMode,
                            )
                          : _buildUserCard(
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
                  color: Theme.of(context).appBarTheme.foregroundColor),
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
                fixedSize: Size(screenWidth * 0.15, screenHeight * 0.01)),
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
                  color: Theme.of(context).appBarTheme.foregroundColor),
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
                fixedSize: Size(screenWidth * 0.15, screenHeight * 0.01)),
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
                  color: Theme.of(context).appBarTheme.foregroundColor),
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
                fixedSize: Size(screenWidth * 0.15, screenHeight * 0.01)),
          ),
          RotatedBox(
            quarterTurns: 1,
            child: IconButton(
                color: _isAscendingOrder == false
                    ? Theme.of(context).appBarTheme.foregroundColor
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
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isInSelectionMode) {
    String subTitle = user["accessLevel"];
    subTitle = subTitle.substring(0, 1).toUpperCase() + subTitle.substring(1);
    String? currentDesignation = user["currentDesignation"];
    currentDesignation ??= "";
    String? currentOrg = user["currentOrgName"];
    currentOrg ??= "";
    if (currentDesignation != "" && currentOrg != "") {
      subTitle = currentDesignation + " at " + currentOrg;
    }
    Widget leading = CircleAvatar(
        radius: 56, backgroundImage: NetworkImage(user["imageUrl"]));
    if (user["profilePic"] == null) {
      leading = CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 56,
        child: Initicon(
          size: 56,
          text: user["name"],
        ),
      );
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
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => ProfilePage(uid: user["uid"])))
                    .then((value) {
                  setState(() {});
                });
              },
        minLeadingWidth: 56,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: leading,
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

class UserCard extends StatefulWidget {
  final Map<String, dynamic> user;
  final bool isInSelectionMode;
  const UserCard({required this.user, this.isInSelectionMode = false, Key? key})
      : super(key: key);

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late bool returnEmpty;
  late Map<String, dynamic> user;

  @override
  void initState() {
    user = widget.user;
    if (widget.user["uid"] == userData["uid"]) {
      user = userData;
    }
    returnEmpty = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (returnEmpty == true) {
      return const SizedBox();
    } else {
      String subTitle = user["accessLevel"];
      subTitle = subTitle.substring(0, 1).toUpperCase() + subTitle.substring(1);
      String? currentDesignation = user["currentDesignation"];
      currentDesignation ??= "";
      String? currentOrg = user["currentOrgName"];
      currentOrg ??= "";
      if (currentDesignation != "" && currentOrg != "") {
        subTitle = currentDesignation + " at " + currentOrg;
      }
      Widget leading = CircleAvatar(
          radius: 56, backgroundImage: NetworkImage(widget.user["imageUrl"]));
      if (user["profilePic"] == null) {
        leading = CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 56,
          child: Initicon(
            size: 56,
            text: user["name"],
          ),
        );
      }
      return Card(
        margin: const EdgeInsets.only(bottom: 4, top: 4),
        shadowColor:
            Theme.of(context).appBarTheme.shadowColor!.withOpacity(0.5),
        elevation: 1,
        child: ListTile(
          onTap: widget.isInSelectionMode
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
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => ProfilePage(uid: user["uid"])))
                      .then((value) {
                    if (value == -1) {
                      setState(() {
                        returnEmpty = true;
                      });
                    } else {
                      setState(() {});
                    }
                    if (lastUserWasMadeAdmin == true) {
                      lastUserWasMadeAdmin = false;
                      setState(() {
                        user["accessLevel"] = "admin";
                      });
                    }
                  });
                },
          minLeadingWidth: 56,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: leading,
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
}
