import 'package:alumni/globals.dart';
import 'package:alumni/widgets/event_card.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/notice_popup.dart';
import 'package:alumni/widgets/post_card.dart';
import 'package:alumni/widgets/top_alumni_cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final int selectedTab;
  const HomePage({required this.selectedTab, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool isInitialBuild;
  Widget? noticeWidget;
  @override
  void initState() {
    isInitialBuild = true;
    noticeWidget = const SizedBox();
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (noticesSeen == false) {
        noticesSeen = true;
        showDialog(
            context: context,
            builder: ((context) {
              return const Notices();
            }));
      }
    });
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    var eventData = firestore!.collection('events');
    var querySnapshot = await eventData
        .where("eventStartTime", isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy("eventStartTime", descending: true)
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

  Widget _buildUpcomingEventsPage() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: FutureBuilder(
            future: getEvents(),
            builder:
                (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              late List<Widget> children;
              if (snapshot.hasData) {
                List<Map<String, dynamic>> eventData = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: eventData.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == eventData.length) {
                      return TextButton(
                          onPressed: () {}, child: const Text("See more"));
                    }
                    return AnEventCard(
                      eventTitleImage: eventData[index]["eventTitleImage"],
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

  Future<List<Map<String, dynamic>>> getPosts() async {
    var postsRef = firestore!.collection('posts');
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    querySnapshot =
        await postsRef.orderBy("rating", descending: true).limit(10).get();
    //lastDoc = allDocSnap[allDocSnap.length - 1];
    final List<Map<String, dynamic>> allData = (querySnapshot.docs.map((doc) {
      Map<String, dynamic> value = doc.data();
      Timestamp temp = value["postedOn"];
      value["postedOn"] = temp.toDate();
      value["postID"] = doc.id;
      return value;
    }).toList());

    for (int i = 0; i < allData.length; i++) {
      allData[i]["authorName"] =
          await getAuthorNameByID(allData[i]["postAuthorID"]);
    }
    return allData;
  }

  Widget _buildTrendingPostsPage() {
    return FutureBuilder(
        future: getPosts(),
        builder:
            ((context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            var postsData = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: postsData.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == postsData.length) {
                  return TextButton(
                      onPressed: () {}, child: const Text("See more"));
                }
                String postID = postsData[index]["postID"];
                String postTitle = postsData[index]["postTitle"];
                String postAuthorID = postsData[index]["postAuthorID"];
                String postAuthorName = postsData[index]["authorName"];
                int postVotes = postsData[index]["postVotes"];
                String postBody = postsData[index]["postBody"];
                DateTime postedOn = postsData[index]["postedOn"];
                List<String>? images;
                if (postsData[index]["images"] != null) {
                  images = [];
                  postsData[index]["images"].forEach((value) {
                    images!.add(value.toString());
                  });
                }
                String? link = postsData[index]["postLink"];

                return APostCard(
                  postID: postID,
                  postTitle: postTitle,
                  postAuthorID: postAuthorID,
                  postAuthorName: postAuthorName,
                  postVotes: postVotes,
                  postBody: postBody,
                  postedOn: postedOn,
                  imagesUrls: images,
                  postLink: link,
                );
              },
            );
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot, text: "Loading Posts");
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        }));
  }

  late final List<Widget> _tabViews = [
    _buildTrendingPostsPage(),
    _buildUpcomingEventsPage(),
    const TopAlumniCards(),
  ];

  @override
  Widget build(BuildContext context) {
    int currentTab =
        currentHomeTab == null ? widget.selectedTab : currentHomeTab!;
    return _tabViews[currentTab];
  }
}
