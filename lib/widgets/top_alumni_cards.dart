import 'package:alumni/globals.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/group_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_initicon/flutter_initicon.dart';

class TopAlumniCards extends StatefulWidget {
  const TopAlumniCards({Key? key}) : super(key: key);

  @override
  State<TopAlumniCards> createState() => _TopAlumniCardsState();
}

class _TopAlumniCardsState extends State<TopAlumniCards> {
  late List<Map<String, dynamic>> alumni = [];
  final PageController _pageController = PageController();
  int? _currentPage = 0;

  Future<bool> getTopAlumni() async {
    alumni = [];
    List<String> idList =
        await firestore!.collection("topAlumni").get().then((value) {
      return value.docs.map((e) {
        alumni.add({"topAlumniMessage": e.data()["message"].toString()});
        return e.data()["uid"].toString();
      }).toList();
    });
    print(idList);
    if (idList.isEmpty) {
      return true;
    }
    await firestore!
        .collection("users")
        .where("uid", whereIn: idList)
        .get()
        .then((value) {
      int index = 0;
      value.docs.map((e) {
        print(e.data());
        alumni[index].addAll(e.data());
      }).toList();
    });
    print(alumni);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getTopAlumni(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          List<Widget> children;
          if (snapshot.data == true) {
            List<Widget> header = [];
            if (userData["accessLevel"] == "admin") {
              header.add(Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildAppBarIcon(
                        onPressed: () {},
                        icon: Icons.edit,
                        padding: EdgeInsets.zero),
                    buildAppBarIcon(
                        onPressed: () {},
                        icon: Icons.delete,
                        padding: EdgeInsets.zero)
                  ]));
            } else {
              header.add(SizedBox(
                height: screenHeight * 0.03,
              ));
            }
            return alumni.isEmpty
                ? const Center(
                    child: Text("No alumni have been chosen yet\nStay tuned."),
                  )
                : Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    shadowColor: Theme.of(context).appBarTheme.shadowColor,
                    elevation: 1,
                    color: const Color(0xffC2240B),
                    margin: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    child: SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 0),
                              child: Row(
                                children: header,
                                mainAxisAlignment: MainAxisAlignment.end,
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.625,
                              child: PageView.builder(
                                  onPageChanged: (value) {
                                    setState(() {
                                      _currentPage = value;
                                    });
                                  },
                                  controller: _pageController,
                                  itemCount: alumni.length,
                                  itemBuilder: ((context, index) {
                                    Widget profilePic;
                                    if (alumni[index]["profilePic"] != null) {
                                      profilePic = CircleAvatar(
                                        radius: screenHeight * 0.125,
                                        backgroundImage: Image.network(
                                                alumni[index]["profilePic"])
                                            .image,
                                      );
                                    } else {
                                      profilePic = Initicon(
                                        size: screenHeight * 0.25,
                                        text: alumni[index]["name"],
                                      );
                                    }
                                    String description = "";
                                    String? designation =
                                        alumni[index]["currentDesignation"];
                                    String? currentOrgName =
                                        alumni[index]["currentOrgName"];
                                    if (designation != null &&
                                        designation.isNotEmpty &&
                                        currentOrgName != null &&
                                        currentOrgName.isNotEmpty) {
                                      description =
                                          designation + " at " + currentOrgName;
                                    }
                                    Widget descriptionWidget = const SizedBox();
                                    if (description.isNotEmpty) {
                                      descriptionWidget = Text(
                                        description,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontStyle: FontStyle.italic),
                                      );
                                    }
                                    String collegeTimeSpan = alumni[index]
                                            ["admissionYear"]
                                        .toString();
                                    if (alumni[index]["passingYear"] != null &&
                                        alumni[index]["passingYear"] != "") {
                                      collegeTimeSpan += " - " +
                                          alumni[index]["passingYear"]
                                              .toString();
                                    } else {
                                      collegeTimeSpan += " - Now ";
                                    }
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    ProfilePage(
                                                        uid: alumni[index]
                                                            ["uid"]))));
                                      },
                                      child: SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            profilePic,
                                            SizedBox(
                                              height: screenHeight * 0.025,
                                            ),
                                            Text(
                                              alumni[index]["name"],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: screenHeight * 0.005,
                                            ),
                                            descriptionWidget,
                                            SizedBox(
                                              height: screenHeight * 0.01,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.email,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            screenWidth * 0.025,
                                                      ),
                                                      Text(
                                                        alumni[index]["email"],
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: screenHeight * 0.01,
                                                  ),
                                                  alumni[index]["mobileContactNo"] !=
                                                              null &&
                                                          alumni[index][
                                                                  "mobileContactNo"] !=
                                                              ""
                                                      ? Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.phone,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  screenWidth *
                                                                      0.025,
                                                            ),
                                                            Text(
                                                              alumni[index][
                                                                  "mobileContactNo"],
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            )
                                                          ],
                                                        )
                                                      : const SizedBox()
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: screenHeight * 0.01,
                                            ),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  bottom: 20),
                                              decoration: const BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.grey))),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 16),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.timeline,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    screenWidth *
                                                                        0.025,
                                                              ),
                                                              Text(
                                                                collegeTimeSpan,
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                screenHeight *
                                                                    0.008,
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.school,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    screenWidth *
                                                                        0.025,
                                                              ),
                                                              Text(
                                                                alumni[index]
                                                                    ["course"],
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                            SizedBox(
                                              height: screenHeight * 0.025,
                                            ),
                                            alumni[index]["topAlumniMessage"] !=
                                                        null &&
                                                    alumni[index][
                                                            "topAlumniMessage"] !=
                                                        ""
                                                ? Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8.0),
                                                    child: GroupBox(
                                                        color: Colors.white,
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 14,
                                                                vertical: 12),
                                                        child: Text(
                                                          alumni[index][
                                                              "topAlumniMessage"],
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16),
                                                        ),
                                                        title: "About The Alum",
                                                        titleBackground:
                                                            const Color(
                                                                0xffC2240B)),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                    );
                                  })),
                            ),
                            Container(
                              width: screenWidth,
                              decoration: const BoxDecoration(
                                  border: Border(
                                      top: BorderSide(color: Colors.grey))),
                              child: TextButton(
                                onPressed: () {
                                  _currentPage! < (alumni.length - 1)
                                      ? _pageController
                                          .jumpToPage(_currentPage! + 1)
                                      : print("see more alums");
                                },
                                child: _currentPage! < (alumni.length - 1)
                                    ? Text("Next")
                                    : Text("See more Alums"),
                              ),
                            )
                          ]),
                    ),
                  );
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }
}
