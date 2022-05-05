import 'package:alumni/globals.dart';
import 'package:alumni/views/event_creation_page.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/ask_message_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final bool readOnly;
  const AnEventPage(
      {required this.eventID,
      this.eventTitleImage,
      required this.eventTitle,
      required this.eventHolder,
      required this.eventAttendeesNumber,
      required this.eventStartTime,
      required this.eventDuration,
      this.eventLink,
      this.readOnly = false,
      Key? key})
      : super(key: key);

  @override
  State<AnEventPage> createState() => _AnEventPageState();
}

class _AnEventPageState extends State<AnEventPage> {
  String formatDateTime(DateTime dateTime) {
    final Map monthMap = {
      1: "January",
      2: "February",
      3: "March",
      4: "April",
      5: "May",
      6: "June",
      7: "July",
      8: "August",
      9: "September",
      10: "October",
      11: "November",
      12: "December"
    };
    DateTime current = DateTime.now();
    String year = "";
    String month = "";
    String date = "";
    String returnString = "";
    String datePostFix = "";
    if (current.year != dateTime.year) {
      year = dateTime.year.toString();
      month = monthMap[dateTime.month];
      date = dateTime.day.toString();
      int temp = dateTime.day % 10;
      if (temp == 1) {
        datePostFix = "st";
      } else if (temp == 2) {
        datePostFix = "nd";
      } else if (temp == 3) {
        datePostFix = "rd";
      } else {
        datePostFix = "th";
      }
      date += datePostFix;
      returnString = month + " " + date + ", " + year;
    } else {
      if (current.month != dateTime.month) {
        month = monthMap[dateTime.month];
        date = dateTime.day.toString();
        int temp = dateTime.day % 10;
        if (temp == 1) {
          datePostFix = "st";
        } else if (temp == 2) {
          datePostFix = "nd";
        } else if (temp == 3) {
          datePostFix = "rd";
        } else {
          datePostFix = "th";
        }
        date += datePostFix;
        returnString = month + " " + date;
      } else {
        if (current.day == dateTime.day) {
          date = "Today";
        } else {
          date = dateTime.day.toString();
          int temp = dateTime.day % 10;
          if (temp == 1) {
            datePostFix = "st";
          } else if (temp == 2) {
            datePostFix = "nd";
          } else if (temp == 3) {
            datePostFix = "rd";
          } else {
            datePostFix = "th";
          }
          date += datePostFix;
        }
        returnString = date;
      }
    }

    String hour = dateTime.hour.toString();
    String minute = dateTime.minute.toString();
    returnString += " at " + hour + ":" + minute;
    return returnString;
  }

  late Map<String, bool> clickFlags;
  late int attendeeOffset;

  @override
  void initState() {
    attendeeOffset = 0;
    clickFlags = {
      "attending": false,
      "bookmark": false,
    };
    super.initState();
  }

  Future<void> changeAttendeeNumber() async {
    var doc = await FirebaseFirestore.instance
        .collection("events")
        .doc(widget.eventID)
        .get()
        .then((value) => value);
    int dbAttendeeNum = doc.data()!["eventAttendeesNumber"];
    setState(() {
      if (clickFlags["attending"] == true) {
        clickFlags["attending"] = false;
        attendeeOffset = 0;
        FirebaseFirestore.instance
            .collection("events")
            .doc(widget.eventID)
            .update({"eventAttendeesNumber": dbAttendeeNum - 1});
      } else {
        clickFlags["attending"] = true;
        attendeeOffset = 1;
        FirebaseFirestore.instance
            .collection("events")
            .doc(widget.eventID)
            .update({"eventAttendeesNumber": dbAttendeeNum + 1});
      }
    });
  }

  void deleteEvent() {
    firestore!.collection("events").doc(widget.eventID).delete();
    Navigator.of(context).popUntil(ModalRoute.withName("/events"));
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
    int currentAttendees = attendeeOffset + widget.eventAttendeesNumber;
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
              launch(widget.eventLink!);
            }
          },
          icon: const Icon(Icons.open_in_new))
    ];
    Widget eventOptions = Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 39, 53, 57)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: iconButtons,
        ));
    if (widget.readOnly == true) {
      eventOptions = const SizedBox(
        height: 0,
      );
    }
    List<Widget> appBarActions = _setActionButtons();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 0x24, 0x24, 0x24),
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
