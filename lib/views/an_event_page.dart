import 'package:alumni/ThemeData/dark_theme.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/event_creation_page.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/ask_message_popup.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AnEventPage extends StatefulWidget {
  final String eventID;
  final Image? eventTitleImage;
  final String eventTitle;
  final int eventAttendeesNumber;
  final String eventHolder;
  final DateTime eventStartTime;
  final Duration eventDuration;
  final String? eventLink;
  const AnEventPage(
      {required this.eventID,
      this.eventTitleImage,
      required this.eventTitle,
      required this.eventHolder,
      required this.eventAttendeesNumber,
      required this.eventStartTime,
      required this.eventDuration,
      this.eventLink,
      Key? key})
      : super(key: key);

  @override
  State<AnEventPage> createState() => _AnEventPageState();
}

class _AnEventPageState extends State<AnEventPage> {
  late Map<String, bool> clickFlags;
  late int attendeeOffset;
  late bool isInitialBuild;
  late int attendees;

  @override
  void initState() {
    attendees = widget.eventAttendeesNumber;
    isInitialBuild = true;
    attendeeOffset = 0;
    clickFlags = {
      "attending": false,
      "bookmark": false,
    };
    super.initState();
  }

  Future<Map<String, dynamic>> getEventDetails() async {
    await getEventAttendanceStatus();
    Map<String, dynamic> eventDetails = {
      "eventDescription":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
      "peopleInEvent": [
        {
          "uid": null,
          "name": "Guest1",
          "position": "Some position at some organisation",
          "contactDetails": {
            "email": "someEmail@example.com",
            "phone": "1234567890"
          }
        },
        {"uid": "nhiTh5NYDaU64CsY5KDzgiU6DhD3"}
      ],
      "gallery": [
        "https://firebasestorage.googleapis.com/v0/b/alumni-npgc-flutter.appspot.com/o/gallery_images%2Fn6.jfif?alt=media&token=45c5a103-33b8-4830-84ab-d758e9833558",
        "https://firebasestorage.googleapis.com/v0/b/alumni-npgc-flutter.appspot.com/o/gallery_images%2Fn9.jfif?alt=media&token=41b9f759-9cd0-409d-8e4a-343ef698a897",
        "https://firebasestorage.googleapis.com/v0/b/alumni-npgc-flutter.appspot.com/o/gallery_images%2Fn6.jfif?alt=media&token=45c5a103-33b8-4830-84ab-d758e9833558",
        "https://firebasestorage.googleapis.com/v0/b/alumni-npgc-flutter.appspot.com/o/gallery_images%2Fn6.jfif?alt=media&token=45c5a103-33b8-4830-84ab-d758e9833558"
      ]
    };
    List<Map<String, dynamic>> idHolder = [];
    List<Map<String, dynamic>> people = eventDetails["peopleInEvent"];
    for (int i = 0; i < people.length; i++) {
      if (people[i]["uid"] != null) {
        idHolder.add({"index": i, "uid": people[i]["uid"]});
      }
    }
    List<Map<String, dynamic>> idDetails = await getPeopleDetailsByID(idHolder);
    for (Map<String, dynamic> map in idDetails) {
      int index = map["index"];
      map.remove("index");
      people[index] = map;
    }
    eventDetails["peopleInEvent"] = people;
    return eventDetails;
  }

  Future<List<Map<String, dynamic>>> getPeopleDetailsByID(
      List<Map<String, dynamic>> idHolder) async {
    List<String> ids = idHolder.map((e) {
      String temp = e["uid"];
      return temp;
    }).toList();
    int count = -1;
    List<Map<String, dynamic>> details = await firestore!
        .collection("users")
        .where("uid", whereIn: ids)
        .get()
        .then((value) {
      return value.docs.map((e) {
        count++;
        Map<String, dynamic> value = e.data();
        String? phone;
        if (value["phone"]["public?"]) {
          phone = value["phone"]["number"];
        }
        String? position;
        if (value["designation"] != null ||
            value["currentOrganisation"] != null) {
          position =
              value["designation"] + "at " + value["currentOrganisation"];
        }
        return {
          "uid": value["uid"],
          "index": idHolder[count]["index"],
          "name": value["name"],
          "position": position,
          "contactDetails": {"email": value["email"], "phone": phone}
        };
      }).toList();
    });
    return details;
  }

