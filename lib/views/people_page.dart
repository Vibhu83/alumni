import 'package:alumni/globals.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/user_filter_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late int _typeFilterValue;
  late bool _isAscendingOrder;
  late String? _courseFilterValue;
  late int? _admissionYearFilterValue;
  late String? _nationalityFilterValue;
  late String? _designationFilterValue;
  late String? _organisationFilterValue;

  late List<Map<String, dynamic>> _usersData;

  Widget? body;

  @override
  void initState() {
    _usersData = [];
    _courseFilterValue = null;
    _admissionYearFilterValue = null;
    _nationalityFilterValue = null;
    _designationFilterValue = null;
    _organisationFilterValue = null;
    _isAscendingOrder = true;
    _typeFilterValue = 7;
    _showAdmins = true;
    _showAlumni = true;
    _showStudents = true;
    if (widget.isInSelectionMode) {
      _typeFilterValue = 6;
      _showAdmins = true;
      _showAlumni = true;
      _showStudents = false;
    }
    super.initState();
  }

  Future<bool> _getUserData() async {
    _usersData = [];
    Query<Map<String, dynamic>>? _query;

    switch (_typeFilterValue) {
      case 0:
        _usersData = [];
        return true;
      case 1:
        _query = firestore!
            .collection("users")
            .where("userType", isEqualTo: "student");
        break;

      case 2:
        _query = firestore!
            .collection("users")
            .where("userType", isEqualTo: "alumni");
        break;

      case 3:
        _query = firestore!
            .collection("users")
            .where("userType", whereIn: ["student", "alumni"]);
        break;

      case 4:
        _query = firestore!
            .collection("users")
            .where("userType", isEqualTo: "admin");
        break;

      case 5:
        _query = firestore!
            .collection("users")
            .where("userType", whereIn: ["student", "admin"]);
        break;

      case 6:
        _query = firestore!
            .collection("users")
            .where("userType", whereIn: ["alumni", "admin"]);
        break;
      default:
        _query = firestore!.collection("users");
        break;
    }
    if (_admissionYearFilterValue != null) {
      _query =
          _query.where("admissionYear", isEqualTo: _admissionYearFilterValue);
    }
    if (_nationalityFilterValue != null) {
      _query = _query.where("nationality", isEqualTo: _nationalityFilterValue);
    }
    if (_courseFilterValue != null) {
      _query = _query.where("course", isEqualTo: _courseFilterValue);
    }
    if (_designationFilterValue != null) {
      _query = _query.where("currentDesignation",
          isEqualTo: _designationFilterValue);
    }
    if (_organisationFilterValue != null) {
      _query =
          _query.where("currentOrgName", isEqualTo: _organisationFilterValue);
    }
    _usersData = await _query.get().then((value) {
      List<Map<String, dynamic>> temp = [];
      for (var element in value.docs) {
        if (element.data()["uid"] != null) {
          temp.add(element.data());
        }
      }
      return temp;
    });
    if (_usersData.length > 1) {
      _usersData.sort((a, b) {
        String nameA = a["name"];
        String nameB = b["name"];
        if (_isAscendingOrder) {
          return nameA.compareTo(nameB);
        } else {
          return nameB.compareTo(nameA);
        }
      });
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
        headerSliverBuilder: ((context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
                automaticallyImplyLeading: false,
                floating: true,
                toolbarHeight: 0,
                expandedHeight: screenHeight * 0.075,
                backgroundColor: Theme.of(context).canvasColor,
                actions: const [SizedBox()],
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  background: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            isScrollControlled: true,
                            elevation: 2,
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return Wrap(children: [
                                UserFilterPopUp(
                                    showAdmins: _showAdmins,
                                    showAlumni: _showAlumni,
                                    showStudents: _showStudents,
                                    typeFilterValue: _typeFilterValue,
                                    isAscendingOrder: _isAscendingOrder,
                                    courseFilterValue: _courseFilterValue,
                                    admissionYearFilterValue:
                                        _admissionYearFilterValue,
                                    nationalityFilterValue:
                                        _nationalityFilterValue,
                                    designationFilterValue:
                                        _designationFilterValue,
                                    organisationFilterValue:
                                        _organisationFilterValue),
                              ]);
                            }).then((value) async {
                          if (value != null) {
                            setState(() {
                              _showAdmins = value["showAdmins"];
                              _showAlumni = value["showAlumni"];
                              _showStudents = value["showStudents"];
                              _typeFilterValue = value["typeFilterValue"];
                              _isAscendingOrder = value["isAscendingOrder"];
                              _designationFilterValue =
                                  value["designationFilterValue"];
                              _nationalityFilterValue =
                                  value["nationalityFilterValue"];
                              _organisationFilterValue =
                                  value["organisationFilterValue"];
                              _courseFilterValue = value["courseFilterValue"];
                              _admissionYearFilterValue =
                                  value["admissionYearFilterValue"];
                            });
                          }
                        });
                      },
                      child: _buildFilterBar()),
                )),
          ];
        }),
        body: FutureBuilder(
            future: _getUserData(),
            builder: ((context, AsyncSnapshot<bool> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                return ListView.builder(
                    itemCount: _usersData.length,
                    itemBuilder: ((context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 12),
                        child: widget.isInSelectionMode == false
                            ? UserCard(
                                user: _usersData[index],
                                isInSelectionMode: widget.isInSelectionMode,
                              )
                            : _buildUserCard(
                                _usersData[index], widget.isInSelectionMode),
                      );
                    }));
              } else if (snapshot.hasError) {
                children = buildFutureError(snapshot);
              } else {
                children = buildFutureLoading(snapshot);
              }
              return buildFuture(children: children);
            })));
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
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(
                Icons.filter_alt,
                color: Colors.orange,
              ),
              SizedBox(
                width: screenWidth * 0.0125,
              ),
              const Text("Filter",
                  style: TextStyle(fontSize: 16, color: Colors.orange)),
            ],
          ),
        ),
      ),

      // Row(
      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //   children: [
      //     ElevatedButton(
      //       onPressed: () {
      //         bool nextValue = true;
      //         int changeInChoiceValue = 0;
      //         if (_showStudents == true) {
      //           nextValue = false;
      //           changeInChoiceValue = -1;
      //         } else {
      //           nextValue = true;
      //           changeInChoiceValue = 1;
      //         }
      //         setState(() {
      //           _showStudents = nextValue;
      //           _typeFilterValue += changeInChoiceValue;
      //         });
      //       },
      //       child: Text(
      //         "Students",
      //         style: TextStyle(
      //             fontSize: screenWidth * 0.025,
      //             color: Theme.of(context).appBarTheme.foregroundColor),
      //       ),
      //       style: ElevatedButton.styleFrom(
      //           elevation: 0,
      //           padding: EdgeInsets.zero,
      //           onPrimary: Colors.transparent,
      //           primary: _showStudents == true
      //               ? Colors.blueAccent.withOpacity(0.3)
      //               : Colors.transparent,
      //           shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(18)),
      //           side: BorderSide(
      //               color: Theme.of(context)
      //                   .appBarTheme
      //                   .shadowColor!
      //                   .withOpacity(0.2)),
      //           fixedSize: Size(screenWidth * 0.15, screenHeight * 0.01)),
      //     ),
      //     ElevatedButton(
      //       onPressed: () {
      //         bool nextValue = true;
      //         int changeInChoiceValue = 0;
      //         if (_showAlumni == true) {
      //           nextValue = false;
      //           changeInChoiceValue = -2;
      //         } else {
      //           nextValue = true;
      //           changeInChoiceValue = 2;
      //         }
      //         setState(() {
      //           _showAlumni = nextValue;
      //           _typeFilterValue += changeInChoiceValue;
      //         });
      //       },
      //       child: Text(
      //         "Alumni",
      //         style: TextStyle(
      //             fontSize: screenWidth * 0.025,
      //             color: Theme.of(context).appBarTheme.foregroundColor),
      //       ),
      //       style: ElevatedButton.styleFrom(
      //           elevation: 0,
      //           padding: EdgeInsets.zero,
      //           onPrimary: Colors.transparent,
      //           primary: _showAlumni == true
      //               ? Colors.blueAccent.withOpacity(0.3)
      //               : Colors.transparent,
      //           shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(18)),
      //           side: BorderSide(
      //               color: Theme.of(context)
      //                   .appBarTheme
      //                   .shadowColor!
      //                   .withOpacity(0.2)),
      //           fixedSize: Size(screenWidth * 0.15, screenHeight * 0.01)),
      //     ),
      //     ElevatedButton(
      //       onPressed: () {
      //         int changeInChoiceValue = 0;

      //         bool nextValue = true;
      //         if (_showAdmins == true) {
      //           nextValue = false;
      //           changeInChoiceValue = -4;
      //         } else {
      //           nextValue = true;
      //           changeInChoiceValue = 4;
      //         }
      //         setState(() {
      //           _showAdmins = nextValue;
      //           _typeFilterValue += changeInChoiceValue;
      //         });
      //       },
      //       child: Text(
      //         "Admins",
      //         style: TextStyle(
      //             fontSize: screenWidth * 0.027,
      //             color: Theme.of(context).appBarTheme.foregroundColor),
      //       ),
      //       style: ElevatedButton.styleFrom(
      //           elevation: 0,
      //           padding: EdgeInsets.zero,
      //           onPrimary: Colors.transparent,
      //           primary: _showAdmins == true
      //               ? Colors.blueAccent.withOpacity(0.3)
      //               : Colors.transparent,
      //           shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(18)),
      //           side: BorderSide(
      //               color: Theme.of(context)
      //                   .appBarTheme
      //                   .shadowColor!
      //                   .withOpacity(0.2)),
      //           fixedSize: Size(screenWidth * 0.15, screenHeight * 0.01)),
      //     ),
      //     RotatedBox(
      //       quarterTurns: 1,
      //       child: IconButton(
      //           color: _isAscendingOrder == false
      //               ? Theme.of(context).appBarTheme.foregroundColor
      //               : Colors.grey,
      //           splashRadius: 1,
      //           onPressed: (() {
      //             bool nextValue = true;
      //             if (_isAscendingOrder) {
      //               nextValue = false;
      //             }
      //             setState(() {
      //               _isAscendingOrder = nextValue;
      //             });
      //           }),
      //           icon: const Icon(Icons.compare_arrows_outlined)),
      //     ),
      //   ],
      // ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isInSelectionMode) {
    String subTitle = user["userType"];
    subTitle = subTitle.substring(0, 1).toUpperCase() + subTitle.substring(1);
    String? currentDesignation = user["currentDesignation"];
    currentDesignation ??= "";
    String? currentOrg = user["currentOrgName"];
    currentOrg ??= "";
    if (currentDesignation != "" && currentOrg != "") {
      subTitle = currentDesignation + " at " + currentOrg;
    }
    Widget leading;
    if (user["profilePic"] == null) {
      leading = CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 56,
        child: Initicon(
          size: 56,
          text: user["name"],
        ),
      );
    } else {
      leading = CircleAvatar(
          radius: 56, backgroundImage: NetworkImage(user["profilePic"]));
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
      String subTitle = user["userType"];
      subTitle = subTitle.substring(0, 1).toUpperCase() + subTitle.substring(1);
      String? currentDesignation = user["currentDesignation"];
      currentDesignation ??= "";
      String? currentOrg = user["currentOrgName"];
      currentOrg ??= "";
      if (currentDesignation != "" && currentOrg != "") {
        subTitle = currentDesignation + " at " + currentOrg;
      }
      Widget leading;
      if (user["profilePic"] == null) {
        leading = CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 56,
          child: Initicon(
            size: 56,
            text: user["name"],
          ),
        );
      } else {
        leading = CircleAvatar(
            radius: 56, backgroundImage: NetworkImage(user["profilePic"]));
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
                        user["userType"] = "admin";
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
