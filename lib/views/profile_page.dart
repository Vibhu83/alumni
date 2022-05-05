import 'package:alumni/globals.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/ProfilePictureWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({required this.uid, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late double screenHeight;
  late double screenWidth;
  late bool isTheProfileOfCurrentUser;

  @override
  void initState() {
    super.initState();
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    isTheProfileOfCurrentUser = false;
    if (userData["uid"] == widget.uid) {
      isTheProfileOfCurrentUser = true;
      return userData;
    }
    if (isTheProfileOfCurrentUser == false) {
      var temp = await FirebaseFirestore.instanceFor(app: app!)
          .collection("users")
          .doc(widget.uid)
          .get();
      Map<String, dynamic> userData = temp.data()!;
      return userData;
    } else {
      var temp = await FirebaseFirestore.instanceFor(app: app!)
          .collection("users")
          .doc(widget.uid)
          .get();
      Map<String, dynamic> userDataFromDB = temp.data()!;
      return userDataFromDB;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    double appBarHeight = screenHeight * 0.045;
    return FutureBuilder(
      future: getUserDetails(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          Map<String, dynamic> userData = snapshot.data!;
          List<Widget> appBarActions = [];
          Widget delUserButton = IconButton(
              splashRadius: 16,
              onPressed: () {
                print("deleting profile");
              },
              icon: const Icon(
                Icons.delete_rounded,
                size: 20,
              ));
          Widget editUserButton = IconButton(
              splashRadius: 16,
              onPressed: () {
                print("editing profile");
              },
              icon: const Icon(
                Icons.edit_rounded,
                size: 20,
              ));
          if (isTheProfileOfCurrentUser == true) {
            appBarActions.add(editUserButton);
            appBarActions.add(delUserButton);
          }
          if (userData["accessLevel"] == "admin") {
            appBarActions.add(delUserButton);
          }

          print(userData);
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 0x24, 0x24, 0x24),
            appBar: buildAppBar(
              actions: appBarActions,
              appBarHeight: appBarHeight,
              leading: IconButton(
                splashRadius: 0.1,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  SizedBox(height: screenHeight * 0.02),
                  ProfilePicture(
                    isEdit: false,
                    imagePath: userData["photo"],
                    onClicked: () {},
                  ),
                  SizedBox(height: screenHeight * 0.027),
                  buildName(userData["name"], userData["accessLevel"]),
                  SizedBox(height: screenHeight * 0.027),
                  buildEmploymentDetails(userData["accessLevel"]),
                  buildContactDetails(userData["email"], userData["phone"]),
                  buildCollegeDetails(userData["batch"], userData["course"]),
                  buildAbout(),
                ],
              ),
            ),
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

  Widget buildEmploymentDetails(String type) {
    if (type != "Alumni") {
      return Container();
    } else {
      return Container();
    }
  }

  Widget buildContactDetails(String email, Map phoneDetails) {
    List<Widget> details = [];
    details.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Email',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: screenHeight * .005,
          ),
          Text(
            email,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
    if (phoneDetails["public?"] == true) {
      details.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phone',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: screenHeight * .005,
            ),
            Text(
              phoneDetails["number"],
              style: const TextStyle(color: Colors.grey),
            )
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: screenHeight * 0.021,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: details,
            ),
          ),
          SizedBox(height: screenHeight * 0.027),
        ],
      ),
    );
  }

  Widget buildCollegeDetails(String batchYear, String course) {
    List<Widget> details = [];
    details.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Batch of',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: screenHeight * .005,
          ),
          Text(
            batchYear.toString(),
            style: const TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
    details.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Course',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: screenHeight * .005,
          ),
          Text(
            course,
            style: const TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'College Details',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: screenHeight * 0.021,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: details,
            ),
          ),
          SizedBox(height: screenHeight * 0.027),
        ],
      ),
    );
  }

  Widget buildName(String name, String userType) {
    String accessLevel =
        userType.substring(0, 1).toUpperCase() + userType.substring(1);
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        SizedBox(height: screenHeight * 0.005),
        Text(
          accessLevel,
          style:
              const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        )
      ],
    );
  }

  Widget buildAbout() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * .021),
            const Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );
}
