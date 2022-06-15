import 'package:alumni/globals.dart';
import 'package:alumni/widgets/event_card.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatefulWidget {
  final bool showOnlyBookmarked;
  final bool showOnlyPastEvents;
  const EventsPage(
      {this.showOnlyBookmarked = false,
      this.showOnlyPastEvents = false,
      Key? key})
      : super(key: key);
  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late final ScrollController _listScrollController;
  late DocumentSnapshot? _lastDocument;
  late List<Map<String, dynamic>> _eventsData;
  late int _documentLoadLimit;
  late bool _allEventsLoaded;
  late Future<List<Map<String, dynamic>>> _futureEventsData;
  late int _bookmarkIndex;
  @override
  void initState() {
    _bookmarkIndex = 0;
    _lastDocument = null;
    _allEventsLoaded = false;
    _documentLoadLimit = 10;
    _listScrollController = ScrollController();
    _listScrollController.addListener(() async {
      if (_listScrollController.position.maxScrollExtent ==
              _listScrollController.offset &&
          _allEventsLoaded == false) {
        List<Map<String, dynamic>> temp = _eventsData;
        temp.addAll(await _getMoreEvents());
        setState(() {
          _eventsData = temp;
          _futureEventsData = Future.value(temp);
        });
      }
    });
    _eventsData = [];
    _futureEventsData = _getEvents();

    super.initState();
  }

  Future<List<Map<String, dynamic>>> _getMoreEvents({int delayTime = 0}) async {
    Query<Map<String, dynamic>> query;
    int? newBookmarkIndex;

    if (widget.showOnlyBookmarked) {
      List bookmarks = userData["eventsBookmarked"];
      int end = bookmarks.length;

      if (bookmarks.length > (_bookmarkIndex + 10)) {
        end = _bookmarkIndex + 10;
      }
      newBookmarkIndex = end;
      bookmarks = bookmarks.getRange(_bookmarkIndex, end).toList();
      query =
          firestore!.collection("events").where("eventID", whereIn: bookmarks);
    } else if (widget.showOnlyPastEvents) {
      query = firestore!
          .collection("events")
          .orderBy("eventStartTime", descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_documentLoadLimit);
    } else {
      query = firestore!
          .collection("events")
          .orderBy("eventStartTime")
          .startAfterDocument(_lastDocument!)
          .limit(_documentLoadLimit);
    }

    QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
    final List<Map<String, dynamic>> eventsData =
        (querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      Timestamp temp = data["eventStartTime"];
      data["startTimestamp"] = temp;
      data["eventStartTime"] = temp.toDate();
      return data;
    }).toList());
    setState(() {
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }
      if (newBookmarkIndex != null) {
        if (newBookmarkIndex < (_bookmarkIndex + 10)) {
          _allEventsLoaded = true;
        }
        _bookmarkIndex = newBookmarkIndex;
      }
    });
    if (eventsData.length < _documentLoadLimit &&
        widget.showOnlyBookmarked == false) {
      _allEventsLoaded = true;
    }
    await Future.delayed(Duration(seconds: delayTime));
    return eventsData;
  }

  Future<List<Map<String, dynamic>>> _getEvents({int delayTime = 0}) async {
    Query<Map<String, dynamic>> query;
    int? newBookmarkIndex;
    if (widget.showOnlyBookmarked) {
      List bookmarks = userData["eventsBookmarked"];
      int end = 10;
      if (bookmarks.length < 10) {
        end = bookmarks.length;
      }
      newBookmarkIndex = end;
      bookmarks = bookmarks.getRange(_bookmarkIndex, end).toList();
      query = firestore!
          .collection("events")
          .where("eventID", whereIn: bookmarks)
          .limit(_documentLoadLimit);
    } else if (widget.showOnlyPastEvents) {
      query = firestore!
          .collection("events")
          .where("eventStartTime", isLessThan: Timestamp.now())
          .orderBy("eventStartTime", descending: true)
          .limit(_documentLoadLimit);
    } else {
      query = firestore!
          .collection("events")
          .where("eventStartTime", isGreaterThanOrEqualTo: Timestamp.now())
          .limit(_documentLoadLimit);
    }
    var querySnapshot = await query.get();
    final List<Map<String, dynamic>> eventsData =
        (querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      Timestamp temp = data["eventStartTime"];
      data["startTimestamp"] = temp;
      data["eventStartTime"] = temp.toDate();
      return data;
    }).toList());

    setState(() {
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }
      if (eventsData.length < _documentLoadLimit &&
          widget.showOnlyBookmarked == false) {
        _allEventsLoaded = true;
      }
      if (newBookmarkIndex != null) {
        setState(() {
          _bookmarkIndex = newBookmarkIndex!;
          if (newBookmarkIndex < 10) {
            _allEventsLoaded = true;
          }
        });
      }
    });

    await Future.delayed(Duration(seconds: delayTime));
    return eventsData;
  }

  Future<void> _onRefresh() async {
    setState(() {
      _lastDocument = null;
      _bookmarkIndex = 0;
      _allEventsLoaded = false;
      _eventsData = [];
      _futureEventsData = Future.value([]);
    });
    List<Map<String, dynamic>> temp = await _getEvents();
    setState(() {
      _eventsData = temp;
      _futureEventsData = Future.value(temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder(
          future: _futureEventsData,
          builder:
              (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            late List<Widget> children = [];
            if (snapshot.hasData) {
              _eventsData = snapshot.data!;
              return _buildEventsList();
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
          }),
    );
  }

  Widget _buildEventsList() {
    return _eventsData.isEmpty
        ? const Center(
            child: Text("No events found"),
          )
        : ListView.builder(
            controller: _listScrollController,
            itemCount: _eventsData.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == _eventsData.length) {
                return _allEventsLoaded == false
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox();
              }
              return AnEventCard(
                eventTitleImage: _eventsData[index]["eventTitleImage"],
                eventID: _eventsData[index]["eventID"],
                eventTitle: _eventsData[index]["eventTitle"],
                eventAttendeesNumber: _eventsData[index]
                    ["eventAttendeesNumber"],
                eventHolder: _eventsData[index]["eventHolder"],
                eventStartTime: _eventsData[index]["eventStartTime"],
                eventDuration: _eventsData[index]["eventDuration"],
                eventLink: _eventsData[index]["eventLink"],
                readOnly: userData["uid"] != null ? false : true,
              );
            },
          );
  }
}
