import 'package:alumni/firebase_options.dart';
import 'package:alumni/widgets/ChangingIconButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AnEventPage extends StatelessWidget {
  final String eventID;
  final Image? titleImage;
  final String title;
  final int attendeeNum;
  final String eventHolder;
  final DateTime startTime;
  final Duration eventDuration;
  final String? eventLink;
  const AnEventPage(
      {required this.eventID,
      this.titleImage,
      required this.title,
      required this.eventHolder,
      required this.attendeeNum,
      required this.startTime,
      required this.eventDuration,
      this.eventLink,
      Key? key})
      : super(key: key);

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
                    attendeeNum.toString(),
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
                          eventDuration.inHours.toString() +
                          " hours",
                      style: GoogleFonts.lato(fontSize: 10)),
                ),
              ])
            ],
          ),
        ),
      ),
    ];

    if (titleImage != null) {
      firstRowChildren.add(const Placeholder(
        fallbackHeight: 110,
        fallbackWidth: 125,
      ));
    }
    List<Widget> iconButtons = [
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
      ),
      IconButton(
          onPressed: () {
            if (eventLink != null) {
              launch(eventLink!);
            }
          },
          icon: const Icon(Icons.open_in_new))
    ];
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              Container(
                decoration:
                    const BoxDecoration(color: Color.fromARGB(255, 39, 53, 57)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: iconButtons,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
