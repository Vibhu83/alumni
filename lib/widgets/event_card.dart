// import 'package:alumni/ThemeData/dark_theme.dart';
import 'package:alumni/globals.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../views/an_event_page.dart';

class AnEventCard extends StatefulWidget {
  final String eventID;
  final String? eventTitleImage;
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
              SizedBox(
                height: screenHeight * 0.0025,
              ),
              Text(
                "By: " + eventHolder,
                style: GoogleFonts.lato(
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              SizedBox(
                height: screenHeight * 0.0075,
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
                        fontSize: 14,
                        color: Theme.of(context)
                            .appBarTheme
                            .shadowColor!
                            .withOpacity(0.9)),
                  )
                ],
              ),
              SizedBox(
                height: screenHeight * 0.005,
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
    Image? titleImage;
    if (widget.eventTitleImage != null) {
      titleImage = Image.network(widget.eventTitleImage!);
      firstRowChildren.add(Container(
        height: screenHeight * 0.110,
        width: screenWidth * 0.3,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: titleImage.image, fit: BoxFit.fitHeight)),
      ));
    }

    return Container(
      margin: const EdgeInsets.only(right: 4, left: 4, top: 4, bottom: 5),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
            return AnEventPage(
                eventTitleImagePath: widget.eventTitleImage,
                eventTitleImage: titleImage,
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
              lastEventAttendeeChange = null;
              lastEventBool = null;
            }
          });
        },
        child: Card(
          shadowColor:
              Theme.of(context).appBarTheme.shadowColor!.withOpacity(0.3),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
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
                SizedBox(
                  height: screenHeight * 0.01,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
