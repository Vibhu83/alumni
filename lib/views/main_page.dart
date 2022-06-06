import 'package:alumni/ThemeData/theme_model.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/chat_room_page.dart';
import 'package:alumni/views/event_creation_page.dart';
import 'package:alumni/views/events_page.dart';
import 'package:alumni/views/forum_page.dart';
import 'package:alumni/views/home_page.dart';
import 'package:alumni/views/notification_page.dart';
import 'package:alumni/views/past_events_page.dart';
import 'package:alumni/views/people_page.dart';
import 'package:alumni/views/post_creation_page.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/add_notice_popup.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/login_popup.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/my_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  final int startingIndex;
  const MainPage({this.startingIndex = 0, Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedTab;

  final List<Widget> _tabsViews = <Widget>[
    HomePage(
      selectedTab: currentHomeTab == null ? 0 : currentHomeTab!,
    ),
    const EventsPage(),
    const PeoplePage(),
    const ForumPage(),
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
      icon: Icon(Icons.people_alt_outlined),
      activeIcon: Icon(Icons.people_alt_sharp),
      label: 'People',
    ),
    BottomNavigationBarItem(
        icon: Icon(Icons.forum_outlined),
        activeIcon: Icon(Icons.forum_sharp),
        label: 'Forum'),
    BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline_rounded),
        activeIcon: Icon(Icons.chat_sharp),
        label: 'Chats')
  ];

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

  Future<bool> _setUserLoginStatus() async {
    setScreenDimensions(context);
    User? currentUser = auth!.currentUser;

    chat!.firebaseUser = currentUser;
    if (currentUser != null) {
      if (currentUser.emailVerified) {
        userData["uid"] = currentUser.uid;
        await _saveUserData(userData["uid"]);
        return true;
      } else {
        userData["uid"] = null;
        if (emailPopUpShown != true) {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            emailPopUpShown = true;
            showDialog(
                context: context,
                builder: (context) {
                  return CustomAlertDialog(
                      height: screenHeight * 0.05,
                      actions: [
                        TextButton(
                            onPressed: () async {
                              await currentUser.sendEmailVerification();
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
        return false;
      }
    } else {
      userData["uid"] = null;
      return false;
    }
  }

  Future<bool> _saveUserData(String uid) async {
    return await firestore!.collection("users").doc(uid).get().then((value) {
      var temp = value.data();
      if (temp != null) {
        temp["uid"] = userData["uid"];
        userData = temp;
      }
      return true;
    });
  }

  late List<Widget?> _floatingActionButtons;

  late final Widget _signInPopUp;

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
      if (userData["accessLevel"] == "admin") {
        _floatingActionButtons[1] =
            //Events Floating Button
            FloatingActionButton(
          // backgroundColor: currentTheme!.floatingActionButtonColor,
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
      _floatingActionButtons[3] = FloatingActionButton(
        // backgroundColor: currentTheme!.floatingActionButtonColor,
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreatePostPage()));
        },
        child: const Icon(Icons.add),
      );
    }
  }

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _setUserLoginStatus(),
        builder: ((context, AsyncSnapshot<bool?> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            return _buildPage();
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        }));
  }

  List<Widget> _setAppBarIconsForSelectedTabs() {
    List<Widget> appBarIcons = [];
    switch (_selectedTab) {
      case 0:
        var addNoticeButton = buildAppBarIcon(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return const AddNoticePopUp();
                  });
            },
            icon: Icons.notification_add_sharp);
        if (userData["accessLevel"] == "admin") {
          appBarIcons.add(addNoticeButton);
        }
        break;
      // case 2:
      //   appBarIcons.add(buildAppBarIcon(
      //       onPressed: () {
      //         showModalBottomSheet(
      //             context: context,
      //             builder: (context) {
      //               return const UserFilterPopUp();
      //             });
      //       },
      //       icon: Icons.filter_alt));
      //   break;
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
    }
    return appBarIcons;
  }

  Consumer _buildPage() {
    _setFloatingActionButtons();

    Row pageFeatures = Row(
      children: _setAppBarIconsForSelectedTabs(),
    );
    return Consumer<ThemeModel>(
      builder: ((context, ThemeModel themeNotifier, child) => Scaffold(
          appBar: buildAppBar(
            appBarHeight: _selectedTab == 0 ? screenHeight * 0.117 : null,
            bottom: _selectedTab == 0
                ? PreferredSize(
                    preferredSize: Size.fromHeight(screenHeight * 0.1),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          border: Border(
                              top: BorderSide(
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .shadowColor!
                                      .withOpacity(0.3)))),
                      child: DefaultTabController(
                          initialIndex:
                              currentHomeTab == null ? 0 : currentHomeTab!,
                          length: 3,
                          child: TabBar(
                            labelColor:
                                Theme.of(context).appBarTheme.foregroundColor,
                            onTap: (value) {
                              currentHomeTab = value;
                              setState(() {
                                _tabsViews[0] = HomePage(
                                  selectedTab: value,
                                );
                              });
                            },
                            labelPadding: EdgeInsets.zero,
                            padding: EdgeInsets.zero,
                            tabs: const [
                              Tab(
                                text: "Trending Posts",
                              ),
                              Tab(
                                text: "Upcoming Events",
                              ),
                              Tab(
                                text: "Top Alums",
                              ),
                            ],
                          )),
                    ),
                  )
                : const PreferredSize(
                    preferredSize: Size.zero, child: SizedBox()),
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
              Builder(builder: (context) => pageFeatures),
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
          endDrawer: _buildProfileDrawer(context),
          body: NestedScrollView(
              body: _tabsViews.elementAt(_selectedTab),
              headerSliverBuilder: ((context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    stretchTriggerOffset: 1,
                    onStretchTrigger: () async {
                      setState(() {});
                    },
                    toolbarHeight: 1,
                    backgroundColor: Colors.transparent,
                    actions: const [SizedBox()],
                    expandedHeight: _selectedTab == 0 ? screenHeight * 0.19 : 0,
                    flexibleSpace: _selectedTab == 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: FlexibleSpaceBar(
                                background: Image.asset("assets/banner.jpg"),
                              ),
                            ),
                          )
                        : null,
                  )
                ];
              })),
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

  void logoutUser() async {
    noticesSeen = false;
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil(ModalRoute.withName(""));
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      userData.clear();
      return const MainPage();
    }));
  }

  Widget? _buildProfileDrawer(BuildContext context) {
    if (userData["uid"] == null) {
      return null;
    }
    double topPad = screenHeight * 0.085;
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
                      userData["profilePic"] != null
                          ? CircleAvatar(
                              radius: 128,
                              backgroundImage:
                                  NetworkImage(userData["profilePic"]),
                            )
                          : Initicon(
                              size: 256,
                              text: userData["name"],
                            ),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: _buildDrawListTile("My Profile", () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: ((context) =>
                                    ProfilePage(uid: userData["uid"]))));
                          })),
                      _buildDrawListTile("Notifications", () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: ((context) =>
                                NotificationPage(uid: userData["uid"]))));
                      }),
                      _buildDrawListTile("Inbox", () {
                        setState(() {
                          _selectedTab = 4;
                        });
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
                    title: const Text("Settings"),
                    trailing: IconButton(
                      icon: const Icon(Icons.logout_rounded),
                      onPressed: () {
                        logoutUser();
                      },
                    ),
                    onTap: () {},
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
