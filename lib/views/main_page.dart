import 'package:alumni/firebase_options.dart';
import 'package:alumni/views/chat_page.dart';
import 'package:alumni/views/events_page.dart';
import 'package:alumni/views/forum_page.dart';
import 'package:alumni/views/post_creation_page.dart';
import 'package:alumni/views/register_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'login_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

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

  late final FirebaseApp app;
  late double screenHeight;
  late double screenWidth;
  late double appBarHeight;

  late final List<Widget?> _floatingActionButtons = [
    //Home Floating Button
    null,
    //Events Floating Button
    FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.add),
    ),
    //Chat Floating Button
    FloatingActionButton(
      onPressed: () {},
      child: const Icon(Icons.message),
    ),
    //Forum Floating Button
    FloatingActionButton(
      onPressed: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreatePostPage()));
      },
      child: const Icon(Icons.add),
    ),
  ];

  bool? isAUserLoggedIn;

  late final Widget loginModalSheet;

  Future<FirebaseApp> initialiseApp() async {
    if (Firebase.apps.isEmpty) {
      var temp = await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform)
          .then((value) => value);
      return temp;
    } else {
      return Firebase.apps[Firebase.apps.length - 1];
    }
  }

  void _setUserLoginStatus() {
    if (FirebaseAuth.instanceFor(app: app).currentUser != null) {
      isAUserLoggedIn = true;
    } else {
      isAUserLoggedIn = false;
    }
  }

  @override
  void initState() {
    initialiseApp().then((value) {
      app = value;
      _setUserLoginStatus();
    });
    super.initState();
    loginModalSheet = const LoginRegisterPopUp();
    if (isAUserLoggedIn == false) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return loginModalSheet;
            });
      });
    }
  }

  @override
  void dispose() {
    _widgetOptions.clear();
    _floatingActionButtons.clear();
    app.delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    appBarHeight = screenHeight * 0.045;
    List<Widget> pageFeatureWidgets = [];
    if (_selectedIndex == 1) {
      pageFeatureWidgets.add(IconButton(
        onPressed: () {},
        icon: const Icon(Icons.history),
        iconSize: 20,
        splashRadius: 1,
        padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
      ));
    } else if (_selectedIndex == 3) {
      pageFeatureWidgets.add(IconButton(
        iconSize: 20,
        splashRadius: 1,
        padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
        icon: const Icon(Icons.search),
        onPressed: () {},
      ));
    }
    Row pageFeatures = Row(
      children: pageFeatureWidgets,
    );
    return Scaffold(
        floatingActionButton: _floatingActionButtons[_selectedIndex],
        backgroundColor: const Color.fromARGB(255, 0x24, 0x24, 0x24),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBarHeight),
          child: Container(
            decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: Colors.grey.shade800))),
            child: AppBar(
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(8))),
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    iconSize: 16,
                    splashRadius: 1,
                    padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
                    icon: const Icon(Icons.menu_rounded),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              actions: <Widget>[
                Builder(builder: (context) => pageFeatures),
                Builder(
                  builder: (context) {
                    return IconButton(
                      iconSize: 20,
                      splashRadius: 1,
                      padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                      icon: const Icon(Icons.person),
                      onPressed: () {
                        if (isAUserLoggedIn == true) {
                          Scaffold.of(context).openEndDrawer();
                        } else {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return loginModalSheet;
                              });
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        drawer: _buildMenuDrawer(context),
        endDrawer:
            isAUserLoggedIn == false ? null : _buildProfileDrawer(context),
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
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.event_rounded),
        label: 'Events',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.chat_bubble_outline_rounded),
        label: 'Chat',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.forum_outlined), label: 'Forum')
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
                    icon: Icon(Icons.logout_rounded),
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget loginModalSheet = const LoginRegisterPopUp();

  late FirebaseApp app;

  @override
  void initState() {
    super.initState();
  }

  Future<FirebaseApp> initialiseApp() async {
    var temp = await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform)
        .then((value) => value);
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initialiseApp(),
      builder: (context, AsyncSnapshot<FirebaseApp> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          app = snapshot.data!;
          return Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  FutureBuilder(
                    future: getUserSummary(),
                    builder: (context, AsyncSnapshot<List> snapshot) {
                      List<Widget> children;
                      if (snapshot.hasData) {
                        var data = snapshot.data;
                        return _buildProfileMessage(
                            context, data![0], data[1], data[2], data[3]);
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
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Fetching posts'),
                          )
                        ];
                      }
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: children,
                        ),
                      );
                    },
                  ),
                  // _buildTopAlum(),
                  // _buildTopEvents(),
                  _buildTopPosts()
                ])),
          );
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

  Container _buildTopPosts() {
    return Container(
        padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
        margin: const EdgeInsets.fromLTRB(4, 15, 4, 2),
        child: Column(children: const [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Top Posts",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ]));
  }

  Future<List> getUserSummary() async {
    FirebaseAuth auth = FirebaseAuth.instanceFor(app: app);
    bool isSignedIn = false;
    User? currentUser = auth.currentUser;
    if (currentUser != null) {
      isSignedIn = true;
    }
    String title = "Hello ";
    String subtitle = "";
    Function? onPressingNotificationButton;
    if (isSignedIn == true) {
      onPressingNotificationButton = () {};
      var temp = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .get();
      title = "Hello, " + temp.data()!["name"];
      subtitle = "";
    } else {
      title = "Not signed in";
      subtitle = "Click here to login in/register";
      onPressingNotificationButton = null;
    }
    return [title, subtitle, onPressingNotificationButton, isSignedIn];
  }

  Widget _buildProfileMessage(
      BuildContext context,
      String title,
      String subtitle,
      Function? onPressingNotificationButton,
      bool isUserSignedIn) {
    return Container(
        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 24, right: 24),
        margin: const EdgeInsets.only(bottom: 16, top: 0),
        child: ListTile(
            onTap: () {
              if (isUserSignedIn == false) {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return loginModalSheet;
                    });
              } else {}
            },
            style: ListTileStyle.list,
            dense: true,
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            trailing: IconButton(
              onPressed: onPressingNotificationButton as void Function()?,
              icon: const Icon(Icons.notifications),
            )));
  }
}

class LoginRegisterPopUp extends StatelessWidget {
  const LoginRegisterPopUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
      decoration: BoxDecoration(color: Colors.transparent.withAlpha(164)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 360,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(6),
          ),
          color: Color.fromARGB(255, 19, 37, 36),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "You are not logged in!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 3),
              Text(
                "Login or Register to access all the features",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(.6),
                ),
              ),
              const SizedBox(height: 80),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginView(),
                    ),
                  );
                },
                child: Container(
                  width: double.maxFinite / 2,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xff2E933C),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterView(),
                    ),
                  );
                },
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(
                        8,
                      ),
                    ),
                    border: Border.all(
                      color: Color(0xffB4C5E4),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Register now',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
