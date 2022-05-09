import 'package:alumni/ThemeData/dark_theme.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/event_creation_page.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/ask_message_popup.dart';
import 'package:alumni/widgets/future_widgets.dart';
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

  Future<bool?> getEventAttendanceStatus() async {
    bool? isBeingAttended = await firestore!
        .collection("eventAttendanceStatus")
        .doc(userData["uid"])
        .get()
        .then((value) {
      return value.data()![widget.eventID];
    });
    isBeingAttended ??= false;
    print("user is attending event?" + isBeingAttended.toString());
    return isBeingAttended;
  }

  Future<void> changeAttendeeNumber() async {
    int dbAttendeeNum = await firestore!
        .collection("events")
        .doc(widget.eventID)
        .get()
        .then((value) => value["eventAttendeesNumber"]);
    bool nextAttendingFlag = false;
    int nextAttendeeOffset = 0;
    int changeInDbAttendee = 0;
    if (clickFlags["attending"] == true) {
      nextAttendingFlag = false;
      nextAttendeeOffset = 0;
      changeInDbAttendee = -1;
    } else {
      nextAttendingFlag = true;
      nextAttendeeOffset = 1;
      changeInDbAttendee = 1;
    }
    firestore!
        .collection("events")
        .doc(widget.eventID)
        .update({"eventAttendeesNumber": dbAttendeeNum + changeInDbAttendee});
    print("attendance status changed to" + nextAttendingFlag.toString());
    firestore!
        .collection("eventAttendanceStatus")
        .doc(userData["uid"])
        .update({widget.eventID: nextAttendingFlag});
    setState(() {
      attendees = widget.eventAttendeesNumber + changeInDbAttendee;
      clickFlags["attending"] = nextAttendingFlag;
      attendeeOffset = nextAttendeeOffset;
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
                eventTitleImage: widget.eventTitle,
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
        future: getEventAttendanceStatus(),
        builder: (context, AsyncSnapshot<bool?> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            clickFlags = {
              "attending": snapshot.data!,
              "bookmark": false,
            };
            return _buildPage();
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }

  Scaffold _buildPage() {
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
      attendeeOffset = 1;
      attendeeNumberColor = Colors.blue;
      attendingIconColor = Colors.blue;
      attendingIcon = Icons.event_busy_rounded;
    }
    int currentAttendees;
    if (isInitialBuild) {
      currentAttendees = widget.eventAttendeesNumber;
      isInitialBuild = false;
    } else {
      currentAttendees = widget.eventAttendeesNumber + attendeeOffset;
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
                    currentAttendees.toString(),
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
                      SingleChildScrollView(
                        child: SizedBox(
                          height: screenHeight * .6,
                          child: const TabBarView(children: [
                            Center(child: Text("Description")),
                            Center(child: Text("People")),
                            Center(child: Text("Gallery"))
                          ]),
                        ),
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
