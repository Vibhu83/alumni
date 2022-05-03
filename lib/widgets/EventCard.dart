import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../views/an_event_page.dart';

class Event extends StatefulWidget {
  final String eventID;
  final Image? titleImage;
  final String title;
  final int attendeeNum;
  final String eventHolder;
  final DateTime startTime;
  final Duration eventDuration;
  final String? eventLink;
  final bool readOnly;
  const Event(
      {required this.eventID,
      this.titleImage,
      required this.title,
      required this.eventHolder,
      required this.attendeeNum,
      required this.startTime,
      required this.eventDuration,
      this.readOnly = false,
      this.eventLink,
      Key? key})
      : super(key: key);

  @override
  State<Event> createState() => _EventState();
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

class _EventState extends State<Event> {
  late String title = widget.title;
  late String eventHolder = widget.eventHolder;
  late DateTime startTime = widget.startTime;
  late Map<String, bool> clickFlags;

  String? eventLink = "https://pub.dev/packages/url_launcher/install";

  late List<Widget> eventAttributes = [];
  @override
  Widget build(BuildContext context) {
    double screenwidth = MediaQuery.of(context).size.width;
    List<Widget> firstRowChildren = [
      Flexible(
        child: Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
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
                "By: " + eventHolder,
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
                    widget.attendeeNum.toString(),
                    style: GoogleFonts.lato(
                        fontSize: 14, fontWeight: FontWeight.bold),
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
                  width: (screenwidth * .38),
                  child: Text(
                      "On: " +
                          formatDateTime(startTime) +
                          " \nFor: " +
                          widget.eventDuration.inHours.toString() +
                          " hours",
                      style: GoogleFonts.lato(fontSize: 10)),
                ),
              ])
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
            return AnEventPage(
              eventID: widget.eventID,
              title: title,
              eventHolder: eventHolder,
              attendeeNum: widget.attendeeNum,
              startTime: startTime,
              eventDuration: widget.eventDuration,
              readOnly: widget.readOnly,
            );
          })));
        },
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
                children: firstRowChildren,
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
