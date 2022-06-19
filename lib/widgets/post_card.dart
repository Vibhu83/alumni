// import 'package:alumni/ThemeData/dark_theme.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/a_post_page.dart';
import 'package:alumni/views/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class APostCard extends StatefulWidget {
  final bool isUnapproved;
  final String postID;
  final String postTitle;
  final String? postAuthorID;
  final String postAuthorName;
  final int postVotes;
  final String postBody;
  final DateTime postedOn;
  final List<String>? imagesUrls;
  final String? postLink;
  const APostCard(
      {this.isUnapproved = false,
      required this.postID,
      required this.postTitle,
      required this.postAuthorID,
      required this.postAuthorName,
      required this.postVotes,
      required this.postBody,
      required this.postedOn,
      this.imagesUrls,
      this.postLink,
      Key? key})
      : super(key: key);

  @override
  State<APostCard> createState() => _APostCardState();
}

class _APostCardState extends State<APostCard> {
  late String _postTitle;
  late String _postBody;
  late int _postVotes;
  late List<Image> _images;
  late List<String> _imageUrls;
  late bool _returnEmpty;

  @override
  void initState() {
    _returnEmpty = false;
    _images = [];
    _imageUrls = [];
    if (widget.imagesUrls != null) {
      _imageUrls = widget.imagesUrls!;
      for (int i = 0; i < widget.imagesUrls!.length; i++) {
        _images.add(Image.network(widget.imagesUrls![i]));
      }
    }
    _postTitle = widget.postTitle;
    _postBody = widget.postBody;
    _postVotes = widget.postVotes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_returnEmpty == true) {
      return const SizedBox();
    }
    Duration postedDuration;
    postedDuration = widget.postedOn.difference(DateTime.now());

    List<Widget> titleWidgets = [];
    titleWidgets.addAll(
      [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _postTitle,
                style: GoogleFonts.lato(
                    fontSize: 16, height: 1.3, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                softWrap: false,
              ),
              SizedBox(
                height: screenHeight * 0.005,
              ),
              TextButton(
                onPressed: () {
                  if (widget.postAuthorID != null) {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ProfilePage(uid: widget.postAuthorID!);
                    }));
                  }
                },
                style: TextButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text(
                  "By:" +
                      widget.postAuthorName +
                      " (" +
                      printDuration(postedDuration) +
                      ")",
                  style: GoogleFonts.lato(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .appBarTheme
                          .shadowColor!
                          .withOpacity(0.8)),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Text(
                _postVotes.toString(),
                style:
                    GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
            ],
          ),
        ),
        SizedBox(
          width: screenWidth * 0.025,
        )
      ],
    );

    if (_images.isNotEmpty) {
      titleWidgets.add(Container(
        height: screenHeight * 0.110,
        width: screenWidth * 0.3,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: _images[0].image, fit: BoxFit.fitHeight)),
      ));
    }

    Widget title = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: titleWidgets,
    );

    return Container(
      margin: const EdgeInsets.only(right: 4, left: 4, top: 4, bottom: 5),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return APost(
              isUnapproved: widget.isUnapproved,
              postID: widget.postID,
              postTitle: _postTitle,
              authorID: widget.postAuthorID,
              postVotes: widget.postVotes,
              authorName: widget.postAuthorName,
              postBody: _postBody,
              imagesUrls: _imageUrls,
              images: _images,
              postLink: widget.postLink,
              postedDuration:
                  printDuration(widget.postedOn.difference(DateTime.now())),
            );
          })).then((value) {
            if (value == -1) {
              setState(() {
                _returnEmpty = true;
              });
            }
            if (updatedPostID == widget.postID) {
              if (updatedPostData["isUnapproved"] == true &&
                  widget.isUnapproved == false) {
                setState(() {
                  _returnEmpty = true;
                });
              } else {
                setState(() {
                  _postTitle = updatedPostData["postTitle"];
                  _postBody = updatedPostData["postBody"];
                  _images = updatedPostData["images"];
                  _imageUrls = updatedPostData["imagesUrls"];
                });
              }
            }
            if (lastPostNewVotes != null) {
              setState(() {
                _postVotes = lastPostNewVotes!;
              });
            }

            lastPostNewVotes = null;
            lastPostBool = null;
          });
        },
        child: Card(
          shadowColor:
              Theme.of(context).appBarTheme.shadowColor!.withOpacity(0.3),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: (MainAxisSize.max),
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      title,
                      SizedBox(
                        height: screenHeight * 0.01,
                      ),
                      Flexible(
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.9),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              width: double.maxFinite,
                              child: Text(
                                _postBody,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .appBarTheme
                                        .foregroundColor),
                                softWrap: false,
                              ))),
                      SizedBox(
                        height: screenHeight * 0.002,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
