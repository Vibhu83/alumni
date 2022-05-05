import 'dart:async';

import 'package:alumni/globals.dart';
import 'package:alumni/widgets/post_card.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({Key? key}) : super(key: key);

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  List<Map<String, dynamic>> postsData = [];
  DocumentSnapshot? lastDoc;

  Future<List<Map<String, dynamic>>> getPosts() async {
    var postsRef = firestore!.collection('posts');
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    querySnapshot = await postsRef.get();
    //lastDoc = allDocSnap[allDocSnap.length - 1];
    final List<Map<String, dynamic>> allData = (querySnapshot.docs.map((doc) {
      Map<String, dynamic> value = doc.data();
      Timestamp temp = value["postedOn"];
      value["postedOn"] = temp.toDate();
      value["postID"] = doc.id;
      return value;
    }).toList());
    for (Map<String, dynamic> map in allData) {
      map["authorName"] = await getAuthorNameByID(map["postAuthorID"]);
      postsData.add(map);
    }
    return postsData;
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
                  itemCount: postsData.length,
                  itemBuilder: (BuildContext context, int index) {
                    print(postsData[index]);
                    String postID = postsData[index]["postID"];
                    String postTitle = postsData[index]["postTitle"];
                    String postAuthorID = postsData[index]["postAuthorID"];
                    String postAuthorName = postsData[index]["authorName"];
                    int postVotes = postsData[index]["postVotes"];
                    String postBody = postsData[index]["postBody"];
                    DateTime postedOn = postsData[index]["postedOn"];
                    return APostCard(
                        postID: postID,
                        postTitle: postTitle,
                        postAuthorID: postAuthorID,
                        postAuthorName: postAuthorName,
                        postVotes: postVotes,
                        postBody: postBody,
                        postedOn: postedOn);
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
            })));
  }
}
