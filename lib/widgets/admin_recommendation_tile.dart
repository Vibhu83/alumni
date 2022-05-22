import 'package:alumni/globals.dart';
import 'package:alumni/widgets/admin_recommendation_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AdminRecommendationListTile extends StatefulWidget {
  final void Function()? onPressed;
  final String recommendationType;
  final String recommendationId;
  final String recommendedItemTitle;
  final String content;
  final Timestamp recommendedTime;
  const AdminRecommendationListTile(
      {required this.recommendationId,
      required this.recommendationType,
      required this.onPressed,
      required this.recommendedItemTitle,
      required this.content,
      required this.recommendedTime,
      Key? key})
      : super(key: key);

  @override
  State<AdminRecommendationListTile> createState() =>
      _AdminRecommendationListTileState();
}

class _AdminRecommendationListTileState
    extends State<AdminRecommendationListTile> {
  late bool returnEmpty;
  late String content;

  @override
  void initState() {
    returnEmpty = false;
    content = widget.content;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String time = printDuration(
        widget.recommendedTime.toDate().difference(DateTime.now()));
    String title =
        "Admin Team has recommended this " + widget.recommendationType + ":";
    if (returnEmpty != true) {
      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: ElevatedButton(
          style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).cardColor)),
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AdminRecommendationPopUp(
                      recommendationId: widget.recommendationId,
                      onPressed: widget.onPressed,
                      recommendedItemTitle: widget.recommendedItemTitle,
                      content: content);
                }).then((value) {
              if (deleteLastOpenedRecommendation == true) {
                deleteLastOpenedRecommendation = null;
                setState(() {
                  returnEmpty = true;
                });
              } else if (updateLastRecommendationText != null) {
                setState(() {
                  content = updateLastRecommendationText!;
                  updateLastRecommendationText = null;
                });
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: (MainAxisSize.max),
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(
                        height: 0.1,
                      ),
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            text: widget.recommendedItemTitle,
                            recognizer: TapGestureRecognizer()
                              ..onTap = widget.onPressed)
                      ])),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        content,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: TextStyle(
                            // color: Colors.grey.shade400,
                            fontSize: 13,
                            fontWeight: FontWeight.normal),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        "(" + time + " ago)",
                        style: TextStyle(
                            fontSize: 10,
                            // color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const SizedBox(
        height: 0,
      );
    }
  }
}
