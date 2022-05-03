import 'dart:async';

import 'package:alumni/globals.dart';
import 'package:alumni/widgets/PostWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<Map<String, dynamic>> postSummariesData = [];
  DocumentSnapshot? lastDoc;

  Future<List<Map<String, dynamic>>> getPosts() async {
    var postSummaries = firestore!.collection('postSummaries');
    var querySnapshotFunction;
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    if (lastDoc == null) {
      querySnapshotFunction = postSummaries.limit(20).get;
    } else {
      querySnapshotFunction =
          postSummaries.startAfterDocument(lastDoc!).limit(20).get;
    }
    querySnapshot = await querySnapshotFunction();
    var allDocSnap = querySnapshot.docs;
    lastDoc = allDocSnap[allDocSnap.length - 1];
    final List<Map<String, dynamic>> allData = (querySnapshot.docs.map((doc) {
      Map<String, dynamic> value = doc.data();
      Timestamp temp = value["postTime"];
      value["postTime"] = temp.toDate();
      value["id"] = doc.id;
      value["reaction"] = null;
      value["saved"] = null;
      return value;
    }).toList());
    for (Map<String, dynamic> map in allData) {
      postSummariesData.add(map);
    }
    return postSummariesData;
  }

  @override
  void initState() {
    super.initState();
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
                  itemCount: postSummariesData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Post(
                      currentAccessLevel: userData["type"],
                      currentUID: userData["uid"],
                      postID: postSummariesData[index]["id"],
                      title: postSummariesData[index]["title"],
                      authorId: postSummariesData[index]["authorId"],
                      authorName: postSummariesData[index]["authorName"],
                      votes: postSummariesData[index]["votes"],
                      commentNumber: postSummariesData[index]["commentNumber"],
                      postContent: postSummariesData[index]["postContent"],
                      postTime: postSummariesData[index]["postTime"],
                      reaction: postSummariesData[index]["reaction"],
                      saveStatus: postSummariesData[index]["saved"],
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
                    child: Text('Fetching posts'),
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
/*        Post(
            title: "title",
            author: "author",
            votes: 1644,
            commentNumber: 125,
            postContent: "content",
            postTime: DateTime(2022, 4, 14, 15, 24, 32),
            reaction: true,
            saveStatus: false),*/

class PostSummaryDetails {
  String id;
  String title;
  String author;
  int votes;
  int commentNumber;
  String postContent;
  Timestamp postTime;
  bool? reaction;
  bool? saveStatus;
  PostSummaryDetails(
      {required this.id,
      required this.title,
      required this.author,
      this.votes = 0,
      this.commentNumber = 0,
      required this.postContent,
      required this.postTime,
      this.reaction,
      this.saveStatus});
}
