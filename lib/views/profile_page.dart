import 'package:alumni/globals.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({required this.uid, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> data = {};

  @override
  void initState() {
    print(widget.uid);
    super.initState();
  }

  Future<bool> getUserDetails() async {
    if (userData["uid"] == widget.uid) {
      data = userData;
      return true;
    } else {
      var temp = await firestore!.collection("users").doc(widget.uid).get();
      Map<String, dynamic> userDataFromFirebase = temp.data()!;
      data = userDataFromFirebase;
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserDetails(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          print(data);
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
          if (userData["uid"] == widget.uid) {
            appBarActions.add(editUserButton);
            appBarActions.add(delUserButton);
          } else if (userData["accessLevel"] == "admin") {
            appBarActions.add(delUserButton);
          }

          return Scaffold(
            // backgroundColor: const Color(backgroundColor),
            appBar: buildAppBar(
              actions: appBarActions,
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
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: NetworkImage(data["profilePic"]),
                  ),
                  SizedBox(height: screenHeight * 0.027),
                  buildName(),
                  SizedBox(height: screenHeight * 0.027),
                  buildEmploymentDetails(),
                  buildContactDetails(),
                  buildCollegeDetails(),
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

  Widget buildEmploymentDetails() {
    if (data["isAnAlumni"] != true) {
      return Container();
    } else {
      return Container();
    }
  }

  Widget buildContactDetails() {
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
            data["email"],
            // style: const TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
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
            data["mobileContactNo"],
            // style: const TextStyle(color: Colors.grey),
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

  Widget buildCollegeDetails() {
    List<Widget> details = [];
    details.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Year of Admission',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          SizedBox(
            height: screenHeight * .005,
          ),
          Text(
            data["admissionYear"].toString(),
            // style: const TextStyle(color: Colors.grey),
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
            data["course"],
            // style: const TextStyle(color: Colors.grey),
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

  Widget buildName() {
    String userType = data["accessLevel"];
    String accessLevel =
        userType.substring(0, 1).toUpperCase() + userType.substring(1);
    return Column(
      children: [
        Text(
          data["name"],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        SizedBox(height: screenHeight * 0.005),
        Text(
          accessLevel,
          style: const TextStyle(
              // color: Colors.grey,
              fontStyle: FontStyle.italic),
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
