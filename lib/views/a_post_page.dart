import 'dart:async';

import 'package:alumni/globals.dart';
import 'package:alumni/views/post_creation_page.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/ask_message_popup.dart';
import 'package:alumni/widgets/confirmation_popup.dart';
import 'package:alumni/widgets/full_screen_page.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class APost extends StatefulWidget {
  final bool isUnapproved;
  final String postID;
  final String postTitle;
  final String? authorID;
  final int postVotes;
  final String authorName;
  final String postBody;
  final String postedDuration;
  final bool? reaction;
  final List<Image>? images;
  final List<String>? imagesUrls;
  final String? postLink;
  const APost(
      {this.isUnapproved = false,
      required this.postID,
      required this.postTitle,
      required this.authorID,
      required this.postVotes,
      required this.authorName,
      required this.postBody,
      required this.postedDuration,
      this.images,
      this.imagesUrls,
      this.postLink,
      this.reaction,
      Key? key})
      : super(key: key);

  @override
  State<APost> createState() => _APost();
}

class _APost extends State<APost> {
  late bool _isInitialRun;
  late bool _isBookmarked;
  late String _postTitle;
  late String _postBody;
  late List<Image>? _postImages;
  late List<String>? _postImagesUrl;
  late String? postLink;
  late int _voteOffset;
  late int _votes;
  late bool _isUnapproved;

  @override
  void initState() {
    _isUnapproved = widget.isUnapproved;
    if (userData["postsBookmarked"] != null) {
      _isBookmarked = userData["postsBookmarked"].contains(widget.postID);
    } else {
      _isBookmarked = false;
    }
    _isInitialRun = true;
    _votes = 0;
    _voteOffset = 0;
    _postBody = widget.postBody;
    _postTitle = widget.postTitle;
    _postImages = widget.images;
    _postImagesUrl = widget.imagesUrls;
    postLink = widget.postLink;
    super.initState();
  }

  Future<bool> _getVotes() async {
    if (_isInitialRun == true) {
      if (_isUnapproved) {
        return true;
      }
      _isInitialRun = false;

      _votes =
          await firestore!.collection("posts").doc(widget.postID).get().then(
        (value) {
          return value.data()!["postVotes"];
        },
      );
      if (userData["uid"] == null) {
        return false;
      }

      bool? voteValue = await firestore!
          .collection("userVotes")
          .doc(userData["uid"])
          .get()
          .then((value) {
        return value.data()![widget.postID];
      });

      _voteOffset = voteBoolToVoteOffsetMap[voteValue];
      return false;
    } else {
      return false;
    }
  }

