import 'package:alumni/globals.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:alumni/widgets/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrendingPostsPage extends StatelessWidget {
  const TrendingPostsPage({Key? key}) : super(key: key);

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
      print(allData[i]);
      allData[i]["authorName"] =
          await getAuthorNameByID(allData[i]["postAuthorID"]);
    }
    return allData;
  }

  @override
  Widget build(BuildContext context) {
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
                  return TextButton(onPressed: () {}, child: Text("See more"));
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
}
