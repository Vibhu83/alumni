import 'dart:math';

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

  void getPosts() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    var fireStoreInstance = FirebaseFirestore.instance;
    var postSummaries = fireStoreInstance.collection('postSummaries');
    var querySnapshot = await postSummaries.get();

    final allData = (querySnapshot.docs.map((doc) {
      Map value = doc.data();
      value["id"] = doc.id;
      return value;
    }));
    print(allData);
  }

  @override
  void initState() {
    getPosts();
    Random randomGenerator = Random();
    List<bool?> reactionArray = [true, false, null];
    for (int i = 0; i < 10; i++) {
      DateTime randomDate = DateTime.now().subtract(Duration(
          days: randomGenerator.nextInt(31),
          hours: randomGenerator.nextInt(24),
          minutes: randomGenerator.nextInt(60),
          seconds: randomGenerator.nextInt(60)));
      postSummariesData.add([
        "title" + i.toString(),
        "author" + i.toString(),
        randomGenerator.nextInt(3000),
        randomGenerator.nextInt(300),
        "Post Content " + i.toString(),
        randomDate,
        reactionArray[randomGenerator.nextInt(3)],
        reactionArray[randomGenerator.nextInt(3)]
      ]);
    }

    postSummariesData.add([
      "This is a really title to see how this will be shown in the post and comments page. This is still too I wish to make this larger.",
      "A random author with a very long name to see how the software handles very long author name",
      1233,
      211,
      "This is the post's content, this going to be really really long to see if it's working properly or not.\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.This is the post's content, this going to be really really long to see if it's working properly or not.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
      DateTime(2022, 1, 21, 03, 44),
      true,
      true
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: ListView.builder(
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
        ));
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
      required this.votes,
      required this.commentNumber,
      required this.postContent,
      required this.postTime,
      required this.reaction,
      required this.saveStatus});
}
