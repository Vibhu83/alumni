import 'package:alumni/views/events_page.dart';
import 'package:alumni/views/posts_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:flutter/material.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key);

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  late int _selectedTab;
  late List<BottomNavigationBarItem> _tabs;

  @override
  void initState() {
    _tabs = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.event_outlined),
        activeIcon: Icon(Icons.event_sharp),
        label: 'Events',
      ),
      BottomNavigationBarItem(
          icon: Icon(Icons.forum),
          activeIcon: Icon(Icons.forum_sharp),
          label: 'Posts'),
    ];
    _selectedTab = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(
            leading: buildAppBarIcon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icons.close)),
        body: _selectedTab == 0
            ? const EventsPage(
                showBookmarkedEventsFlag: true,
              )
            : const ForumPage(
                showBookmarkedPostsFlag: true,
              ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).appBarTheme.shadowColor!.withOpacity(0.3),
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
              onTap: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).appBarTheme.foregroundColor,
              unselectedItemColor: Theme.of(context)
                  .appBarTheme
                  .foregroundColor!
                  .withOpacity(0.7),
            ),
          ),
        ));
  }
}
