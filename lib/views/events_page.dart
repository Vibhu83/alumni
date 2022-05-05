import 'package:alumni/globals.dart';
import 'package:alumni/widgets/event_card.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late bool isNotLoggedIn;
  Future<List<Map<String, dynamic>>> getPosts() async {
    userData["id"] != null ? isNotLoggedIn = false : isNotLoggedIn = true;

    var eventData = firestore!.collection('events');
    var querySnapshot = await eventData.limit(20).get();
    //lastDoc = allDocSnap[allDocSnap.length - 1];
    final List<Map<String, dynamic>> allData = (querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      Timestamp temp = data["eventStartTime"];
      data["eventStartTime"] = temp.toDate();
      data["eventID"] = doc.id;
      data["eventDuration"] = Duration(hours: data["eventDuration"]);
      return data;
    }).toList());
    return allData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: FutureBuilder(
            future: getPosts(),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              late List<Widget> children;
              if (snapshot.hasData) {
                List<Map<String, dynamic>> eventData = snapshot.data!;
                return ListView.builder(
                  itemCount: eventData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AnEventCard(
                      eventID: eventData[index]["eventID"],
                      eventTitleImage: eventData[index]["eventTitleImage"],
                      eventTitle: eventData[index]["eventTitle"],
                      eventAttendeesNumber: eventData[index]
                          ["eventAttendeesNumber"],
                      eventHolder: eventData[index]["eventHolder"],
                      eventStartTime: eventData[index]["eventStartTime"],
                      eventDuration: eventData[index]["eventDuration"],
                      eventLink: eventData[index]["eventLink"],
                      readOnly: isNotLoggedIn,
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
