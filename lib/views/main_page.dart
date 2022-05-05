import 'package:alumni/firebase_options.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/chat_page.dart';
import 'package:alumni/views/event_creation_page.dart';
import 'package:alumni/views/events_page.dart';
import 'package:alumni/views/forum_page.dart';
import 'package:alumni/views/home_page.dart';
import 'package:alumni/views/post_creation_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/login_popup.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  final int startingIndex;
  const MainPage({this.startingIndex = 0, Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions = <Widget>[
    const HomePage(),
    const EventsPage(),
    const ChatPage(),
    const ForumPage()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late List<Widget?> _floatingActionButtons;

  late final Widget loginModalSheet;

  Future<FirebaseApp> initialiseFirebaseApp() async {
    var temp = await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform)
        .then((value) => value);
    return temp;
  }

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
          backgroundColor: Colors.blue.shade300,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const CreateEvent(
                      eventUpdationFlag: false,
                    )));
          },
          child: const Icon(Icons.add),
        );
      }
      _floatingActionButtons[2] =
          //Chat Floating Button
          FloatingActionButton(
        backgroundColor: Colors.blue.shade300,
        onPressed: () {},
        child: const Icon(Icons.message),
      );
      //Forum Floating Button
      _floatingActionButtons[3] = FloatingActionButton(
        backgroundColor: Colors.blue.shade300,
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreatePostPage()));
        },
        child: const Icon(Icons.add),
      );
    }
  }

  Future<FirebaseApp> initialiseApp() async {
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

  void _saveUserData() async {
    await firestore!
        .collection("users")
        .doc(userData["uid"])
        .get()
        .then((value) {
      var temp = value.data();
      temp!["uid"] = userData["uid"];
      userData = temp;
    });
  }

  void _setUserLoginStatus() {
    User? currentUser = auth!.currentUser;
    if (currentUser != null) {
      userData["uid"] = currentUser.uid;
      _saveUserData();
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
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder(
        future: initialiseApp(),
        builder: ((context, AsyncSnapshot<FirebaseApp> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            app = snapshot.data;
            auth = FirebaseAuth.instance;
            firestore = FirebaseFirestore.instance;
            _setUserLoginStatus();
            _setFloatingActionButtons();
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

  Scaffold _buildPage() {
    List<Widget> pageFeatureWidgets = [];
    if (_selectedIndex == 1) {
      var pastEventButton = buildAppBarIcon(
          onPressed: () {
            print("getting past events");
          },
          icon: Icons.history);

      pageFeatureWidgets.add(pastEventButton);
    } else if (_selectedIndex == 3) {
      var searchForumButton = buildAppBarIcon(
          onPressed: () {
            print("Searching forum");
          },
          icon: Icons.search_rounded);
      pageFeatureWidgets.add(searchForumButton);
    }
    Row pageFeatures = Row(
      children: pageFeatureWidgets,
    );
    return Scaffold(
        floatingActionButton: _floatingActionButtons[_selectedIndex],
        backgroundColor: const Color.fromARGB(255, 0x24, 0x24, 0x24),
        appBar: buildAppBar(
          appBarHeight: null,
          actions: <Widget>[
            Builder(builder: (context) => pageFeatures),
            Builder(
              builder: (context) {
                return buildAppBarIcon(
                    onPressed: () {
                      if (userData["uid"] != null) {
                        Scaffold.of(context).openEndDrawer();
                      } else {
                        showModalBottomSheet(
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
          leading: Builder(
            builder: (context) {
              return buildAppBarIcon(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: Icons.menu_rounded);
            },
          ),
        ),
        drawer: _buildMenuDrawer(context),
        endDrawer:
            userData["uid"] == null ? null : _buildProfileDrawer(context),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: _buildBottomNavBar());
  }

  Container _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade800))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: BottomNavigationBar(
          //elevation: 0.0,
          items: _buildNavBarTabs(),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white70,
          unselectedItemColor: Colors.white24,
          backgroundColor: const Color.fromARGB(255, 56, 56, 56),
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
          backgroundColor: const Color.fromARGB(0xFF, 0x26, 0x26, 0x26),
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
    double topPad = screenHeight * 0.082;
    double bottomPad = screenHeight * 0.01;
    return Container(
      padding: EdgeInsets.fromLTRB(0, topPad, 0, bottomPad),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
        child: Drawer(
          backgroundColor: const Color.fromARGB(0xFF, 0x26, 0x26, 0x26),
          child: Column(
            children: [
              Expanded(
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
                        child: _buildDrawListTile("My Profile", () {})),
                    _buildDrawListTile("Notifications", () {}),
                    _buildDrawListTile("Saved Posts", () {}),
                    _buildDrawListTile("Inbox", () {}),
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
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: () {
                      logoutUser();
                    },
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

  Widget _buildDrawListTile(String title, Function onTap) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(width: 1, color: Colors.grey.shade700))),
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