  Future<bool?> getEventAttendanceStatus() async {
    if (isInitialBuild && userData["uid"] != null) {
      isInitialBuild = false;
      bool? isBeingAttended = await firestore!
          .collection("eventAttendanceStatus")
          .doc(userData["uid"])
          .get()
          .then((value) {
        return value.data()![widget.eventID];
      });
      isBeingAttended ??= false;
      print("user is attending event?" + isBeingAttended.toString());
      clickFlags["attending"] = isBeingAttended;
      return true;
    } else {
      return true;
    }
  }

  void changeAttendeeNumber() async {
    bool nextAttendingFlag = false;
    int nextAttendeeNum = 0;
    if (clickFlags["attending"] == true) {
      nextAttendingFlag = false;
      nextAttendeeNum = attendees - 1;
    } else {
      nextAttendingFlag = true;
      nextAttendeeNum = attendees + 1;
    }
    setState(() {
      attendees = nextAttendeeNum;
      clickFlags["attending"] = nextAttendingFlag;
      lastEventAttendeeChange = attendees - widget.eventAttendeesNumber;
      lastEventBool = clickFlags["attending"];
    });
  }

  void deleteEvent() {
    firestore!.collection("events").doc(widget.eventID).delete();
    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const MainPage(
        startingIndex: 1,
      );
    }));
  }

  List<Widget> _setActionButtons() {
    List<Widget> appBarActions = [];
    if (userData["accessLevel"] == "admin") {
      IconButton shareButton = buildAppBarIcon(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AskMessagePopUp(
                      editingFlag: false,
                      title: widget.eventTitle,
                      authorName: widget.eventHolder,
                      id: widget.eventID,
                      type: "event");
                });
          },
          icon: Icons.notification_add_rounded);
      appBarActions.add(shareButton);

      IconButton editButton = buildAppBarIcon(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return CreateEvent(
                eventUpdationFlag: true,
                eventId: widget.eventID,
                eventDescription: null,
                eventDuration: widget.eventDuration.inHours,
                eventHolder: widget.eventHolder,
                eventLink: widget.eventLink,
                eventStartTime: widget.eventStartTime,
                eventTitle: widget.eventTitle,
              );
            }));
          },
          icon: Icons.edit);
      appBarActions.add(editButton);
      IconButton deleteButton = buildAppBarIcon(
          onPressed: () {
            deleteEvent();
          },
          icon: Icons.delete_rounded);
      appBarActions.add(deleteButton);
    }
    return appBarActions;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getEventDetails(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            return _buildPage(snapshot.data!);
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }

  Scaffold _buildPage(Map<String, dynamic> details) {
    //setting various eventAction button's icon and color
    double appBarHeight = screenHeight * 0.045;
    Color bookMarkIconColor = Colors.grey;
    IconData bookMarkIcon = Icons.bookmark_add;
    Color attendingIconColor = Colors.grey;
    IconData attendingIcon = Icons.event_available_rounded;
    Color attendeeNumberColor = Colors.grey;
    attendeeOffset = 0;
    if (clickFlags["bookmark"] == true) {
      bookMarkIcon = Icons.bookmark_added;
      bookMarkIconColor = Colors.blue;
    }
    if (clickFlags["attending"] == true) {
      attendeeNumberColor = Colors.blue;
      attendingIconColor = Colors.blue;
      attendingIcon = Icons.event_busy_rounded;
    }
    //

    List<Widget> firstRowChildren = [
      Flexible(
        child: Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.eventTitle,
                style: GoogleFonts.lato(
                    fontSize: 18, height: 1.3, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                softWrap: false,
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                "By: " + widget.eventHolder,
                style:
                    GoogleFonts.lato(fontSize: 11, color: Colors.grey.shade300),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              const SizedBox(
                height: 6,
              ),
              Row(
                children: [
                  Text(
                    attendees.toString(),
                    style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: attendeeNumberColor),
                  ),
                  Text(
                    " Attendees",
                    style: GoogleFonts.lato(
                        fontSize: 14, color: Colors.grey.shade400),
                  )
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                const Icon(
                  Icons.event_note_rounded,
                  size: 18,
                ),
                const SizedBox(
                  width: 2,
                ),
                SizedBox(
                  width: (screenWidth * .38),
                  child: Text(
                      "On: " +
                          formatDateTime(widget.eventStartTime) +
                          " \nFor: " +
                          widget.eventDuration.inHours.toString() +
                          " hours",
                      style: GoogleFonts.lato(fontSize: 10)),
                ),
              ]),
            ],
          ),
        ),
      ),
    ];

    if (widget.eventTitleImage != null) {
      firstRowChildren.add(const Placeholder(
        fallbackHeight: 110,
        fallbackWidth: 125,
      ));
    }
    List<Widget> iconButtons = [
      IconButton(
          splashRadius: 1,
          onPressed: () {
            changeAttendeeNumber();
          },
          icon: Icon(
            attendingIcon,
            color: attendingIconColor,
          )),
      IconButton(
          splashRadius: 1,
          onPressed: () {
            setState(() {
              if (clickFlags["bookmark"] == true) {
                clickFlags["bookmark"] = false;
              } else {
                clickFlags["bookmark"] = true;
              }
            });
          },
          icon: Icon(
            bookMarkIcon,
            color: bookMarkIconColor,
          )),
      IconButton(
          onPressed: () {
            if (widget.eventLink != null) {
              launchUrl(Uri.parse(widget.eventLink!));
            }
          },
          icon: const Icon(Icons.open_in_new))
    ];
    Widget eventOptions = Container(
        decoration:
            BoxDecoration(color: Colors.grey.shade900.withOpacity(0.75)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: iconButtons,
        ));
    if (userData["uid"] == null) {
      eventOptions = const SizedBox(
        height: 0,
      );
    }
    List<Widget> appBarActions = _setActionButtons();
    List<Map<String, dynamic>> people = details["peopleInEvent"];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(eventPageBackground),
      appBar: buildAppBar(
          actions: appBarActions,
          appBarHeight: appBarHeight,
          leading: buildAppBarIcon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icons.close)),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: firstRowChildren,
              ),
              const SizedBox(
                height: 8,
              ),
              eventOptions,
              SizedBox(height: screenHeight * 0.01),
              DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(tabs: [
                        Tab(
                          text: "Description",
                        ),
                        Tab(
                          text: "People",
                        ),
                        Tab(
                          text: "Gallery",
                        )
                      ]),
                      SizedBox(
                        height: screenHeight * .625,
                        child: TabBarView(children: [
                          SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 8),
                              child: Text(details["eventDescription"]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 8),
                            child: ListView.builder(
                                itemCount: people.length,
                                itemBuilder: ((context, index) {
                                  String subTitle = "";
                                  if (people[index]["position"] == null) {
                                    subTitle = "";
                                  } else {
                                    subTitle = people[index]["position"];
                                  }
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: const Color(eventCardColor),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: ListTile(
                                      isThreeLine: true,
                                      title: Text(people[index]["name"]),
                                      subtitle: Text(subTitle),
                                    ),
                                  );
                                })),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2, vertical: 8),
                            child: GridView.builder(
                                itemCount: details["gallery"].length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5),
                                itemBuilder: (context, index) {
                                  return Container(
                                      decoration: BoxDecoration(
                                    color: const Color(postCardColor),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(
                                          details["gallery"][index]),
                                    ),
                                  ));
                                }),
                          )
                        ]),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
