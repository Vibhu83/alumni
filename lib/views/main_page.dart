import 'dart:io';

import 'package:alumni/ThemeData/theme_model.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/bookmark_page.dart';
import 'package:alumni/views/chat_room_page.dart';
import 'package:alumni/views/event_creation_page.dart';
import 'package:alumni/views/events_page.dart';
import 'package:alumni/views/posts_by_id.dart';
import 'package:alumni/views/unapproved_posts_page.dart';
import 'package:alumni/views/posts_page.dart';
import 'package:alumni/views/home_page.dart';
import 'package:alumni/views/recommendation_page.dart';
import 'package:alumni/views/past_events_page.dart';
import 'package:alumni/views/people_page.dart';
import 'package:alumni/views/post_creation_page.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/views/search_alum_page.dart';
import 'package:alumni/widgets/add_notice_popup.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/login_popup.dart';
import 'package:alumni/widgets/custom_alert_dialog.dart';
import 'package:alumni/widgets/notice_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  final int startingIndex;
  const MainPage({this.startingIndex = 0, Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Widget> _tabsViews = <Widget>[
    const HomePage(),
    const EventsPage(),
    const PostsPage(),
    const PeoplePage(),
    const ChatRooms()
  ];

  final List<BottomNavigationBarItem> _tabs = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home_sharp),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.event_outlined),
      activeIcon: Icon(Icons.event_sharp),
      label: 'Events',
    ),
    BottomNavigationBarItem(
        icon: Icon(Icons.forum_outlined),
        activeIcon: Icon(Icons.forum_sharp),
        label: 'Forum'),
    BottomNavigationBarItem(
      icon: Icon(Icons.people_alt_outlined),
      activeIcon: Icon(Icons.people_alt_sharp),
      label: 'People',
    ),
    BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline_rounded),
        activeIcon: Icon(Icons.chat_sharp),
        label: 'Chats')
  ];

  late List<Widget> _appBarActions;

  late int _selectedTab;
  late List<Widget?> _floatingActionButtons;
  late final Widget _signInPopUp;

  void addTempData() async {
    for (int i = 1; i <= 25; i++) {
      String title = "Post " + i.toString();
      await firestore!.collection("posts").add({}).then((value) async {
        String eventID = value.id;

        await firestore!.collection('posts').doc(eventID).set({
          "authorName": userData["name"],
          "postID": eventID,
          "postAuthorID": userData["uid"],
          "postTitle": title,
          "postVotes": 0,
          "postBody": "",
          "postedOn": Timestamp.fromDate(DateTime.now()),
          "rating": getRating(0, DateTime.now()),
          "postLink": "",
          "images": [],
        }, SetOptions(merge: true));
      });
    }
  }

  @override
  void initState() {
    _appBarActions = [
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox()
    ];
    _verifyEmail();
    _setFloatingActionButtons();
    _setAppBarIcons();
    _selectedTab = 0;
    _signInPopUp = const LoginRegisterPopUp();
    _selectedTab = widget.startingIndex;
    super.initState();
  }

  @override
  void dispose() {
    _tabsViews.clear();
    _floatingActionButtons.clear();
    super.dispose();
  }

  void _setAppBarIcons() {
    for (int i = 0; i < 5; i++) {
      _appBarActions[i] = Row(
        children: _setAppBarIconsForTab(i),
      );
    }
  }

  void _verifyEmail() {
    if (auth!.currentUser != null &&
        auth!.currentUser!.emailVerified != true &&
        emailPopUpShown != true) {
      userData.clear();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        emailPopUpShown = true;
        showDialog(
            context: context,
            builder: (context) {
              return CustomAlertDialog(
                  height: screenHeight * 0.05,
                  actions: [
                    TextButton(
                        onPressed: () async {
                          await auth!.currentUser!.sendEmailVerification();
                          await auth!.signOut();
                          Navigator.of(context).pop();
                        },
                        child: const Text("Send email verification"))
                  ],
                  title: const Text("Email not verified"),
                  content: const Text(
                      "To access all features, please verify your email and login again"));
            });
      });
    }
  }

  void _setFloatingActionButtons() {
    _floatingActionButtons = [
      //Home Floating Button
      null,
      //Events Floating Button
      null,
      //People Floating Button
      null,
      //Forum Floating Button
      null,
      //Chat Floating Button
      null
    ];
    if (userData["uid"] != null) {
      if (userData["hasAdminAccess"] == true) {
        _floatingActionButtons[1] =
            //Events Floating Button
            FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const CreateEvent(
                      eventUpdationFlag: false,
                    )));
          },
          child: const Icon(Icons.add),
        );
      }
      //Forum Floating Button
      _floatingActionButtons[2] = FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreatePostPage()));
        },
        child: const Icon(Icons.add),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == 4 && userData["uid"] == null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return _signInPopUp;
          });
    } else {
      setState(() {
        _selectedTab = index;
      });
    }
  }

  List<Widget> _setAppBarIconsForTab(int tabIndex) {
    List<Widget> appBarIcons = [];
    switch (tabIndex) {
      case 0:
        var addNoticeButton = buildAppBarIcon(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const AddNoticePopUp();
                  });
            },
            icon: Icons.add);
        var seeNoticesButton = buildAppBarIcon(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const Notices(
                      showAllFlag: true,
                    );
                  });
            },
            icon: Icons.mail);
        if (userData["hasAdminAccess"] == true) {
          appBarIcons.add(addNoticeButton);
        }
        appBarIcons.add(seeNoticesButton);
        break;
      case 1:
        var pastEventButton = buildAppBarIcon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
                return const PastEventsPage();
              })));
            },
            icon: Icons.history);

        appBarIcons.add(pastEventButton);

        break;
      // case 2:
      //   var searchForumButton =
      //       buildAppBarIcon(onPressed: () {}, icon: Icons.search_rounded);
      //   appBarIcons.add(searchForumButton);
      //   break;
      case 3:
        //   appBarIcons.add(buildAppBarIcon(
        //       onPressed: () {
        //         showModalBottomSheet(
        //             isScrollControlled: true,
        //             elevation: 2,
        //             backgroundColor: Colors.transparent,
        //             context: context,
        //             builder: (context) {
        //               return Wrap(children: const [
        //                 Padding(
        //                   padding:
        //                       EdgeInsets.only(left: 8.0, right: 8, bottom: 16),
        //                   child: UserFilterPopUp(),
        //                 ),
        //               ]);
        //             }).then((value) {
        //           print("value changed");
        //         });
        //       },
        //       icon: Icons.filter_alt));
        appBarIcons.add(buildAppBarIcon(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const SearchAlumsPage();
              }));
            },
            icon: Icons.search));
        if (userData["hasAdminAccess"] == true) {
          appBarIcons.add(buildAppBarIcon(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return CustomAlertDialog(
                      height: screenHeight * 0.25,
                      title: null,
                      actions: null,
                      content: Center(
                        child: FutureBuilder(
                            future: _downloadUsersDataSheet(),
                            builder: ((context, AsyncSnapshot<Excel> snapshot) {
                              List<Widget> children = [];
                              if (snapshot.hasData) {
                                children = <Widget>[
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: screenWidth * 0.15,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 16),
                                    child: Text(
                                      "File Ready!",
                                      style: TextStyle(color: Colors.green),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.05,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        if (snapshot.data != null) {
                                          saveExcelFile(snapshot.data!);
                                        }
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor: Colors.green),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.download),
                                          Text("Download")
                                        ],
                                      ))
                                ];
                              } else if (snapshot.hasError) {
                                children = buildFutureError(snapshot);
                              } else {
                                children = buildFutureLoading(snapshot);
                              }
                              return buildFuture(children: children);
                            })),
                      ),
                    );
                  });
              _downloadUsersDataSheet();
            },
            icon: Icons.download,
          ));
        }

        break;
    }
    return appBarIcons;
  }

  Future<Excel> _downloadUsersDataSheet() async {
    List<List<String>> _usersData = [
      [
        "UID",
        "Roll No.",
        "Name",
        "Email",
        "Year of Admission",
        "Course",
        "User Type",
        "Is An Alumni",
        "Mother's Name",
        "Father's Name",
        "Date of Birth",
        "Permanent Address",
        "Year of Passing",
        "Nationality",
        "Is NRI",
        "Achievements",
        "Current Designation",
        "Current Organisation",
        "In Current Organisation Since",
        "Residence Contact No",
        "Current Office Number",
        "Mobile Contact Number",
        "Previous Organisation Name",
        "Previous Designation",
        "Were In Previous Organisation Since",
        "Previous Office Contact Number",
        "Spouse Name",
        "Spouse Organisation Name",
        "Spouse Designation",
        "Spouse In Organisation Since",
        "Spouse Office Contact Number",
        "Spouse Mobile Contace Number",
      ]
    ];
    await firestore!.collection("users").get().then((value) {
      for (var element in value.docs) {
        Map<String, dynamic> user = element.data();
        if (element.data()["uid"] == null) {
          continue;
        }
        _usersData.add([
          _formatToString(user["uid"]),
          _formatToString(user["rollNo"]),
          _formatToString(user["name"]),
          _formatToString(user["email"]),
          _formatToString(user["admissionYear"]),
          _formatToString(user["course"]),
          _formatToString(user["userType"]),
          _formatToString(user["isAnAlumni"]),
          _formatToString(user["motherName"]),
          _formatToString(user["fatherName"]),
          _formatTimestampToString(user["dateOfBirth"]),
          _formatToString(user["permanentAddress"]),
          _formatToString(user["passingYear"]),
          _formatToString(user["nationality"]),
          _formatToString(user["isNRI"]),
          _formatToString(user["achievements"]),
          _formatToString(user["currentDesignation"]),
          _formatToString(user["currentOrgName"]),
          _formatTimestampToString(user["inCurrentOrgSince"]),
          _formatToString(user["residenceContactNo"]),
          _formatToString(user["currentOfficeContactNo"]),
          _formatToString(user["mobileContactNo"]),
          _formatToString(user["previousOrgName"]),
          _formatToString(user["previousDesignation"]),
          _formatTimestampToString(user["wereInPreviousOrgSince"]),
          _formatToString(user["previousOrgOfficeContactNo"]),
          _formatToString(user["spouseName"]),
          _formatToString(user["spouseOrgName"]),
          _formatToString(user["spouseDesignation"]),
          _formatTimestampToString(user["spouseWorkingInOrgSince"]),
          _formatToString(user["spouseOfficeContactNo"]),
          _formatToString(user["spouseMobileContactNo"]),
        ]);
      }
    });
    final Excel excelDoc = Excel.createExcel();
    final Sheet sheet = excelDoc[excelDoc.getDefaultSheet()!];
    for (int x = 0; x < _usersData.length; x++) {
      for (int y = 0; y < _usersData[x].length; y++) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: y, rowIndex: x))
            .value = _usersData[x][y];
      }
    }
    excelDoc.save(fileName: "userList");
    return excelDoc;
  }

  String _formatToString(var value) {
    if (value == null || value.toString() == "") {
      return "-";
    } else {
      return value.toString();
    }
  }

  String _formatTimestampToString(var value) {
    if (value == null) {
      return "-";
    } else {
      List<String> temp = value.toDate().toString().split(" ")[0].split("-");
      return temp[2] + "-" + temp[1] + "-" + temp[0];
    }
  }

  Future<void> saveExcelFile(Excel excel) async {
    try {
      await Permission.storage.request();

      await Permission.accessMediaLocation.request();

      await Permission.manageExternalStorage.request();

      List temp = Timestamp.now().toDate().toString().split(".")[0].split(" ");
      String name = "List-" + temp[0] + temp[1] + ".xlsx";
      temp = name.split(":");
      name = temp[0] + temp[1];
      temp = name.split("-");
      name = temp[0] + temp[3] + ".xlsx";

      String path = "/storage/emulated/0/Download";

      FilePicker.platform.clearTemporaryFiles();
      FilePicker.platform.getDirectoryPath().then((value) async {
        if (value != null) {
          try {
            File(value + "/" + name)
              ..createSync(recursive: false)
              ..writeAsBytesSync(
                excel.encode()!,
              );
            Navigator.of(context).pop();
          } on FileSystemException catch (e) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Theme.of(context).cardColor,
              content: Text(
                "Some error occurred while saving file\nFile saved to Internal Storage's Downloads folder\n(\"/storage/emulated/0/Download/\")",
                style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor),
              ),
            ));

            File(path + "/" + name)
              ..createSync(recursive: false)
              ..writeAsBytesSync(
                excel.encode()!,
              );
          }
        }
      });
    } on Exception catch (e) {
      showDialog(
          context: context,
          builder: (context) {
            return CustomAlertDialog(
                height: screenHeight * 0.1,
                actions: null,
                title: null,
                content: const Center(
                  child: Text(
                    "Some error occured",
                    style: TextStyle(color: Colors.red),
                  ),
                ));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    setScreenDimensions(context);

    return Consumer<ThemeModel>(
      builder: ((context, ThemeModel themeNotifier, child) => Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: buildAppBar(
            title: Container(
              width: screenWidth * 0.22,
              height: screenHeight * 0.043,
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: AssetImage("assets/logo.png"),
                )),
              ),
            ),
            leading: buildAppBarIcon(
                onPressed: () {
                  themeNotifier.isDark
                      ? themeNotifier.isDark = false
                      : themeNotifier.isDark = true;
                },
                icon: themeNotifier.isDark
                    ? Icons.nightlight_round_outlined
                    : Icons.wb_sunny_rounded),
            actions: <Widget>[
              Builder(builder: (context) => _appBarActions[_selectedTab]),
              Builder(
                builder: (context) {
                  return buildAppBarIcon(
                      onPressed: () {
                        if (userData["uid"] != null) {
                          Scaffold.of(context).openEndDrawer();
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return _signInPopUp;
                              });
                        }
                      },
                      icon: Icons.person);
                },
              ),
            ],
          ),
          floatingActionButton: _floatingActionButtons[_selectedTab],
          endDrawer: Builder(
            builder: (context) {
              return _buildProfileDrawer(context);
            },
          ),
          body: _tabsViews.elementAt(_selectedTab),
          bottomNavigationBar: _buildBottomNavBar())),
    );
  }

  Container _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Theme.of(context).appBarTheme.shadowColor!.withOpacity(0.3),
          blurStyle: BlurStyle.normal,
          spreadRadius: 0.1,
          blurRadius: 0.5,
          offset: const Offset(0, -1),
        ),
      ], color: Theme.of(context).appBarTheme.backgroundColor),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: BottomNavigationBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1,
          items: _tabs,
          currentIndex: _selectedTab,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedItemColor:
              Theme.of(context).appBarTheme.foregroundColor!.withOpacity(0.7),
        ),
      ),
    );
  }

  void _logoutUser() async {
    await auth!.signOut();
    await setUserLoginStatus(data: {});
    Navigator.of(context).popUntil(ModalRoute.withName(""));
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const MainPage();
    }));
  }

  Widget _buildProfileDrawer(BuildContext context) {
    if (userData["uid"] == null) {
      return const SizedBox();
    }
    double topPad = screenHeight * 0.093;
    double bottomPad = screenHeight * 0.01;
    return Container(
      padding: EdgeInsets.fromLTRB(0, topPad, 0, bottomPad),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
        child: Drawer(
          backgroundColor: Theme.of(context).cardColor,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 16, bottom: 4),
                    child: Column(children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: ((context) =>
                                  ProfilePage(uid: userData["uid"]))));
                        },
                        child: userData["profilePic"] != null
                            ? CircleAvatar(
                                radius: 128,
                                backgroundImage:
                                    NetworkImage(userData["profilePic"]),
                              )
                            : Initicon(
                                size: 256,
                                text: userData["name"],
                              ),
                      ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: _buildDrawListTile("My Profile", () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: ((context) =>
                                    ProfilePage(uid: userData["uid"]))));
                          })),
                      _buildDrawListTile("My Posts", () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return PostsByIDPage(uid: userData["uid"]);
                        }));
                      }),
                      userData["hasAdminAccess"] == true
                          ? _buildDrawListTile("Unapproved Posts", () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: ((context) =>
                                      const UnapprovedPostsPage())));
                            })
                          : _buildDrawListTile("My Unapproved Posts", () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: ((context) =>
                                      const UnapprovedPostsPage())));
                            }),
                      _buildDrawListTile("Recommendations", () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: ((context) =>
                                RecommendationPage(uid: userData["uid"]))));
                      }),
                      _buildDrawListTile("Bookmarks", () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const BookmarkPage();
                        }));
                      }),
                      _buildDrawListTile("Inbox", () {
                        setState(() {
                          _selectedTab = 4;
                        });
                        Scaffold.of(context).closeEndDrawer();
                      }),
                    ]),
                  ),
                ),
              ),
              Container(
                height: screenHeight * .0831,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .appBarTheme
                            .shadowColor!
                            .withOpacity(0.3),
                        blurStyle: BlurStyle.normal,
                        spreadRadius: 0.1,
                        blurRadius: 0.5,
                        offset: const Offset(0, -0.25),
                      ),
                    ],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4.0))),
                child: Center(
                  child: ListTile(
                    iconColor: Theme.of(context).appBarTheme.foregroundColor,
                    textColor: Theme.of(context).appBarTheme.foregroundColor,
                    leading: const Icon(Icons.settings),
                    title: const Text("Logout"),
                    trailing: const Icon(Icons.logout_rounded),
                    onTap: () {
                      _logoutUser();
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawListTile(String title, Function onTap) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  width: 1,
                  color: Theme.of(context)
                      .appBarTheme
                      .shadowColor!
                      .withOpacity(0.4)))),
      child: ListTile(
        style: ListTileStyle.drawer,
        title: Text(title),
        onTap: onTap as void Function(),
      ),
    );
  }
}
