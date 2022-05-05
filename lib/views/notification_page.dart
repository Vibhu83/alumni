import 'package:alumni/globals.dart';
import 'package:alumni/views/a_post_page.dart';
import 'package:alumni/views/an_event_page.dart';
import 'package:alumni/widgets/admin_recommendation_tile.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  final String uid;
  const NotificationPage({required this.uid, Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

Future<List<Map<String, dynamic>>> getNotificationList() async {
  List<Map<String, dynamic>> detailList = [];
  var data = await firestore!
      .collection("recommendationFromAdmins")
      .orderBy("recommendedTime", descending: true)
      .get()
      .then((value) {
    return value.docs.map((e) {
      var recommendationData = e.data();
      recommendationData["recommendationID"] = e.id;
      return recommendationData;
    }).toList();
  });
  print("before title");
  print(data);
  for (Map recommendationData in data) {
    var temp = await getTitle(recommendationData["recommendationType"],
        recommendationData["recommendedItemID"]);
    recommendationData.addAll(temp);
  }
  return data;
}

Future<Map<String, dynamic>> getTitle(String type, String id) async {
  print(firestore);
  String itemType = type + "s";
  print(itemType);
  print(id);
  var details =
      await firestore!.collection(itemType).doc(id).get().then((value) async {
    var data = value.data()!;
    return data;
  });
  String authorName;
  if (type == "post") {
    String authorID = details["postAuthorID"];
    authorName = await getAuthorNameByID(authorID);
    details["authorName"] = authorName;
  } else {
    authorName = details["eventHolder"];
  }
  details["recommendationTitle"] =
      details[type + "Title"] + " By " + authorName;
  return details;
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0x24, 0x24, 0x24),
      appBar: buildAppBar(
          leading: buildAppBarIcon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icons.close)),
      body: FutureBuilder(
          future: getNotificationList(),
          builder:
              ((context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              var list = snapshot.data!;
              print("Data:");
              print(snapshot.data);
              print("User:");
              print(userData);
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  bool readOnly = true;
                  if (userData["uid"] != null) {
                    readOnly = false;
                  }
                  void Function() onPressed = () {};
                  var item = list[index];
                  if (item["recommendationType"] == "post") {
                    onPressed = () {
                      Timestamp temp = item["postedOn"];
                      var postedDuration =
                          temp.toDate().difference(DateTime.now());
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return APost(
                            readOnly: readOnly,
                            postID: item["recommendedItemID"],
                            title: item["recommendationTitle"],
                            authorId: item["postAuthorID"],
                            authorName: item["authorName"],
                            votes: item["postVotes"],
                            postContent: item["postBody"],
                            postedDuration: printDuration(postedDuration));
                      }));
                    };
                  } else {
                    onPressed = () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        var eventID = item["recommendedItemID"];
                        var eventTitle = item["eventTitle"];
                        var eventHolder = item["eventHolder"];
                        int eventAttendeesNumber = item["eventAttendeesNumber"];
                        Timestamp temp = item["eventStartTime"];
                        DateTime eventStartTime = temp.toDate();
                        var eventDuration =
                            Duration(hours: item["eventDuration"]);
                        return AnEventPage(
                            eventID: eventID,
                            eventTitle: eventTitle,
                            eventHolder: eventHolder,
                            eventAttendeesNumber: eventAttendeesNumber,
                            eventStartTime: eventStartTime,
                            eventDuration: eventDuration);
                      }));
                    };
                  }
                  return AdminRecommendationListTile(
                      recommendationId: item["recommendationID"],
                      recommendationType: item["recommendationType"],
                      onPressed: onPressed,
                      recommendedItemTitle: item["recommendationTitle"],
                      content: item["recommendationMessage"]);
                },
              );
            } else if (snapshot.hasError) {
              children = buildFutureError(snapshot);
            } else {
              children = buildFutureLoading(snapshot);
            }
            return buildFuture(children: children);
          })),
    );
  }
}
