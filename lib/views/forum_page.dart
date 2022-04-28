import 'dart:async';

import 'package:alumni/firebase_options.dart';
import 'package:alumni/widgets/PostWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<List> postSummariesData = [];
  var lastDoc = null;

  Future<List<List>> getPosts() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }
    var postSummaries = FirebaseFirestore.instance.collection('postSummaries');
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
      Timestamp temp = value["postTime"];
      value["postTime"] = temp.toDate();
      value["id"] = doc.id;
      return value;
    }).toList());
    for (Map<String, dynamic> map in allData) {
      postSummariesData.add([
        map["id"],
        map["title"],
        map["author"],
        map["votes"],
        map["commentNumber"],
        map["postContent"],
        map["postTime"],
        map["reaction"],
        map["saveStatus"]
      ]);
      print("data added");
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
                      postID: postSummariesData[index][0],
                      title: postSummariesData[index][1],
                      author: postSummariesData[index][2],
                      votes: postSummariesData[index][3],
                      commentNumber: postSummariesData[index][4],
                      postContent: postSummariesData[index][5],
                      postTime: postSummariesData[index][6],
                      reaction: postSummariesData[index][7],
                      saveStatus: postSummariesData[index][8],
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
