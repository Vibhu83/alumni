import 'package:alumni/globals.dart';
import 'package:alumni/widgets/event_card.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrendingEventsPage extends StatelessWidget {
  const TrendingEventsPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _getEvents() async {
    var eventData = firestore!.collection('events');
    var querySnapshot = await eventData
        .where("eventStartTime", isGreaterThanOrEqualTo: Timestamp.now())
        .limit(10)
        .get();
    //lastDoc = allDocSnap[allDocSnap.length - 1];
    final List<Map<String, dynamic>> allData = (querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      Timestamp temp = data["eventStartTime"];
      data["eventStartTime"] = temp.toDate();
      data["eventID"] = doc.id;
      data["eventDuration"] = Duration(hours: data["eventDuration"]);
      return data;
    }).toList());

    if (allData.isNotEmpty) {
      allData.sort((a, b) {
        Timestamp aPostedOn = a["eventAttendeesNumber"];
        Timestamp bPostedOn = b["eventAttendeesNumber"];
        return bPostedOn.compareTo(aPostedOn);
      });
    }
    return allData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: FutureBuilder(
            future: _getEvents(),
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
                        shrinkWrap: true,
                        itemCount: eventData.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == eventData.length) {
                            return TextButton(
                                onPressed: () {},
                                child: const Text("See more"));
                          }
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
