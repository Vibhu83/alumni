import 'package:alumni/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AnEventPage extends StatefulWidget {
  final String eventID;
  final Image? titleImage;
  final String title;
  final int attendeeNum;
  final String eventHolder;
  final DateTime startTime;
  final Duration eventDuration;
  final String? eventLink;
  final bool readOnly;
  const AnEventPage(
      {required this.eventID,
      this.titleImage,
      required this.title,
      required this.eventHolder,
      required this.attendeeNum,
      required this.startTime,
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

  Future<FirebaseApp> initialiseApp() async {
    if (Firebase.apps.isEmpty) {
      var temp = await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform)
          .then((value) => value);
      return temp;
    } else {
      return Firebase.apps[Firebase.apps.length - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double appBarHeight = screenHeight * 0.045;
    return FutureBuilder(
      future: initialiseApp(),
      builder: (context, AsyncSnapshot<FirebaseApp> snapshot) {
        List<Widget> children = [];
        if (snapshot.hasData) {
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
          int currentAttendees = attendeeOffset + widget.attendeeNum;

          List<Widget> firstRowChildren = [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.lato(
                          fontSize: 18,
                          height: 1.3,
                          fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: false,
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(
                      "By: " + widget.eventHolder,
                      style: GoogleFonts.lato(
                          fontSize: 11, color: Colors.grey.shade300),
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
                                formatDateTime(widget.startTime) +
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

          if (widget.titleImage != null) {
            firstRowChildren.add(const Placeholder(
              fallbackHeight: 110,
              fallbackWidth: 125,
            ));
          }
          List<Widget> iconButtons = [
            IconButton(
                splashRadius: 1,
                onPressed: () async {
                  currentAttendees = widget.attendeeNum + attendeeOffset;
                  var doc = await FirebaseFirestore.instance
                      .collection("events")
                      .doc(widget.eventID)
                      .get()
                      .then((value) => value);
                  int dbAttendeeNum = doc.data()?["attendees"];
                  setState(() {
                    if (clickFlags["attending"] == true) {
                      clickFlags["attending"] = false;
                      FirebaseFirestore.instance
                          .collection("events")
                          .doc(widget.eventID)
                          .update({"attendees": dbAttendeeNum - 1});
                    } else {
                      clickFlags["attending"] = true;
                      FirebaseFirestore.instance
                          .collection("events")
                          .doc(widget.eventID)
                          .update({"attendees": dbAttendeeNum + 1});
                    }
                  });
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
              decoration:
                  const BoxDecoration(color: Color.fromARGB(255, 39, 53, 57)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: iconButtons,
              ));
          if (widget.readOnly == true) {
            eventOptions = SizedBox(
              height: 0,
            );
          }
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 0x24, 0x24, 0x24),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(appBarHeight),
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.grey.shade800))),
                child: AppBar(
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(8))),
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
              ),
            ),
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
                                height: screenHeight - 291,
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
}
