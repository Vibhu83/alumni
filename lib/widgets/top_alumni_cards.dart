import 'package:alumni/globals.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/add_alumni_popup.dart';
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
  late List<Map<String, dynamic>> _alumni;
  late final PageController _pageController;
  late int _currentPage;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _currentPage = 0;
    _alumni = [];
    _pageController = PageController();
    super.initState();
  }

  Future<bool> _getTopAlumni() async {
    _alumni = await firestore!.collection("topAlumni").get().then((value) {
      return value.docs.map((e) {
        return e.data();
      }).toList();
    });
    List<String> idList = _alumni.map((e) {
      return e["uid"].toString();
    }).toList();
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
        _alumni[index].addAll(e.data());
        index++;
      }).toList();
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getTopAlumni(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          List<Widget> children;
          if (snapshot.data == true) {
            List<Widget> header = [];
            if (userData["hasAdminAccess"] == true) {
              header.add(
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildAppBarIcon(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AddAlumniPopUp(
                                    editFlag: true,
                                    message: _alumni[_currentPage]["message"],
                                    uid: _alumni[_currentPage]["uid"],
                                  );
                                }).then((value) {
                              if (value != null) {
                                setState(() {
                                  _alumni[_currentPage]["message"] = value;
                                });
                              }
                            });
                          },
                          icon: Icons.edit,
                          padding: EdgeInsets.zero),
                      buildAppBarIcon(
                          onPressed: () {
                            firestore!
                                .collection("topAlumni")
                                .doc(_alumni[_currentPage]["uid"])
                                .delete();
                            setState(() {
                              _alumni.removeAt(_currentPage);
                              if (_currentPage != 0) {
                                _pageController.jumpToPage(_currentPage--);
                              }
                            });
                          },
                          icon: Icons.delete,
                          padding: EdgeInsets.zero),
                    ]),
              );
            } else {
              header.add(SizedBox(
                height: screenHeight * 0.01,
              ));
            }
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              shadowColor: Theme.of(context).appBarTheme.shadowColor,
              elevation: 1,
              color: const Color.fromARGB(255, 0, 104, 0),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: screenHeight * 0.06,
                        color: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.zero,
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.white))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "Chosen Alum (" +
                                    (_currentPage + 1).toString() +
                                    "/" +
                                    _alumni.length.toString() +
                                    ")",
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                width: screenWidth * 0.125,
                              ),
                              Row(
                                children: header,
                                mainAxisAlignment: MainAxisAlignment.center,
                              ),
                            ],
                          ),
                        )),
                    Flexible(
                      child: Center(
                        child: PageView.builder(
                            controller: _pageController,
                            itemCount: _alumni.length,
                            onPageChanged: (value) {
                              setState(() {
                                _currentPage = value;
                              });
                            },
                            itemBuilder: ((context, index) {
                              Widget profilePic;
                              if (_alumni[index]["profilePic"] != null) {
                                profilePic = CircleAvatar(
                                  radius: screenHeight * 0.125,
                                  backgroundImage: Image.network(
                                          _alumni[index]["profilePic"])
                                      .image,
                                );
                              } else {
                                profilePic = Initicon(
                                  size: screenHeight * 0.25,
                                  text: _alumni[index]["name"],
                                );
                              }
                              String description = "";
                              String? designation =
                                  _alumni[index]["currentDesignation"];
                              String? currentOrgName =
                                  _alumni[index]["currentOrgName"];
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
                              String collegeTimeSpan =
                                  _alumni[index]["admissionYear"].toString();
                              if (_alumni[index]["passingYear"] != null &&
                                  _alumni[index]["passingYear"] != "") {
                                collegeTimeSpan += " - " +
                                    _alumni[index]["passingYear"].toString();
                              } else {
                                collegeTimeSpan += " - Now ";
                              }
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: ((context) => ProfilePage(
                                          uid: _alumni[index]["uid"]))));
                                },
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.01),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 16),
                                          child: profilePic,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 6),
                                          child: Text(
                                            _alumni[index]["name"],
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: descriptionWidget,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 16),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Row(
                                                  children: [
                                                    const Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 10),
                                                      child: Icon(
                                                        Icons.email,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    Text(
                                                      _alumni[index]["email"],
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              _alumni[index]["mobileContactNo"] !=
                                                          null &&
                                                      _alumni[index][
                                                              "mobileContactNo"] !=
                                                          ""
                                                  ? Row(
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 10),
                                                          child: Icon(
                                                            Icons.phone,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Text(
                                                          _alumni[index][
                                                              "mobileContactNo"],
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  : const SizedBox()
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding:
                                              const EdgeInsets.only(bottom: 20),
                                          decoration: _alumni[index]
                                                          ["message"] !=
                                                      null &&
                                                  _alumni[index]["message"] !=
                                                      ""
                                              ? const BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.grey)))
                                              : null,
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
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 6.0),
                                                        child: Row(
                                                          children: [
                                                            const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          10),
                                                              child: Icon(
                                                                Icons.timeline,
                                                                color: Colors
                                                                    .white,
                                                              ),
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
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    right: 10),
                                                            child: Icon(
                                                              Icons.school,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          Text(
                                                            _alumni[index]
                                                                ["course"],
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ]),
                                        ),
                                        _alumni[index]["message"] != null &&
                                                _alumni[index]["message"] != ""
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16,
                                                        horizontal: 8.0),
                                                child: GroupBox(
                                                  color: Colors.white,
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 14,
                                                      vertical: 12),
                                                  child: Text(
                                                    _alumni[index]["message"],
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                                  title: "About",
                                                  titleBackground:
                                                      const Color.fromARGB(
                                                          255, 0, 104, 0),
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            })),
                      ),
                    ),
                    Container(
                      width: screenWidth,
                      height: screenHeight * 0.05,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey))),
                      child: TextButton(
                        onPressed: () {
                          _currentPage < (_alumni.length - 1)
                              ? _pageController.jumpToPage(_currentPage + 1)
                              : null;
                        },
                        child: _currentPage < (_alumni.length - 1)
                            ? const Text("Next")
                            : Text(
                                "",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor
                                        .withOpacity(0.75)),
                              ),
                      ),
                    )
                  ]),
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
