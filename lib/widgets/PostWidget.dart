import 'package:alumni/views/a_post_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Post extends StatelessWidget {
  final String postID;
  final String title;
  final String author;
  final int votes;
  final int commentNumber;
  final String postContent;
  final DateTime postTime;
  final bool? reaction;
  final bool? saveStatus;
  const Post(
      {required this.postID,
      required this.title,
      required this.author,
      required this.votes,
      required this.commentNumber,
      required this.postContent,
      required this.postTime,
      this.reaction,
      this.saveStatus,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Duration postedDuration;
    postedDuration = postTime.difference(DateTime.now());
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return APost(
                postID: postID,
                title: title,
                author: author,
                votes: votes,
                commentNumber: commentNumber,
                postContent: postContent,
                postedDuration: _printDuration(postedDuration));
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
                      title,
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
                            author +
                            " (" +
                            _printDuration(postedDuration) +
                            ")",
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

  String _printDuration(Duration duration) {
    int days = duration.inDays.abs();
    int hours = duration.inHours.abs();
    int mins = duration.inMinutes.abs();
    int secs = duration.inSeconds.abs();
    if (days != 0) {
      hours = hours.remainder(24);
      return days.toString() + "d" + " " + hours.toString() + "h";
    } else if (hours != 0) {
      mins = mins.remainder(60);
      return hours.toString() + "h" + " " + mins.toString() + "m";
    } else if (mins != 0) {
      secs = secs.remainder(60);
      return mins.toString() + "m" + " " + secs.toString() + "s";
    } else {
      return secs.toString() + "s";
    }
  }
}
