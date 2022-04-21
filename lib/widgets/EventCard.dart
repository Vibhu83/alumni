import 'package:alumni/widgets/ChangingIconButton.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class EventCard extends StatefulWidget {
  final int eventID;
  final String title;
  final String eventHolder;
  final DateTime startTime;
  final Duration eventDuration;
  final String? eventLink;
  const EventCard(
      {required this.eventID,
      required this.title,
      required this.eventHolder,
      required this.startTime,
      required this.eventDuration,
      this.eventLink,
      Key? key})
      : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

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

class _EventCardState extends State<EventCard> {
  String title =
      "This is my event title I wish to make it as long as possible to test my software and see how it handles very long titles";
  String eventHolder =
      "An Organisation which has an extremely long name, which will test how my software handles long organisational names";
  DateTime startTime = DateTime(2021, 01, 18, 10, 30);
  Duration eventDuration = const Duration(hours: 3);

  String? eventLink = "";

  Widget _getEventLink() {
    if (eventLink == null) {
      return const Text("");
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: "Open event\nlink",
                  style: const TextStyle(color: Colors.blue, fontSize: 10),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch("https://pub.dev/packages/url_launcher/install");
                    }),
              const WidgetSpan(
                  child: Padding(
                padding: EdgeInsets.only(left: 2.0, bottom: 2),
                child: Icon(
                  Icons.open_in_new,
                  size: 10,
                  color: Colors.blue,
                ),
              ))
            ]),
          ),
        ],
      );
    }
  }

  late List<Widget> eventAttributes = [];
  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ElevatedButton(
        onPressed: () {},
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          backgroundColor:
              MaterialStateProperty.all(const Color.fromARGB(255, 33, 44, 47)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: (MainAxisSize.min),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
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
                            "By: " + eventHolder,
                            style: GoogleFonts.lato(
                                fontSize: 11, color: Colors.grey.shade300),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Row(children: [
                            const Icon(
                              Icons.event_note_rounded,
                              size: 18,
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            SizedBox(
                              width: (screenwidth * .38),
                              child: Text(
                                  "On: " +
                                      formatDateTime(startTime) +
                                      " \nFor: " +
                                      eventDuration.inHours.toString() +
                                      " hours",
                                  style: GoogleFonts.lato(fontSize: 10)),
                            ),
                            _getEventLink(),
                          ])
                        ],
                      ),
                    ),
                  ),
                  const Placeholder(
                    fallbackHeight: 110,
                    fallbackWidth: 125,
                  )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                decoration:
                    const BoxDecoration(color: Color.fromARGB(255, 39, 53, 57)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ChangingIconButton(
                      orginalColor: Colors.blue,
                      onClickColor: Colors.red,
                      onPressed: () {},
                      icon: Icons.event_available,
                      changedIcon: Icons.event_busy,
                    ),
                    ChangingIconButton(
                      orginalColor: Colors.grey,
                      onClickColor: Colors.blue,
                      onPressed: () {},
                      icon: Icons.bookmark_add_rounded,
                      changedIcon: Icons.bookmark_added_rounded,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
