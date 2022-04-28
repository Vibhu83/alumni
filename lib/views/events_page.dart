import 'package:alumni/widgets/EventCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  List<List> eventSummariesData = [];
  var lastDoc = null;
  Future<List<List>> getPosts() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }
    var postSummaries = FirebaseFirestore.instance.collection('events');
    var querySnapshotFunction;
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    if (lastDoc == null) {
      querySnapshotFunction = postSummaries.limit(20).get;
    } else {
      querySnapshotFunction =
          postSummaries.startAfterDocument(lastDoc).limit(20).get;
    }
    querySnapshot = await querySnapshotFunction();
    var allDocSnap = querySnapshot.docs;
    lastDoc = allDocSnap[allDocSnap.length - 1];
    final List<Map<String, dynamic>> allData = (querySnapshot.docs.map((doc) {
      Map<String, dynamic> value = doc.data();
      Timestamp temp = value["startTime"];
      value["startTime"] = temp.toDate();
      value["id"] = doc.id;
      value["duration"] = Duration(hours: value["duration"]);
      return value;
    }).toList());
    for (Map<String, dynamic> map in allData) {
      eventSummariesData.add([
        map["id"],
        map["titleImage"],
        map["title"],
        map["attendees"],
        map["holder"],
        map["startTime"],
        map["duration"],
        map["link"],
      ]);
      print("data added");
    }
    return eventSummariesData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: FutureBuilder(
            future: getPosts(),
            builder: ((context, snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: eventSummariesData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Event(
                      eventID: eventSummariesData[index][0],
                      titleImage: eventSummariesData[index][1],
                      title: eventSummariesData[index][2],
                      attendeeNum: eventSummariesData[index][3],
                      eventHolder: eventSummariesData[index][4],
                      startTime: eventSummariesData[index][5],
                      eventDuration: eventSummariesData[index][6],
                      eventLink: eventSummariesData[index][7],
                    );
                  },
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
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Fetching events'),
                  )
                ];
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              );
            })));
  }
}
