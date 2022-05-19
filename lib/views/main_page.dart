import 'dart:io';

import 'package:alumni/ThemeData/theme_model.dart';
import 'package:alumni/firebase_options.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/event_creation_page.dart';
import 'package:alumni/views/events_page.dart';
import 'package:alumni/views/forum_page.dart';
import 'package:alumni/views/home_page.dart';
import 'package:alumni/views/notification_page.dart';
import 'package:alumni/views/people_page.dart';
import 'package:alumni/views/post_creation_page.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/add_notice_popup.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/login_popup.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  final int startingIndex;
  const MainPage({this.startingIndex = 0, Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  Map<String, dynamic>? newNotice;

  late final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const EventsPage(),
    const PeoplePage(),
    const ForumPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late List<Widget?> _floatingActionButtons;

  late final Widget loginModalSheet;

  void _setFloatingActionButtons() {
    _floatingActionButtons = [
      //Home Floating Button
      null,
      //Events Floating Button
      null,
      //Chat Floating Button
      null,
      //Forum Floating Button
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

  Future<bool?> initialiseApp() async {
    bool? returnVal = false;
    returnVal = await initialiseFireBaseApp().then((app) async {
      auth = FirebaseAuth.instance;
      firestore = FirebaseFirestore.instance;
      _setUserLoginStatus();
      await _saveUserData();
      _setFloatingActionButtons();
      return true;
    });
    return returnVal;
  }

  Future<FirebaseApp> initialiseFireBaseApp() async {
    if (Firebase.apps.isEmpty) {
      var temp = await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform)
          .then((value) {
        return value;
      });
      return temp;
    } else {
      return Firebase.apps[Firebase.apps.length - 1];
    }
  }

  Future<bool> _saveUserData() async {
    return await firestore!
        .collection("users")
        .doc(userData["uid"])
        .get()
        .then((value) {
      var temp = value.data();
      if (temp != null) {
        temp["uid"] = userData["uid"];
        userData = temp;
      }
      return true;
    });
  }

  void _setUserLoginStatus() {
    User? currentUser = auth!.currentUser;
    if (currentUser != null) {
      userData["uid"] = currentUser.uid;
    } else {
      userData["uid"] = null;
    }
  }

  @override
  void initState() {
    loginModalSheet = const LoginRegisterPopUp();
    _selectedIndex = widget.startingIndex;
    super.initState();
  }

  @override
  void dispose() {
    _widgetOptions.clear();
    _floatingActionButtons.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setScreenDimensions(context);
    return FutureBuilder(
        future: initialiseApp(),
        builder: ((context, AsyncSnapshot<bool?> snapshot) {
          List<Widget> children;
          if (snapshot.data == true) {
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

  Consumer _buildPage() {
    List<Widget> pageFeatureWidgets = [];
    switch (_selectedIndex) {
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
          pageFeatureWidgets.add(addNoticeButton);
        }
        break;
      case 1:
        var pastEventButton = buildAppBarIcon(
            onPressed: () {
              print("getting past events");
            },
            icon: Icons.history);

        pageFeatureWidgets.add(pastEventButton);
        break;
      case 2:
        var searchForumButton = buildAppBarIcon(
            onPressed: () {
              print("Searching forum");
            },
            icon: Icons.search_rounded);
        pageFeatureWidgets.add(searchForumButton);
        break;
    }
    Row pageFeatures = Row(
      children: pageFeatureWidgets,
    );
    return Consumer<ThemeModel>(
      builder: ((context, ThemeModel themeNotifier, child) => Scaffold(
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
                                return loginModalSheet;
                              });
                        }
                      },
                      icon: Icons.person);
                },
              ),
            ],
          ),
          // backgroundColor: currentTheme!.mainScaffoldColor,
          floatingActionButton: _floatingActionButtons[_selectedIndex],
          endDrawer:
              userData["uid"] == null ? null : _buildProfileDrawer(context),
          body: _widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: _buildBottomNavBar())),
    );
  }

  Container _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(boxShadow: [
        // so here your custom shadow goes:
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
          //elevation: 0.0,
          items: _buildNavBarTabs(),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedItemColor:
              Theme.of(context).appBarTheme.foregroundColor!.withOpacity(0.7),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavBarTabs() {
    return const <BottomNavigationBarItem>[
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
          label: 'Forum')
    ];
  }

  Container _buildMenuDrawer(BuildContext context) {
    //Make some logic to change the trailing icon var depending on the themeMode
    double topPad = screenHeight * 0.082;
    double bottomPad = screenHeight * 0.01;
    Icon trailingIcon = const Icon(Icons.nightlight);
    return Container(
      padding: EdgeInsets.fromLTRB(0, topPad, 0, bottomPad),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
        child: Drawer(
          // backgroundColor: const Color(drawerColor),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(children: [
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: _buildDrawListTile("Alumni List", () {})),
                    _buildDrawListTile("Your Calendar", () {}),
                    _buildDrawListTile("About", () {}),
                    _buildDrawListTile("Contact Us", () {})
                  ]),
                ),
              ),
              Container(
                height: 54,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(1),
                          spreadRadius: 4,
                          blurRadius: 4,
                          offset: const Offset(0, 7))
                    ],
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4.0))),
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Settings"),
                  trailing: IconButton(
                    icon: trailingIcon,
                    onPressed: () {},
                  ),
                  onTap: () {},
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void logoutUser() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil(ModalRoute.withName(""));
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      userData.clear();
      return const MainPage();
    }));
  }

  Widget _buildProfileDrawer(BuildContext context) {
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(children: [
                      IconButton(
                          iconSize: 200,
                          onPressed: () {},
                          icon: const Icon(Icons.person)),
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
                      _buildDrawListTile("Saved Posts", () {}),
                      _buildDrawListTile("Inbox", () {}),
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

  Container _buildTopAlum() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
      // decoration: BoxDecoration(
      //     border: Border.all(color: Colors.blue),
      //     borderRadius: BorderRadius.circular(2.5)),
      child: Column(children: [
        const Center(
            child: Text(
          "Alumni Of The Month",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.person),
                iconSize: 120,
              ),
              Column(
                children: [
                  const Text(
                    "Chosen Alumni Name",
                    style: TextStyle(fontSize: 16),
                  ),
                  const Text("Chosen Alumni Desciption here",
                      style:
                          TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text("Show Profile"),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Show Post"),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        )
      ]),
    );
  }

  Container _buildTopEvents() {
    return Container(
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
        margin: const EdgeInsets.fromLTRB(4, 15, 4, 2),
        child: Column(children: const [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Top Events",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Placeholder(
            fallbackHeight: 600,
          )
        ]));
  }
}

class CustomSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final ThemeModel themeNotifier;
  final Widget pageFeatures;
  final Widget loginModalSheet;

  const CustomSliverAppBarDelegate(
      {required this.expandedHeight,
      required this.themeNotifier,
      required this.pageFeatures,
      required this.loginModalSheet});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        _buildAppBar(shrinkOffset, context),
        _buildBackground(shrinkOffset),
      ],
    );
  }

  double disappear(double shrinkOffset) => 1 - shrinkOffset / expandedHeight;

  Widget _buildBackground(double shrinkOffset) {
    return Opacity(
      opacity: disappear(shrinkOffset),
      child: Image.asset(
        "assets/banner.jpg",
        fit: BoxFit.fitWidth,
      ),
    );
  }

  double appear(double shrinkOffset) => shrinkOffset / expandedHeight;

  Widget _buildAppBar(double shrinkOffset, BuildContext context) {
    print(shrinkOffset);
    return Container();
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => screenHeight * 0.09;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
