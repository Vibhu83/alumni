import 'package:alumni/globals.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/views/post_creation_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/ask_message_popup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class APost extends StatefulWidget {
  final String postID;
  final String postTitle;
  final String authorID;
  final String authorName;
  final String postBody;
  final String postedDuration;
  final bool? reaction;
  const APost(
      {required this.postID,
      required this.postTitle,
      required this.authorID,
      required this.authorName,
      required this.postBody,
      required this.postedDuration,
      this.reaction,
      Key? key})
      : super(key: key);

  @override
  State<APost> createState() => _APost();
}

class _APost extends State<APost> {
  Future<int?> getData() async {
    votes = await firestore!.collection("posts").doc(widget.postID).get().then(
      (value) {
        return value.data()!["postVotes"];
      },
    );
    if (userData["uid"] == null) {
      return null;
    }

    print(userData);
    bool? voteValue = await firestore!
        .collection("userVotes")
        .doc(userData["uid"])
        .get()
        .then((value) {
      print(value);
      return value.data()![widget.postID];
    });
    return voteBoolToVoteOffsetMap[voteValue];
  }

  final Map voteOffsetToVoteBoolMap = {
    -1: false,
    0: null,
    1: true,
  };

  final Map voteBoolToVoteOffsetMap = {false: -1, null: 0, true: 1};

  late int voteOffset;
  late int votes;

  void deletePost() {
    firestore!.collection("posts").doc(widget.postID).delete();
    backToForumPage();
  }

  void editPost() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return CreatePostPage(
        postID: widget.postID,
        postTitle: postTitle,
        postBody: postBody,
      );
    })).then((value) {
      if (updatedPostID == widget.postID) {
        setState(() {
          postTitle = updatedPostData["postTitle"];
          postBody = updatedPostData["postBody"];
        });
      }
    });
  }

  void sharePost() {
    showDialog(
        context: context,
        builder: (context) {
          return AskMessagePopUp(
              editingFlag: false,
              title: postTitle,
              authorName: widget.authorName,
              id: widget.postID,
              type: "post");
        });
  }

  void backToForumPage() {
    Navigator.of(context).popUntil(ModalRoute.withName(""));
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const MainPage(
        startingIndex: 3,
      );
    }));
  }

  List<Widget> getAppBarActions() {
    IconButton shareButton = buildAppBarIcon(
        onPressed: () {
          sharePost();
        },
        icon: Icons.notification_add_rounded);
    IconButton editButton = buildAppBarIcon(
        onPressed: () {
          editPost();
        },
        icon: Icons.edit);
    IconButton deleteButton = buildAppBarIcon(
        onPressed: () {
          deletePost();
        },
        icon: Icons.delete_rounded);
    List<Widget> appBarActions = [];
    if (userData["uid"] == widget.authorID) {
      if (userData["accessLevel"] == "admin") {
        appBarActions.add(shareButton);
      }

      appBarActions.add(editButton);
      appBarActions.add(deleteButton);
    } else if (userData["accessLevel"] == "admin") {
      appBarActions.add(deleteButton);
      appBarActions.add(shareButton);
    }
    return appBarActions;
  }

  late String postTitle;
  late String postBody;

  @override
  void initState() {
    votes = 0;
    voteOffset = 0;
    postBody = widget.postBody;
    postTitle = widget.postTitle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (context, AsyncSnapshot<int?> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              voteOffset = snapshot.data!;
            }
            votes -= voteOffset;
            print(voteOffset);
            return _buildPage();
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

  Future<void> upvote() async {
    print("upvote");
    var doc = await firestore!
        .collection("posts")
        .doc(widget.postID)
        .get()
        .then((value) => value);
    int votes = doc.data()!["postVotes"];
    int changeInVote = 0;
    int nextVoteOffset = 0;
    if (voteOffset == 1) {
      nextVoteOffset = 0;
      changeInVote = -1;
    } else if (voteOffset == 0) {
      nextVoteOffset = 1;
      changeInVote = 1;
    } else {
      nextVoteOffset = 1;
      changeInVote = 2;
    }
    firestore!
        .collection("posts")
        .doc(widget.postID)
        .update({"postVotes": votes + changeInVote});
    firestore!
        .collection("userVotes")
        .doc(userData["uid"])
        .update({widget.postID: voteOffsetToVoteBoolMap[nextVoteOffset]});
    setState(() {
      voteOffset = nextVoteOffset;
    });
  }

  Future<void> downvote() async {
    print("downvote");
    var doc = await firestore!
        .collection("posts")
        .doc(widget.postID)
        .get()
        .then((value) => value);
    int votes = doc.data()!["postVotes"];
    int changeInVote = 0;
    int nextVoteOffset = 0;
    if (voteOffset == -1) {
      nextVoteOffset = 0;
      changeInVote = 1;
    } else if (voteOffset == 0) {
      nextVoteOffset = -1;
      changeInVote = -1;
    } else {
      nextVoteOffset = -1;
      changeInVote = -2;
    }
    firestore!
        .collection("posts")
        .doc(widget.postID)
        .update({"postVotes": votes + changeInVote});
    firestore!
        .collection("userVotes")
        .doc(userData["uid"])
        .update({widget.postID: voteOffsetToVoteBoolMap[nextVoteOffset]});
    setState(() {
      voteOffset = nextVoteOffset;
    });
  }

  Scaffold _buildPage() {
    var appBarActions = getAppBarActions();
    Widget postButtons = const SizedBox(
      height: 0,
    );
    Color votesColor = Colors.grey;
    Color upvoteButtonColor = Colors.grey;
    Color downvoteButtonColor = Colors.grey;
    if (voteOffset == 1) {
      upvoteButtonColor = Colors.blue;
      votesColor = upvoteButtonColor;
    } else if (voteOffset == -1) {
      downvoteButtonColor = Colors.deepOrange;
      votesColor = downvoteButtonColor;
    }

    IconButton upvoteButton = IconButton(
        splashRadius: 1,
        color: upvoteButtonColor,
        onPressed: () {
          upvote();
        },
        icon: const Icon(Icons.arrow_upward_sharp));

    IconButton downvoteButton = IconButton(
        splashRadius: 1,
        color: downvoteButtonColor,
        onPressed: () {
          downvote();
        },
        icon: const Icon(Icons.arrow_downward_sharp));

    if (userData["uid"] != null) {
      postButtons = Container(
        decoration: const BoxDecoration(color: Color.fromARGB(255, 31, 41, 44)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            upvoteButton,
            downvoteButton,
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
                      postTitle,
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
                      (votes + voteOffset).toString(),
                      style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: votesColor),
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
                                postBody,
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
