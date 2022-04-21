import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class APost extends StatelessWidget {
  final int postID;
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

  List getCommentsByID(int postID) {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    List comments = getCommentsByID(postID);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close)),
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
