import 'package:alumni/views/post_creation_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class APost extends StatelessWidget {
  final String postID;
  final String title;
  final String author;
  final int votes;
  final int commentNumber;
  final String postContent;
  final String postedDuration;
  final bool? reaction;
  const APost(
      {required this.postID,
      required this.title,
      required this.author,
      required this.votes,
      required this.commentNumber,
      required this.postContent,
      required this.postedDuration,
      this.reaction,
      Key? key})
      : super(key: key);

  List getCommentsByID(String postID) {
    return [];
  }

  String getCurrentAccessLevel() {
    return "admin";
  }

  String getCurrentUser() {
    return "Vibhu";
  }

  @override
  Widget build(BuildContext context) {
    IconButton deleteButton = IconButton(
        splashRadius: 0.1,
        onPressed: () {},
        icon: const Icon(
          Icons.delete_rounded,
          size: 20,
        ));
    List<Widget> appBarActions = [];
    if (getCurrentUser() == author) {
      appBarActions.add(deleteButton);
      appBarActions.add(IconButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return CreatePostPage(
              postId: postID,
              title: title,
              postContent: postContent,
            );
          }));
        },
        icon: const Icon(
          Icons.edit,
          size: 20,
        ),
        splashRadius: 0.1,
      ));
    } else if (getCurrentAccessLevel() == "admin") {
      appBarActions.add(deleteButton);
    }
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double appBarHeight = screenHeight * 0.045;
    List comments = getCommentsByID(postID);
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
                      title,
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
                        "By:" + author + " (" + postedDuration + ")",
                        style: GoogleFonts.lato(
                            fontSize: 10, color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Text(
                          votes.toString(),
                          style: GoogleFonts.lato(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Text(" \u2022 "),
                        Text(
                          commentNumber.toString() + " comments",
                          style: GoogleFonts.lato(
                              fontSize: 14, color: Colors.grey.shade400),
                        )
                      ],
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
                                postContent,
                                style: GoogleFonts.lato(
                                    fontSize: 14, color: Colors.grey.shade50),
                              ),
                            ))),
                    const SizedBox(
                      height: 2,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 39, 53, 57)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: () {},
                              child: const Icon(Icons.arrow_upward_rounded)),
                          TextButton(
                              onPressed: () {},
                              child: const Icon(Icons.arrow_downward_rounded)),
                          TextButton(
                              onPressed: () {},
                              child: const Icon(Icons.bookmark_add)),
                        ],
                      ),
                    )
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
