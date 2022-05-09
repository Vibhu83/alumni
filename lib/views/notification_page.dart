import 'package:alumni/ThemeData/dark_theme.dart';
import 'package:alumni/classes/dark_picker_theme.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/a_post_page.dart';
import 'package:alumni/views/an_event_page.dart';
import 'package:alumni/widgets/admin_recommendation_tile.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class NotificationPage extends StatefulWidget {
  final String uid;
  const NotificationPage({required this.uid, Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int? orderType;
  List<DateTime?> selectedDates = [null, null];

  Future<List<Map<String, dynamic>>> getNotificationList() async {
    List<Map<String, dynamic>> notifications;

    switch (orderType) {
      case 1:
        print("case1");
        notifications = await firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedTime",
                isLessThanOrEqualTo: Timestamp.fromDate(selectedDates[0]!))
            .orderBy("recommendedTime", descending: true)
            .get()
            .then((value) {
          return value.docs.map((e) {
            var recommendationData = e.data();
            recommendationData["recommendationID"] = e.id;
            return recommendationData;
          }).toList();
        });

        break;
      case 2:
        print("case2");
        notifications = await firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedTime",
                isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDates[0]!),
                isLessThanOrEqualTo: Timestamp.fromDate(
                    selectedDates[0]!.add(const Duration(days: 1))))
            .orderBy("recommendedTime", descending: true)
            .get()
            .then((value) {
          return value.docs.map((e) {
            var recommendationData = e.data();
            recommendationData["recommendationID"] = e.id;
            return recommendationData;
          }).toList();
        });
        break;
      case 3:
        print("case3");
        notifications = await firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedTime",
                isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDates[0]!))
            .orderBy("recommendedTime", descending: true)
            .get()
            .then((value) {
          return value.docs.map((e) {
            var recommendationData = e.data();
            recommendationData["recommendationID"] = e.id;
            return recommendationData;
          }).toList();
        });
        break;
      case 4:
        print("case4");
        notifications = await firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedTime",
                isGreaterThanOrEqualTo: Timestamp.fromDate(selectedDates[0]!),
                isLessThanOrEqualTo: Timestamp.fromDate(selectedDates[1]!))
            .orderBy("recommendedTime", descending: true)
            .get()
            .then((value) {
          return value.docs.map((e) {
            var recommendationData = e.data();
            recommendationData["recommendationID"] = e.id;
            return recommendationData;
          }).toList();
        });
        break;
      default:
        print("casedef");
        notifications = await firestore!
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
        break;
    }
    print("Before title");
    print(notifications);
    for (int i = 0; i < notifications.length; i++) {
      var temp = await getTitle(notifications[i]["recommendationType"],
          notifications[i]["recommendedItemID"]);
      if (temp == null) {
        notifications[i].clear();
      } else {
        notifications[i].addAll(temp);
      }
    }
    print("After Title");
    print(notifications);
    return notifications;
  }

  Future<Map<String, dynamic>?> getTitle(String type, String id) async {
    String itemType = type + "s";
    var details =
        await firestore!.collection(itemType).doc(id).get().then((value) {
      if (value.data() == null) {
        return null;
      } else {
        var data = value.data();
        return data;
      }
    });
    if (details == null) {
      return null;
    }
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

  @override
  Widget build(BuildContext context) {
    List<String> dropDownOptions = [
      "Before a date",
      "On a date",
      "After a date",
      "Between two dates",
      "Show all"
    ];
    return Scaffold(
      backgroundColor: const Color(backgroundColor),
      appBar: buildAppBar(
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: DropdownButton<String>(
                  icon: const Icon(Icons.sort),
                  underline: const SizedBox(),
                  style: const TextStyle(fontSize: 14),
                  items: dropDownOptions
                      .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                                child: Text(value),
                                value: value,
                              ))
                      .toList(),
                  onChanged: (String? selectedOrderType) {
                    bool changeWanted = true;
                    if (selectedOrderType == "Show all") {
                      setState(() {
                        orderType = null;
                        selectedDates[0] = null;
                        selectedDates[1] = null;
                      });
                      return;
                    }
                    DatePicker.showDatePicker(context,
                            currentTime: selectedDates[0],
                            theme: getDarkDatePickerTheme())
                        .then((firstDate) async {
                      DateTime? nextFirstDate;
                      DateTime? nextSecondDate;
                      int? nextOrderType;

                      switch (selectedOrderType) {
                        case "Before a date":
                          nextSecondDate = null;
                          nextFirstDate = firstDate;
                          if (firstDate == null) {
                            changeWanted = false;
                          } else {
                            nextOrderType = 1;
                          }
                          break;
                        case "On a date":
                          nextSecondDate = null;
                          nextFirstDate = firstDate;
                          if (firstDate == null) {
                            changeWanted = false;
                          } else {
                            nextOrderType = 2;
                          }
                          break;
                        case "After a date":
                          nextSecondDate = null;
                          nextFirstDate = firstDate;
                          if (firstDate == null) {
                            changeWanted = false;
                          } else {
                            nextOrderType = 3;
                          }
                          break;
                        case "Between two dates":
                          await DatePicker.showDatePicker(context,
                                  theme: getDarkDatePickerTheme(),
                                  currentTime: selectedDates[1])
                              .then((secondDate) {
                            if (firstDate == null || secondDate == null) {
                              changeWanted = false;
                            } else {
                              nextOrderType = 4;
                              nextFirstDate = firstDate;
                              nextSecondDate = secondDate;
                            }
                          });
                          break;
                        case "Show all":
                          nextOrderType = null;
                          nextFirstDate = null;
                          nextSecondDate = null;
                          break;
                        default:
                          changeWanted = false;
                          break;
                      }
                      if (changeWanted == true) {
                        setState(() {
                          orderType = nextOrderType;
                          selectedDates[0] = nextFirstDate;
                          selectedDates[1] = nextSecondDate;
                        });
                      } else {
                        return;
                      }
                    });
                  }),
            ),
          ],
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
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  if (list[index].isEmpty) {
                    return const SizedBox();
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
                            postID: item["recommendedItemID"],
                            postTitle: item["recommendationTitle"],
                            authorID: item["postAuthorID"],
                            authorName: item["authorName"],
                            postBody: item["postBody"],
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
                    content: item["recommendationMessage"],
                    recommendedTime: item["recommendedTime"],
                  );
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
