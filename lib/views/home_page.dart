import 'package:alumni/globals.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/LoginPopUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget loginModalSheet = const LoginRegisterPopUp();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 15),
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  child: Text('${snapshot.error}'),
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
        ),
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
        ]));
  }

  Future<List> getUserSummary() async {
    User? currentUser = auth!.currentUser;
    String? uid;
    if (currentUser != null) {
      uid = currentUser.uid;
    }
    String title = "";
    String subtitle = "";
    Function? onPressingNotificationButton;
    if (currentUser != null) {
      onPressingNotificationButton = () {};
      var temp = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      title = "Hello, " + temp.data()!["name"];
      subtitle = "";
    } else {
      title = "Not signed in";
      subtitle = "Click here to login in/register";
      onPressingNotificationButton = null;
    }
    return [title, subtitle, onPressingNotificationButton, uid];
  }

  Widget _buildProfileMessage(BuildContext context, String title,
      String subtitle, Function? onPressingNotificationButton, String? uid) {
    return Container(
        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 24, right: 24),
        margin: const EdgeInsets.only(bottom: 16, top: 0),
        child: ListTile(
            onTap: () {
              if (uid == null) {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return loginModalSheet;
                    });
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: ((context) => ProfilePage(
                          uid: uid,
                        ))));
              }
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