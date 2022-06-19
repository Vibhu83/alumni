import 'package:alumni/classes/date_picker_theme.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/a_post_page.dart';
import 'package:alumni/views/an_event_page.dart';
import 'package:alumni/widgets/admin_recommendation_tile.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/filter_by_date.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class RecommendationPage extends StatefulWidget {
  final String uid;
  const RecommendationPage({required this.uid, Key? key}) : super(key: key);

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  late int? _filterType;
  final List<DateTime?> _selectedDates = [null, null];
  late final ScrollController _listScrollController;
  late Future<List<Map<String, dynamic>>> _futureNotificationsData;
  late List<Map<String, dynamic>> _notificationsData;
  late int _documentLoadLimit;
  late bool _allNotificationsLoaded;
  late DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    _filterType = null;
    _notificationsData = [];
    _documentLoadLimit = 5;
    _allNotificationsLoaded = false;
    _lastDocument = null;
    _listScrollController = ScrollController();
    _futureNotificationsData = _getNotifications();
    _listScrollController.addListener(() async {
      if (_listScrollController.position.maxScrollExtent ==
              _listScrollController.offset &&
          _allNotificationsLoaded != true) {
        List<Map<String, dynamic>> temp = _notificationsData;
        temp.addAll(await _getMoreNotifications());
        setState(() {
          _notificationsData = temp;
          _futureNotificationsData = Future.value(temp);
        });
      }
    });
    super.initState();
  }

  Future<List<Map<String, dynamic>>> _getNotifications() async {
    List<Map<String, dynamic>> notifications = [];
    Query<Map<String, dynamic>> query;

    switch (_filterType) {
      case 1:
        query = firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedTime",
                isLessThanOrEqualTo: Timestamp.fromDate(_selectedDates[0]!))
            .orderBy("recommendedTime", descending: true);

        break;
      case 2:
        query = firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedTime",
                isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDates[0]!),
                isLessThanOrEqualTo: Timestamp.fromDate(
                    _selectedDates[0]!.add(const Duration(days: 1))))
            .orderBy("recommendedTime", descending: true);
        break;
      case 3:
        query = firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedTime",
                isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDates[0]!))
            .orderBy("recommendedTime", descending: true);
        break;
      case 4:
        query = firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedTime",
                isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDates[0]!),
                isLessThanOrEqualTo: Timestamp.fromDate(_selectedDates[1]!))
            .orderBy("recommendedTime", descending: true);
        break;
      default:
        query = firestore!
            .collection("recommendationFromAdmins")
            .orderBy("recommendedTime", descending: true);
        break;
    }
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await query.limit(_documentLoadLimit).get();

    for (var element in querySnapshot.docs) {
      if (element.data().isNotEmpty) {
        var recommendationData = element.data();
        recommendationData["recommendationID"] = element.id;
        var temp = await _getTitle(recommendationData["recommendationType"],
            recommendationData["recommendedItemID"]);
        if (temp != null) {
          recommendationData.addAll(temp);
          notifications.add(recommendationData);
        }
      }
    }

    for (int i = 0; i < notifications.length; i++) {}
    setState(() {
      if (querySnapshot.docs.length < _documentLoadLimit) {
        _allNotificationsLoaded = true;
      }
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }
    });
    return notifications;
  }

  Future<List<Map<String, dynamic>>> _getMoreNotifications() async {
    List<Map<String, dynamic>> notifications;
    Query<Map<String, dynamic>> query;

    switch (_filterType) {
      case 1:
        query = firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedTime",
                isLessThanOrEqualTo: Timestamp.fromDate(_selectedDates[0]!))
            .orderBy("recommendedTime", descending: true);

        break;
      case 2:
        query = firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedTime",
                isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDates[0]!),
                isLessThanOrEqualTo: Timestamp.fromDate(
                    _selectedDates[0]!.add(const Duration(days: 1))))
            .orderBy("recommendedTime", descending: true);
        break;
      case 3:
        query = firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedTime",
                isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDates[0]!))
            .orderBy("recommendedTime", descending: true);
        break;
      case 4:
        query = firestore!
            .collection("recommendationFromAdmins")
            .where("recommendedTime",
                isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDates[0]!),
                isLessThanOrEqualTo: Timestamp.fromDate(_selectedDates[1]!))
            .orderBy("recommendedTime", descending: true);
        break;
      default:
        query = firestore!
            .collection("recommendationFromAdmins")
            .orderBy("recommendedTime", descending: true);
        break;
    }
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await query
        .startAfterDocument(_lastDocument!)
        .limit(_documentLoadLimit)
        .get();

    notifications = querySnapshot.docs.map((e) {
      var recommendationData = e.data();
      recommendationData["recommendationID"] = e.id;
      return recommendationData;
    }).toList();
    for (int i = 0; i < notifications.length; i++) {
      var temp = await _getTitle(notifications[i]["recommendationType"],
          notifications[i]["recommendedItemID"]);
      if (temp == null) {
        notifications[i].clear();
      } else {
        notifications[i].addAll(temp);
      }
    }
    notifications.removeWhere((element) => element.isEmpty);

    setState(() {
      if (querySnapshot.docs.length < _documentLoadLimit) {
        _allNotificationsLoaded = true;
      }
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }
    });
    return notifications;
  }

  Future<Map<String, dynamic>?> _getTitle(String type, String id) async {
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
      authorName = details["authorName"];
    } else {
      authorName = details["eventHolder"];
    }
    details["recommendationTitle"] =
        details[type + "Title"] + " By " + authorName;
    return details;
  }

  Future<void> _onRefresh() async {
    setState(() {
      _allNotificationsLoaded = false;
      _lastDocument = null;
      _notificationsData = [];
      _futureNotificationsData = Future.value([]);
    });
    List<Map<String, dynamic>> temp = await _getNotifications();
    setState(() {
      _notificationsData = temp;
      _futureNotificationsData = Future.value(temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(backgroundColor),
      appBar: buildAppBar(
          actions: [
            buildAppBarIcon(
                onPressed: () {
                  showModalBottomSheet(
                      elevation: 2,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        _filterType ??= 5;
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: FilterModalBottomSheet(
                            currentFilter: _filterType,
                          ),
                        );
                      }).then((value) {
                    if (value != null) {
                      bool changeWanted = true;
                      if (value == 5) {
                        setState(() {
                          _filterType = null;
                          _selectedDates[0] = null;
                          _selectedDates[1] = null;
                        });
                        return;
                      }
                      DatePicker.showDatePicker(
                        context,
                        currentTime: _selectedDates[0],
                        theme: Theme.of(context).brightness == Brightness.dark
                            ? getDarkDatePickerTheme()
                            : getLightPickerTheme(),
                      ).then((firstDate) async {
                        DateTime? nextFirstDate;
                        DateTime? nextSecondDate;
                        int? nextOrderType;

                        switch (value) {
                          case 1:
                            nextSecondDate = null;
                            nextFirstDate = firstDate;
                            if (firstDate == null) {
                              changeWanted = false;
                            } else {
                              nextOrderType = 1;
                            }
                            break;
                          case 2:
                            nextSecondDate = null;
                            nextFirstDate = firstDate;
                            if (firstDate == null) {
                              changeWanted = false;
                            } else {
                              nextOrderType = 2;
                            }
                            break;
                          case 3:
                            nextSecondDate = null;
                            nextFirstDate = firstDate;
                            if (firstDate == null) {
                              changeWanted = false;
                            } else {
                              nextOrderType = 3;
                            }
                            break;
                          case 4:
                            await DatePicker.showDatePicker(context,
                                    theme: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? getDarkDatePickerTheme()
                                        : getLightPickerTheme(),
                                    currentTime: _selectedDates[1])
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
                          case 5:
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
                            _filterType = nextOrderType;
                            _selectedDates[0] = nextFirstDate;
                            _selectedDates[1] = nextSecondDate;
                          });
                          _onRefresh();
                        } else {
                          return;
                        }
                      });
                    }
                  });
                },
                icon: Icons.filter_alt)
          ],
          leading: buildAppBarIcon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icons.close)),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: FutureBuilder(
            future: _futureNotificationsData,
            builder:
                ((context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                _notificationsData = snapshot.data!;
                return _notificationsData.isEmpty
                    ? const Center(
                        child: Text("No notifications found"),
                      )
                    : ListView.builder(
                        controller: _listScrollController,
                        itemCount: _notificationsData.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _notificationsData.length) {
                            return _allNotificationsLoaded == false
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 32),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : const SizedBox();
                          } else {}
                          void Function() onPressed = () {};
                          var item = _notificationsData[index];
                          if (item["recommendationType"] == "post") {
                            List<Image>? images = [];
                            List<String>? urls = [];
                            if (item["images"] != null) {
                              for (var url in item["images"]) {
                                urls.add(url.toString());
                                images.add(Image.network(url));
                              }
                            }
                            if (images.isEmpty) {
                              urls = null;
                              images = null;
                            }
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
                                  postVotes: item["postVotes"],
                                  authorName: item["authorName"],
                                  postBody: item["postBody"],
                                  postedDuration: printDuration(postedDuration),
                                  postLink: item["postLink"],
                                  images: images,
                                  imagesUrls: urls,
                                );
                              }));
                            };
                          } else {
                            onPressed = () {
                              var eventID = item["recommendedItemID"];
                              var eventTitle = item["eventTitle"];
                              var eventHolder = item["eventHolder"];
                              Timestamp temp = item["eventStartTime"];
                              DateTime eventStartTime = temp.toDate();
                              var eventDuration = item["eventDuration"];
                              Image? eventTitleImage;
                              if (item["eventTitleImage"] != null) {
                                eventTitleImage =
                                    Image.network(item["eventTitleImage"]);
                              }
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return AnEventPage(
                                    eventID: eventID,
                                    eventTitle: eventTitle,
                                    eventLink: item["eventLink"],
                                    eventTitleImage: eventTitleImage,
                                    eventTitleImagePath:
                                        item["eventTitleImage"],
                                    eventHolder: eventHolder,
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
      ),
    );
  }
}
