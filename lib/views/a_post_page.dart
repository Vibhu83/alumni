import 'package:alumni/globals.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/views/post_creation_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/ask_message_popup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class APost extends StatefulWidget {
  final String postID;
  final String title;
  final String authorId;
  final String authorName;
  final int votes;
  final String postContent;
  final String postedDuration;
  final bool? reaction;
  final bool readOnly;
  const APost(
      {required this.postID,
      required this.title,
      required this.authorId,
      required this.authorName,
      required this.votes,
      required this.postContent,
      required this.postedDuration,
      this.reaction,
      this.readOnly = false,
      Key? key})
      : super(key: key);

  @override
  State<APost> createState() => _APost();
}

class _APost extends State<APost> {
  Future<bool> getData() async {
    return true;
  }

  void deletePost() {
    firestore!.collection("posts").doc(widget.postID).delete();
    backToForumPage();
  }

  void backToForumPage() {
    Navigator.of(context).popUntil(ModalRoute.withName(""));
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const MainPage(
        startingIndex: 3,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> appBarActions = [];
    if (userData["uid"] == widget.authorId) {
      if (userData["accessLevel"] == "admin") {
        IconButton shareButton = buildAppBarIcon(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AskMessagePopUp(
                        editingFlag: false,
                        title: widget.title,
                        authorName: widget.authorName,
                        id: widget.postID,
                        type: "post");
                  });
            },
            icon: Icons.notification_add_rounded);
        appBarActions.add(shareButton);
      }
      IconButton editButton = buildAppBarIcon(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return CreatePostPage(
                postId: widget.postID,
                title: widget.title,
                postContent: widget.postContent,
              );
            }));
          },
          icon: Icons.edit);
      appBarActions.add(editButton);
      IconButton deleteButton = buildAppBarIcon(
          onPressed: () {
            deletePost();
          },
          icon: Icons.delete_rounded);
      appBarActions.add(deleteButton);
    } else if (userData["accessLevel"] == "admin") {
      IconButton deleteButton = buildAppBarIcon(
          onPressed: () {
            deletePost();
          },
          icon: Icons.delete_rounded);
      appBarActions.add(deleteButton);
      IconButton shareButton = buildAppBarIcon(
          onPressed: () {
            print("sharing post");
          },
          icon: Icons.notification_add_rounded);
      appBarActions.add(shareButton);
    }
    return FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            return _buildPage(appBarActions);
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
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        });
  }

  Scaffold _buildPage(List<Widget> appBarActions) {
    Widget postButtons = const SizedBox(
      height: 0,
    );
    if (userData["uid"] != null) {
      postButtons = Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 39, 53, 57)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                onPressed: () {},
                child: const Icon(Icons.arrow_upward_rounded)),
            TextButton(
                onPressed: () {},
                child: const Icon(Icons.arrow_downward_rounded)),
            TextButton(onPressed: () {}, child: const Icon(Icons.bookmark_add)),
          ],
        ),
      );
    }
    double appBarHeight = screenHeight * 0.045;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0x24, 0x24, 0x24),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade800))),
          child: AppBar(
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(8))),
            leading: IconButton(
              splashRadius: 0.1,
              icon: const Icon(
                Icons.close_rounded,
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: appBarActions,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: (MainAxisSize.max),
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      child: Text(
                        "By:" +
                            widget.authorName +
                            " (" +
                            widget.postedDuration +
                            ")",
                        style: GoogleFonts.lato(
                            fontSize: 10, color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.votes.toString(),
                      style: GoogleFonts.lato(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Flexible(
                        child: Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 4),
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 39, 53, 57)),
                            width: double.maxFinite,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0, vertical: 4),
                              child: Text(
                                widget.postContent,
                                style: GoogleFonts.lato(
                                    fontSize: 14, color: Colors.grey.shade50),
                              ),
                            ))),
                    const SizedBox(
                      height: 2,
                    ),
                    postButtons,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
