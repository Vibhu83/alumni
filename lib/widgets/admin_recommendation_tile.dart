import 'package:alumni/globals.dart';
import 'package:alumni/widgets/admin_recommendation_popup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AdminRecommendationListTile extends StatefulWidget {
  final void Function()? onPressed;
  final String recommendationType;
  final String recommendationId;
  final String recommendedItemTitle;
  final String content;
  const AdminRecommendationListTile(
      {required this.recommendationId,
      required this.recommendationType,
      required this.onPressed,
      required this.recommendedItemTitle,
      required this.content,
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
    String title =
        "Admin Team has recommended this " + widget.recommendationType + ":";
    if (returnEmpty != true) {
      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ElevatedButton(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
            backgroundColor: MaterialStateProperty.all(
                const Color.fromARGB(255, 33, 44, 47)),
          ),
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
                            color: Colors.grey.shade400,
                            fontSize: 13,
                            fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 0,
      );
    }
  }
}
