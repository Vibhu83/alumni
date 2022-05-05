import 'package:alumni/globals.dart';
import 'package:alumni/views/a_post_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class APostCard extends StatelessWidget {
  final String postID;
  final String postTitle;
  final String postAuthorID;
  final String postAuthorName;
  final int postVotes;
  final String postBody;
  final DateTime postedOn;
  final bool? postReaction;
  final bool? postSaveStatus;
  const APostCard(
      {required this.postID,
      required this.postTitle,
      required this.postAuthorID,
      required this.postAuthorName,
      required this.postVotes,
      required this.postBody,
      required this.postedOn,
      this.postReaction,
      this.postSaveStatus,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Duration postedDuration;
    postedDuration = postedOn.difference(DateTime.now());
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return APost(
                postID: postID,
                title: postTitle,
                authorId: postAuthorID,
                authorName: postAuthorName,
                votes: postVotes,
                postContent: postBody,
                postedDuration: printDuration(postedDuration));
          }));
        },
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          backgroundColor:
              MaterialStateProperty.all(const Color.fromARGB(255, 33, 44, 47)),
        ),
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
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      softWrap: false,
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
                            postAuthorName +
                            " (" +
                            printDuration(postedDuration) +
                            ")",
                        style: GoogleFonts.lato(
                            fontSize: 10, color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      postVotes.toString(),
                      style: GoogleFonts.lato(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Flexible(
                        child: Container(
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
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lato(
                                    fontSize: 14, color: Colors.grey.shade50),
                                softWrap: false,
                              ),
                            ))),
                    const SizedBox(
                      height: 2,
                    ),
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
