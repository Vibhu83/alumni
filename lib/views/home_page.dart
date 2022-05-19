import 'package:alumni/globals.dart';
import 'package:alumni/views/notification_page.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/login_popup.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/notice_popup.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget loginModalSheet = const LoginRegisterPopUp();
  Widget? noticeWidget;
  @override
  void initState() {
    noticeWidget = const SizedBox();
    super.initState();
  }

  Future<Widget> checkForNotices() async {
    var notices = await firestore!
        .collection("notices")
        .where("noticeID", whereNotIn: userData["noticesDismissed"])
        .get()
        .then((value) {
      return value.docs.map((e) {
        return e.data();
      }).toList();
    });
    if (notices.isNotEmpty) {
      return Notices(
        notices: notices,
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FutureBuilder(
            future: checkForNotices(),
            builder: (context, AsyncSnapshot<Widget> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                return snapshot.data!;
              } else if (snapshot.hasError) {
                children = buildFutureError(snapshot);
              } else {
                children = buildFutureLoading(snapshot);
              }
              return buildFuture(children: children);
            }),
        // _buildTopAlum(),
        // _buildTopEvents(),
        // _buildTopPosts(),
        Container(
          height: 720,
        )
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
        ]));
  }
}
