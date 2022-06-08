import 'dart:async';

import 'package:alumni/globals.dart';
import 'package:alumni/widgets/post_card.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  final bool showBookmarkedPostsFlag;
  const ForumPage({this.showBookmarkedPostsFlag = false, Key? key})
      : super(key: key);

  Future<List<Map<String, dynamic>>> _getPosts() async {
    var postsRef = firestore!.collection('posts');
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    querySnapshot = await postsRef.orderBy("rating", descending: true).get();
    //lastDoc = allDocSnap[allDocSnap.length - 1];
    final List<Map<String, dynamic>> allData = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> value = doc.data();
      Timestamp temp = value["postedOn"];
      value["postedOn"] = temp.toDate();
      if (addedPostData != null &&
          addedPostData!["postID"] == value["postID"]) {
        allData.insert(0, value);
        addedPostData = null;
        continue;
      }
      allData.add(value);
    }

    for (int i = 0; i < allData.length; i++) {
      allData[i]["authorName"] =
          await getAuthorNameByID(allData[i]["postAuthorID"]);
    }

    return allData;
  }

  Future<List<Map<String, dynamic>>> _getBookmarkedPosts() async {
    var allData = await firestore!
        .collection("posts")
        .where("postID", whereIn: userData["postsBookmarked"])
        .get()
        .then((value) {
      return value.docs.map((doc) {
        Map<String, dynamic> value = doc.data();
        Timestamp temp = value["postedOn"];
        value["postedOn"] = temp.toDate();
        return value;
      }).toList();
    });
    for (int i = 0; i < allData.length; i++) {
      allData[i]["authorName"] =
          await getAuthorNameByID(allData[i]["postAuthorID"]);
    }
    return allData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: showBookmarkedPostsFlag == false
            ? _getPosts()
            : _getBookmarkedPosts(),
        builder:
            ((context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            var postsData = snapshot.data!;
            return postsData.isEmpty
                ? const Center(
                    child: Text("No posts found"),
                  )
                : ListView.builder(
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
}
