import 'package:alumni/globals.dart';
import 'package:alumni/widgets/event_card.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  final bool showBookmarkedEventsFlag;
  const EventsPage({this.showBookmarkedEventsFlag = false, Key? key})
      : super(key: key);

  Future<List<Map<String, dynamic>>> _getEvents() async {
    var eventData = firestore!.collection('events');
    var querySnapshot = await eventData
        .where("eventStartTime", isGreaterThanOrEqualTo: Timestamp.now())
        .get();
    //lastDoc = allDocSnap[allDocSnap.length - 1];
    final List<Map<String, dynamic>> allData = (querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      Timestamp temp = data["eventStartTime"];
      data["eventStartTime"] = temp.toDate();
      data["eventID"] = doc.id;
      data["eventDuration"] = data["eventDuration"];
      return data;
    }).toList());
    return allData;
  }

  Future<List<Map<String, dynamic>>> _getBookmarkedEvents() async {
    var eventData = firestore!.collection('events');
    var querySnapshot = await eventData
        .where("eventID", whereIn: userData["eventsBookmarked"])
        .get();

    List<Map<String, dynamic>> allData = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      Timestamp temp = data["eventStartTime"];
      data["eventStartTime"] = temp.toDate();
      return data;
    }).toList();
    return allData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: FutureBuilder(
            future: showBookmarkedEventsFlag == false
                ? _getEvents()
                : _getBookmarkedEvents(),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              late List<Widget> children;
              if (snapshot.hasData) {
                List<Map<String, dynamic>> eventData = snapshot.data!;
                return eventData.isEmpty
                    ? const Center(
                        child: Text("No events found"),
                      )
                    : ListView.builder(
                        itemCount: eventData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return AnEventCard(
                            eventTitleImage: eventData[index]
                                ["eventTitleImage"],
                            eventID: eventData[index]["eventID"],
                            eventTitle: eventData[index]["eventTitle"],
                            eventAttendeesNumber: eventData[index]
                                ["eventAttendeesNumber"],
                            eventHolder: eventData[index]["eventHolder"],
                            eventStartTime: eventData[index]["eventStartTime"],
                            eventDuration: eventData[index]["eventDuration"],
                            eventLink: eventData[index]["eventLink"],
                            readOnly: userData["id"] != null ? false : true,
                          );
                        },
                      );
              } else if (snapshot.hasError) {
                children = buildFutureError(snapshot);
              } else {
                children = buildFutureLoading(snapshot, text: "Loading events");
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              );
            }));
  }
}
