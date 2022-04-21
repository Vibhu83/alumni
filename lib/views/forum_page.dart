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
  List<PostSummaryDetails> data = [];
  var lastDoc = null;

  Future<List<List>> getPosts() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    }
    print("app initialised");
    var postSummaries = FirebaseFirestore.instance.collection('postSummaries');
    var querySnapshotFunction;
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    if (lastDoc == null) {
      querySnapshotFunction = postSummaries.get;
    } else {
      querySnapshotFunction = postSummaries.startAfterDocument(lastDoc).get;
    }
    querySnapshot = await querySnapshotFunction(null);

    print("Query snap taken");
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
                      postID: 0,
                      title: postSummariesData[index][0],
                      author: postSummariesData[index][1],
                      votes: postSummariesData[index][2],
                      commentNumber: postSummariesData[index][3],
                      postContent: postSummariesData[index][4],
                      postTime: postSummariesData[index][5],
                      reaction: postSummariesData[index][6],
                      saveStatus: postSummariesData[index][7],
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