  void _deletePost() {
    firestore!.collection("posts").doc(widget.postID).delete();
    deleteStorageFolder(widget.postID);
    firestore!
        .collection("recommendationFromAdmins")
        .where("recommendedItemID", isEqualTo: widget.postID)
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (element.data()["recommendationType"] == "post") {
          firestore!
              .collection("recommendationFromAdmins")
              .doc(element["recommendationID"])
              .delete();
        }
      }
    });
    firestore!
        .collection("userVotes")
        .where(widget.postID, isNotEqualTo: null)
        .get()
        .then((value) {
      for (var element in value.docs) {
        firestore!
            .collection("userVotes")
            .doc(element.id)
            .update({widget.postID: FieldValue.delete()});
      }
    });
    String id = widget.postID;
    List temp = userData["postsBookmarked"];
    temp.remove(id);
    userData["postsBookmarked"] = temp;
    firestore!
        .collection("users")
        .where("postsBookmarked", arrayContains: id)
        .get()
        .then((value) {
      for (var element in value.docs) {
        List? temp = element.data()["postsBookmarked"];
        if (temp != null) {
          temp.remove(id);
          firestore!
              .collection("users")
              .doc(element.id)
              .update({"postsBookmarked": temp});
        }
      }
    });
    Navigator.of(context).pop(-1);
  }

  void _editPost() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return CreatePostPage(
        isUnapproved: _isUnapproved,
        postID: widget.postID,
        postTitle: _postTitle,
        postBody: _postBody,
        imageUrls: _postImagesUrl,
        images: _postImages,
        postLink: widget.postLink,
      );
    })).then((value) {
      if (updatedPostID == widget.postID) {
        setState(() {
          _isUnapproved = updatedPostData["isUnapproved"]!;
          _postTitle = updatedPostData["postTitle"];
          _postBody = updatedPostData["postBody"];
          _postImages = updatedPostData["images"];
          _postImagesUrl = updatedPostData["imagesUrls"];
        });
      }
    });
  }

  void _sharePost() {
    showDialog(
        context: context,
        builder: (context) {
          return AskMessagePopUp(
              editingFlag: false,
              title: _postTitle,
              authorName: widget.authorName,
              id: widget.postID,
              type: "post");
        });
  }

  List<Widget> _getAppBarActions() {
    IconButton approveButton = buildAppBarIcon(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return const ConfirmationPopUp(
                  title: "Approve the post?",
                );
              }).then((value) {
            if (value == true) {
              _approvePost();
              Navigator.of(context).pop(-1);
            }
          });
        },
        icon: Icons.check);
    IconButton disapproveButton = buildAppBarIcon(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return const ConfirmationPopUp(
                  title: "Delete the approval request?",
                );
              }).then((value) {
            if (value == true) {
              firestore!
                  .collection("unapprovedPosts")
                  .doc(widget.postID)
                  .delete();
              deleteStorageFolder(widget.postID);
              firestore!
                  .collection("recommendationFromAdmins")
                  .where("recommendedItemID", isEqualTo: widget.postID)
                  .get()
                  .then((value) {
                for (var element in value.docs) {
                  if (element.data()["recommendationType"] == "post") {
                    firestore!
                        .collection("recommendationFromAdmins")
                        .doc(element["recommendationID"])
                        .delete();
                  }
                }
              });
              firestore!
                  .collection("userVotes")
                  .where(widget.postID, isNotEqualTo: null)
                  .get()
                  .then((value) {
                for (var element in value.docs) {
                  firestore!
                      .collection("userVotes")
                      .doc(element.id)
                      .update({widget.postID: FieldValue.delete()});
                }
              });
              String id = widget.postID;
              List temp = userData["postsBookmarked"];
              temp.remove(id);
              userData["postsBookmarked"] = temp;
              firestore!
                  .collection("users")
                  .where("postsBookmarked", arrayContains: id)
                  .get()
                  .then((value) {
                for (var element in value.docs) {
                  List? temp = element.data()["postsBookmarked"];
                  if (temp != null) {
                    temp.remove(id);
                    firestore!
                        .collection("users")
                        .doc(element.id)
                        .update({"postsBookmarked": temp});
                  }
                }
              });
              Navigator.of(context).pop(-1);
            }
          });
        },
        icon: Icons.delete_forever);
    IconButton shareButton = buildAppBarIcon(
        onPressed: () {
          _sharePost();
        },
        icon: Icons.notification_add_rounded);
    IconButton editButton = buildAppBarIcon(
        onPressed: () {
          _editPost();
        },
        icon: Icons.edit);
    IconButton deleteButton = buildAppBarIcon(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return const ConfirmationPopUp(
                  title: "Are you sure?",
                );
              }).then((value) {
            if (value == true) {
              _deletePost();
            }
          });
        },
        icon: Icons.delete_rounded);
    List<Widget> appBarActions = [];

    if (_isUnapproved) {
      if (userData["hasAdminAccess"] == true &&
          widget.authorID == userData["uid"]) {
        appBarActions.add(editButton);
        appBarActions.add(disapproveButton);
        appBarActions.add(
          approveButton,
        );
      } else if (widget.authorID == userData["uid"]) {
        appBarActions.add(editButton);
        appBarActions.add(disapproveButton);
      } else if (userData["hasAdminAccess"] == true) {
        appBarActions.add(disapproveButton);
        appBarActions.add(
          approveButton,
        );
      }
    } else {
      if (userData["hasAdminAccess"] == true &&
          widget.authorID == userData["uid"]) {
        appBarActions.add(shareButton);
        appBarActions.add(editButton);
        appBarActions.add(deleteButton);
      } else if (widget.authorID == userData["uid"]) {
        appBarActions.add(editButton);
        appBarActions.add(deleteButton);
      } else if (userData["hasAdminAccess"] == true) {
        appBarActions.add(shareButton);
        appBarActions.add(deleteButton);
      }
    }

    // if (widget.authorID != null && userData["uid"] == widget.authorID) {
    //   if (userData["hasAdminAccess"] == true && _isUnapproved == false) {
    //     appBarActions.add(shareButton);
    //   }

    //   appBarActions.add(editButton);
    //   if (_isUnapproved == false) {
    //     appBarActions.add(deleteButton);
    //   }
    //   if (_isUnapproved) {
    //     appBarActions.addAll([
    //       disapproveButton,
    //       approveButton,
    //     ]);
    //   }
    // } else if (userData["hasAdminAccess"] == true) {
    //   if (_isUnapproved == false) {
    //     appBarActions.add(shareButton);
    //     appBarActions.add(deleteButton);
    //   } else {
    //     appBarActions.addAll([
    //       disapproveButton,
    //       approveButton,
    //     ]);
    //   }
    // }
    return appBarActions;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getVotes(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasData) {
            return _buildPage();
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }

  int upvote() {
    int changeInVote = 0;
    int nextVoteOffset = 0;
    if (_voteOffset == 1) {
      nextVoteOffset = 0;
      changeInVote = -1;
    } else if (_voteOffset == 0) {
      nextVoteOffset = 1;
      changeInVote = 1;
    } else {
      nextVoteOffset = 1;
      changeInVote = 2;
    }
    setState(() {
      _voteOffset = nextVoteOffset;
      _votes += changeInVote;

      lastPostBool = voteOffsetToVoteBoolMap[_voteOffset];
      lastPostNewVotes = _votes;
    });
    return changeInVote;
  }

  int downvote() {
    int changeInVote = 0;
    int nextVoteOffset = 0;
    if (_voteOffset == -1) {
      nextVoteOffset = 0;
      changeInVote = 1;
    } else if (_voteOffset == 0) {
      nextVoteOffset = -1;
      changeInVote = -1;
    } else {
      nextVoteOffset = -1;
      changeInVote = -2;
    }
    setState(() {
      _voteOffset = nextVoteOffset;
      _votes += changeInVote;
      lastPostNewVotes = _votes;
      lastPostBool = voteOffsetToVoteBoolMap[_voteOffset];
    });
    return changeInVote;
  }

  void setBookmark() {
    List postsBookmarked = userData["postsBookmarked"];
    postsBookmarked.add(widget.postID);

    userData["postBookmarked"] = postsBookmarked;

    firestore!
        .collection("users")
        .doc(userData["uid"])
        .update({"postsBookmarked": postsBookmarked});
  }

  void unsetBookmark() {
    List postsBookmarked = userData["postsBookmarked"];
    postsBookmarked.remove(widget.postID);

    userData["postBookmarked"] = postsBookmarked;

    firestore!
        .collection("users")
        .doc(userData["uid"])
        .update({"postsBookmarked": postsBookmarked});
  }

  void _approvePost() async {
    Map<String, dynamic> post = await firestore!
        .collection("unapprovedPosts")
        .doc(widget.postID)
        .get()
        .then((value) {
      var temp = value.data()!;
      firestore!.collection("unapprovedPosts").doc(widget.postID).delete();
      return temp;
    });
    post.remove("type");
    firestore!.collection("posts").doc(widget.postID).set(post);
  }

  Scaffold _buildPage() {
    var appBarActions = _getAppBarActions();
    Widget postButtons = const SizedBox(
      height: 0,
    );

    Color votesColor = Colors.grey;
    if (_isUnapproved == false) {
      Color bookMarkIconColor = Theme.of(context).appBarTheme.foregroundColor!;
      IconData bookMarkIcon = Icons.bookmark_add;
      if (_isBookmarked == true) {
        bookMarkIcon = Icons.bookmark_added;
        bookMarkIconColor = Colors.blue;
      }
      Color upvoteButtonColor = Colors.grey;
      Color downvoteButtonColor = Colors.grey;
      if (_voteOffset == 1) {
        upvoteButtonColor = Colors.blue;
        votesColor = upvoteButtonColor;
      } else if (_voteOffset == -1) {
        downvoteButtonColor = Colors.deepOrange;
        votesColor = downvoteButtonColor;
      }

      IconButton upvoteButton = IconButton(
          splashRadius: 1,
          color: upvoteButtonColor,
          onPressed: () {
            int changeInVotes = upvote();
            changeVote(widget.postID, changeInVotes);
          },
          icon: const Icon(Icons.arrow_upward_sharp));

      IconButton downvoteButton = IconButton(
          splashRadius: 1,
          color: downvoteButtonColor,
          onPressed: () {
            int changeInVotes = downvote();
            changeVote(widget.postID, changeInVotes);
          },
          icon: const Icon(Icons.arrow_downward_sharp));
      IconButton bookmarkButton = IconButton(
          splashRadius: 1,
          onPressed: () {
            if (_isBookmarked == true) {
              unsetBookmark();
              setState(() {
                _isBookmarked = false;
              });
            } else {
              setBookmark();
              setState(() {
                _isBookmarked = true;
              });
            }
          },
          icon: Icon(
            bookMarkIcon,
            color: bookMarkIconColor,
          ));
      List<Widget> bottomNavButtons = [];
      if (userData["uid"] != null) {
        bottomNavButtons.addAll([upvoteButton, downvoteButton, bookmarkButton]);
      }
      if (postLink != null && Uri.tryParse(postLink!)!.hasAbsolutePath) {
        IconButton openLinkButton = IconButton(
            onPressed: () {
              launchUrl(Uri.parse(postLink!),
                  mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.open_in_new));
        bottomNavButtons.add(openLinkButton);
      }
      postButtons = bottomNavButtons.isNotEmpty
          ? Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .appBarTheme
                          .shadowColor!
                          .withOpacity(0.25),
                      blurStyle: BlurStyle.solid,
                      spreadRadius: 0.1,
                      blurRadius: 0.5,
                      offset: const Offset(0, -1),
                    ),
                  ]),
              height: screenHeight * .06,
              child: Card(
                color: Theme.of(context).appBarTheme.backgroundColor,
                shadowColor: Theme.of(context).appBarTheme.shadowColor,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: bottomNavButtons,
                ),
              ),
            )
          : const SizedBox();
    }
    Widget bannerWidget;
    double bannerAreaHeight;
    if (_postImages != null && _postImages!.isNotEmpty) {
      bannerAreaHeight = screenHeight * 0.2;
      bannerWidget = GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
            return FullScreenImageViewer(child: _postImages!, dark: true);
          })));
        },
        child: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: _postImages![0].image, fit: BoxFit.fitHeight)),
        ),
      );
    } else {
      bannerAreaHeight = 0;
      bannerWidget = const SizedBox();
    }
    return Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        bottomNavigationBar: postButtons,
        appBar: buildAppBar(
            leading: buildAppBarIcon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icons.close_rounded),
            actions: appBarActions),
        body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  stretchTriggerOffset: 1,
                  onStretchTrigger: () async {
                    setState(() {});
                  },
                  toolbarHeight: 0,
                  backgroundColor: Theme.of(context).canvasColor,
                  actions: const [SizedBox()],
                  expandedHeight: bannerAreaHeight,
                  flexibleSpace: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlexibleSpaceBar(background: bannerWidget),
                  ),
                ),
              ];
            },
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _postTitle,
                    style: GoogleFonts.lato(
                        fontSize: 16, height: 1.3, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: screenHeight * 0.005,
                  ),
                  TextButton(
                    onPressed: () {
                      if (widget.authorID != null) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ProfilePage(uid: widget.authorID!);
                        }));
                      }
                    },
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
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Theme.of(context)
                              .appBarTheme
                              .shadowColor!
                              .withOpacity(0.8)),
                    ),
                  ),
                  _isUnapproved == true
                      ? Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.005),
                          child: Text(
                            "Not yet approved by Admin Team",
                            style: TextStyle(
                                fontSize: 8,
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context)
                                    .appBarTheme
                                    .foregroundColor!
                                    .withOpacity(0.75)),
                          ),
                        )
                      : const SizedBox(),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Text(
                    _votes.toString(),
                    style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: votesColor),
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Flexible(
                      child: _postBody.isNotEmpty
                          ? Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 2, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor
                                      .withOpacity(0.8)),
                              width: double.maxFinite,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0, vertical: 4),
                                child: Text(
                                  _postBody,
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .appBarTheme
                                          .foregroundColor),
                                ),
                              ))
                          : const SizedBox()),
                  const SizedBox(
                    height: 2,
                  ),
                ],
              ),
            )));
  }
}
