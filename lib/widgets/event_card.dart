import 'package:alumni/ThemeData/dark_theme.dart';
import 'package:alumni/globals.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../views/an_event_page.dart';

class AnEventCard extends StatefulWidget {
  final String eventID;
  final Image? eventTitleImage;
  final String eventTitle;
  final int eventAttendeesNumber;
  final String eventHolder;
  final DateTime eventStartTime;
  final Duration eventDuration;
  final String? eventLink;
  final bool readOnly;
  const AnEventCard(
      {required this.eventID,
      this.eventTitleImage,
      required this.eventTitle,
      required this.eventHolder,
      required this.eventAttendeesNumber,
      required this.eventStartTime,
      required this.eventDuration,
      this.readOnly = false,
      this.eventLink,
      Key? key})
      : super(key: key);

  @override
  State<AnEventCard> createState() => _AnEventCardState();
}

class _AnEventCardState extends State<AnEventCard> {
  late String title = widget.eventTitle;
  late String eventHolder = widget.eventHolder;
  late DateTime startTime = widget.eventStartTime;
  late int eventAttendees = widget.eventAttendeesNumber;

  String? eventLink = "https://pub.dev/packages/url_launcher/install";

  late List<Widget> eventAttributes = [];
  @override
  Widget build(BuildContext context) {
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
                    eventAttendees.toString(),
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
                  width: (screenWidth * .38),
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

    if (widget.eventTitleImage != null) {
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
                eventTitle: title,
                eventHolder: eventHolder,
                eventAttendeesNumber: eventAttendees,
                eventStartTime: startTime,
                eventDuration: widget.eventDuration);
          }))).then((value) {
            if (lastEventAttendeeChange != null &&
                lastEventAttendeeChange != 0) {
              print("changing values");
              setState(() {
                eventAttendees += lastEventAttendeeChange!;
              });
              changeAttendeeNumber(widget.eventID);
            }
          });
        },
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          backgroundColor:
              MaterialStateProperty.all(const Color(eventCardColor)),
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
