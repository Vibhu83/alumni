import 'package:alumni/globals.dart';
import 'package:alumni/widgets/event_card.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/notice_popup.dart';
import 'package:alumni/widgets/post_card.dart';
import 'package:alumni/widgets/top_alumni_cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _index;
  @override
  void initState() {
    _index = 0;
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      data["eventDuration"] = data["eventDuration"];
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
                  itemCount: eventData.length,
                  itemBuilder: (BuildContext context, int index) {
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
              itemCount: postsData.length,
              itemBuilder: (BuildContext context, int index) {
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
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context)
                      .appBarTheme
                      .shadowColor!
                      .withOpacity(0.3),
                  blurStyle: BlurStyle.normal,
                  spreadRadius: 0.1,
                  blurRadius: 0.5,
                  offset: const Offset(0, 1),
                )
              ],
              color: Theme.of(context).cardColor,
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context)
                          .appBarTheme
                          .shadowColor!
                          .withOpacity(0.3)))),
          child: DefaultTabController(
              initialIndex: _index,
              length: 3,
              child: TabBar(
                labelColor: Theme.of(context).appBarTheme.foregroundColor,
                onTap: (value) {
                  setState(() {
                    _index = value;
                  });
                },
                labelPadding: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                tabs: const [
                  Tab(
                    text: "Trending Posts",
                  ),
                  Tab(
                    text: "Upcoming Events",
                  ),
                  Tab(
                    text: "Top Alums",
                  ),
                ],
              )),
        ),
        SizedBox(
          height: screenHeight * 0.75,
          child: NestedScrollView(
              body: _tabViews.elementAt(_index),
              headerSliverBuilder: ((context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    stretchTriggerOffset: 1,
                    toolbarHeight: 1,
                    backgroundColor: Colors.transparent,
                    actions: const [SizedBox()],
                    expandedHeight: screenHeight * 0.19,
                    flexibleSpace: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: FlexibleSpaceBar(
                          background: Image.asset("assets/banner.jpg"),
                        ),
                      ),
                    ),
                  )
                ];
              })),
        ),
      ],
    );
  }
}
