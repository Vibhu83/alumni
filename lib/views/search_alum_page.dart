import 'dart:async';
import 'package:alumni/globals.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';

class SearchAlumsPage extends StatefulWidget {
  final bool isInSelectionMode;
  const SearchAlumsPage({this.isInSelectionMode = false, Key? key})
      : super(key: key);

  @override
  State<SearchAlumsPage> createState() => _SearchAlumsPageState();
}

class _SearchAlumsPageState extends State<SearchAlumsPage> {
  late String? _searchName;
  late List<Map<String, dynamic>> _usersData;
  late TextEditingController _searchController;
  @override
  void initState() {
    _searchController = TextEditingController();
    _usersData = [];
    _searchName = null;
    super.initState();
  }

  String _capitaliseFirstLetters(String name) {
    List<String> temp = name.split(" ");
    for (int i = 0; i < temp.length; i++) {
      String str = temp[i];
      temp[i] = str[0].toUpperCase() + str.substring(1);
    }
    String newName = "";
    int counter = 0;
    for (String str in temp) {
      newName += str;
      if (counter != temp.length - 1) {
        newName += " ";
      }
      counter++;
    }
    return newName;
  }

  String _removeWhiteSpaces(String name) {
    List<String> temp = name.split(" ");
    String newName = "";
    for (String str in temp) {
      newName += str;
    }
    return newName;
  }

  Future<bool> _getUsersData() async {
    _usersData = [];
    if (_searchName == null) {
      return true;
    }
    List<String> _namesTries = [
      _searchName!,
      _searchName!.toLowerCase(),
      _searchName!.toUpperCase(),
      _capitaliseFirstLetters(_searchName!.toLowerCase()),
      _searchName!.trim(),
      _removeWhiteSpaces(_searchName!),
      _removeWhiteSpaces(_searchName!.toUpperCase()),
      _removeWhiteSpaces(_searchName!.toLowerCase())
    ];

    await firestore!
        .collection("users")
        .where("name", whereIn: _namesTries)
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (element.data()["uid"] != null) {
          _usersData.add(element.data());
        }
      }
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                  toolbarHeight: screenHeight * 0.1,
                  title: InputField(
                    onChanged: (value) {
                      if (_searchName != null) {
                        setState(() {
                          _searchName = null;
                        });
                      }
                    },
                    controller: _searchController,
                    onSubmitted: (p0) {
                      setState(() {
                        _usersData = [];
                        _searchName = p0;
                      });
                    },
                    keyboardType: TextInputType.name,
                    heightPadding: 0,
                    horizontalPadding: 20,
                    labelText: "Search By Name",
                    circularBorderRadius: 32,
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.0225,
                          bottom: screenHeight * 0.0225,
                          right: 12),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(64)),
                              padding: EdgeInsets.zero),
                          onPressed: () {
                            setState(() {
                              _usersData = [];
                              _searchName = _searchController.text;
                            });
                          },
                          child: const Icon(Icons.search)),
                    )
                  ],
                  floating: true,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  leading: null,
                  backgroundColor: Theme.of(context).canvasColor,
                  shadowColor: Theme.of(context).canvasColor),
            ];
          },
          body: FutureBuilder(
              future: _getUsersData(),
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
              }))),
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
