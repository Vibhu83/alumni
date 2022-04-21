import 'package:alumni/views/chat_page.dart';
import 'package:alumni/views/events_page.dart';
import 'package:alumni/views/forum_page.dart';
import 'package:alumni/views/post_creation_page.dart';
import 'package:alumni/views/sign_up_and_in_page.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late final List<Widget> _widgetOptions;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<FloatingActionButton?> _floatingActionButtons;

  double appBarHeight = 32;
  @override
  void initState() {
    _widgetOptions = <Widget>[
      const HomePage(),
      const EventsPage(),
      const ChatPage(),
      const ForumPage()
    ];
    _floatingActionButtons = [
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

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pageFeatureWidgets = [];
    if (_selectedIndex == 3) {
      IconButton searchIconButton = IconButton(
        iconSize: 20,
        splashRadius: 1,
        padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
        icon: const Icon(Icons.search),
        onPressed: () {},
      );
      pageFeatureWidgets.add(searchIconButton);
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
                        Scaffold.of(context).openEndDrawer();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        drawer: _buildMenuDrawer(context),
        endDrawer: _buildProfileDrawer(context),
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
    Icon trailingIcon = const Icon(Icons.nightlight);
    double topPad = appBarHeight * 2;
    return Container(
      padding: EdgeInsets.fromLTRB(0, topPad, 0, 12),
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
                height: 50,
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
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MainPage()));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDrawer(BuildContext context) {
    double topPad = appBarHeight * 2;
    return Container(
      padding: EdgeInsets.fromLTRB(0, topPad, 0, 12),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
        child: Drawer(
          backgroundColor: const Color.fromARGB(0xFF, 0x26, 0x26, 0x26),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            child: Column(children: [
              IconButton(
                  iconSize: 200,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const WelcomePage()));
                  },
                  icon: const Icon(Icons.person)),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: _buildDrawListTile("My Profile", () {})),
              _buildDrawListTile("Notifications", () {}),
              _buildDrawListTile("Saved Posts", () {}),
              _buildDrawListTile("Inbox", () {}),
              _buildDrawListTile("Manage Your Profile", () {})
            ]),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildProfileMessage(context),
        // _buildTopAlum(),
        // _buildTopEvents(),
        _buildTopPosts()
      ])),
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
          //_buildAPostSummary("title", "Me", true, 144, false)
        ]));
  }

  Widget _buildProfileMessage(BuildContext context) {
    bool isSignedIn = false;
    String title;
    String subtitle;
    Function? onPressingNotificationButton;
    if (isSignedIn == true) {
      onPressingNotificationButton = () {};
      title = "Hello Vibhu";
      subtitle = "";
    } else {
      title = "Not signed in";
      subtitle = "Click here to sign in/register";
      onPressingNotificationButton = null;
    }
    return Container(
        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 24, right: 24),
        margin: const EdgeInsets.only(bottom: 16, top: 0),
        child: ListTile(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const WelcomePage()));
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
