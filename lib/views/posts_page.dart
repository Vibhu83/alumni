import 'dart:async';

import 'package:alumni/globals.dart';
import 'package:alumni/widgets/post_card.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PostsPage extends StatefulWidget {
  final bool showOnlyBookmarked;
  const PostsPage({this.showOnlyBookmarked = false, Key? key})
      : super(key: key);

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late final ScrollController _listScrollController;
  late Future<List<Map<String, dynamic>>> _futurePostsData;
  late List<Map<String, dynamic>> _postsData;
  late int _documentLoadLimit;
  late bool _allPostsLoaded;
  late DocumentSnapshot? _lastDocument;
  late int _bookmarkIndex;

  @override
  void initState() {
    _bookmarkIndex = 0;
    _lastDocument = null;
    _allPostsLoaded = false;
    _documentLoadLimit = 10;
    _listScrollController = ScrollController();

    _listScrollController.addListener(() async {
      if (_listScrollController.position.maxScrollExtent ==
              _listScrollController.offset &&
          _allPostsLoaded != true) {
        List<Map<String, dynamic>> temp = _postsData;
        temp.addAll(await _getMorePosts());
        setState(() {
          _postsData = temp;
          _futurePostsData = Future.value(temp);
        });
      }
    });
    _postsData = [];
    _futurePostsData = _getPosts();

    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _getMorePosts({int delayTime = 0}) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    int? newBookmarkIndex;

    if (widget.showOnlyBookmarked) {
      List bookmarks = userData["postsBookmarked"];
      int end = bookmarks.length;

      if (bookmarks.length > (_bookmarkIndex + _documentLoadLimit)) {
        end = _bookmarkIndex + _documentLoadLimit;
      }
      newBookmarkIndex = end;
      bookmarks = bookmarks.getRange(_bookmarkIndex, end).toList();
      querySnapshot = await firestore!
          .collection("posts")
          .where("postID", whereIn: bookmarks)
          .get();
    } else {
      querySnapshot = await firestore!
          .collection("posts")
          .orderBy("rating", descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_documentLoadLimit)
          .get();
    }
    final List<Map<String, dynamic>> postsData = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> value = doc.data();
      Timestamp temp = value["postedOn"];
      value["postedOn"] = temp.toDate();
      if (addedPostData != null &&
          addedPostData!["postID"] == value["postID"]) {
        postsData.insert(0, value);
        addedPostData = null;
        continue;
      }
      postsData.add(value);
    }

    setState(() {
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }
      if (newBookmarkIndex != null) {
        if (newBookmarkIndex < (_bookmarkIndex + _documentLoadLimit)) {
          _allPostsLoaded = true;
        }
        _bookmarkIndex = newBookmarkIndex;
      }
      if (querySnapshot.docs.length < _documentLoadLimit &&
          widget.showOnlyBookmarked == false) {
        _allPostsLoaded = true;
      }
    });
    await Future.delayed(Duration(seconds: delayTime));
    return postsData;
  }

  Future<List<Map<String, dynamic>>> _getPosts({int delayTime = 0}) async {
    Query<Map<String, dynamic>> query;
    int? newBookmarkIndex;
    if (widget.showOnlyBookmarked) {
      List bookmarks = userData["postsBookmarked"];
      int end = _documentLoadLimit;
      if (bookmarks.length < _documentLoadLimit) {
        end = bookmarks.length;
      }
      newBookmarkIndex = end;
      bookmarks = bookmarks.getRange(_bookmarkIndex, end).toList();
      query =
          firestore!.collection("posts").where("postID", whereIn: bookmarks);
    } else {
      query = firestore!
          .collection("posts")
          .orderBy("rating", descending: true)
          .limit(_documentLoadLimit);
    }
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
    final List<Map<String, dynamic>> postsData = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> value = doc.data();
      Timestamp temp = value["postedOn"];
      value["postedOn"] = temp.toDate();
      if (addedPostData != null &&
          addedPostData!["postID"] == value["postID"]) {
        postsData.insert(0, value);
        addedPostData = null;
        continue;
      }
      postsData.add(value);
    }

    setState(() {
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
      }
      if (querySnapshot.docs.length < _documentLoadLimit &&
          widget.showOnlyBookmarked == false) {
        _allPostsLoaded = true;
      }
      if (newBookmarkIndex != null) {
        setState(() {
          _bookmarkIndex = newBookmarkIndex!;
          if (newBookmarkIndex < _documentLoadLimit) {
            _allPostsLoaded = true;
          }
        });
      }
    });
    await Future.delayed(Duration(seconds: delayTime));
    return postsData;
  }

  Future<void> _onRefresh() async {
    setState(() {
      _lastDocument = null;
      _bookmarkIndex = 0;
      _allPostsLoaded = false;
      _postsData = [];
      _futurePostsData = Future.value([]);
    });
    List<Map<String, dynamic>> temp = await _getPosts();
    setState(() {
      _postsData = temp;
      _futurePostsData = Future.value(temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futurePostsData,
          builder:
              ((context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              _postsData = snapshot.data!;
              return _buildPosts();
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
          })),
    );
  }

  Widget _buildPosts() {
    return _postsData.isEmpty
        ? const Center(
            child: Text("No posts found"),
          )
        : ListView.builder(
            controller: _listScrollController,
            itemCount: _postsData.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == _postsData.length) {
                return _allPostsLoaded == false
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : const SizedBox();
              }

              String postID = _postsData[index]["postID"];
              String postTitle = _postsData[index]["postTitle"];
              String? postAuthorID = _postsData[index]["postAuthorID"];
              String postAuthorName = _postsData[index]["authorName"];
              int postVotes = _postsData[index]["postVotes"];
              String postBody = _postsData[index]["postBody"];
              DateTime postedOn = _postsData[index]["postedOn"];
              List<String>? images;
              if (_postsData[index]["images"] != null) {
                images = [];
                _postsData[index]["images"].forEach((value) {
                  images!.add(value.toString());
                });
              }
              String? link = _postsData[index]["postLink"];

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
  }
}
