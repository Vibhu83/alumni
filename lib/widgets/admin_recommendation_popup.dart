import 'package:alumni/globals.dart';
import 'package:alumni/widgets/ask_message_popup.dart';
import 'package:alumni/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';

class AdminRecommendationPopUp extends StatelessWidget {
  final void Function()? onPressed;
  final String recommendedItemTitle;
  final String content;
  final String recommendationId;
  final String title;
  const AdminRecommendationPopUp(
      {required this.recommendationId,
      required this.onPressed,
      required this.recommendedItemTitle,
      required this.content,
      required this.title,
      Key? key})
      : super(key: key);

  void _deleteRecommendation() {
    firestore!
        .collection("recommendationFromAdmins")
        .doc(recommendationId)
        .delete();
    deleteLastOpenedRecommendation = true;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> recommendationItemActions = [];
    if (userData["hasAdminAccess"] == true) {
      recommendationItemActions.add(IconButton(
          splashRadius: 14,
          onPressed: () {
            _deleteRecommendation();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.delete_outlined)));
      recommendationItemActions.add(IconButton(
          splashRadius: 14,
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AskMessagePopUp(
                    editingFlag: true,
                    title: null,
                    authorName: null,
                    id: null,
                    type: null,
                    content: content,
                    recommendationId: recommendationId,
                  );
                }).then((value) {
              Navigator.of(context).pop();
            });
          },
          icon: const Icon(Icons.edit_outlined)));
    }

    recommendationItemActions.add(IconButton(
        splashRadius: 14,
        onPressed: onPressed,
        icon: const Icon(Icons.open_in_new_outlined)));

    return CustomAlertDialog(
        titlePadding: EdgeInsets.zero,
        actions: [
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: recommendationItemActions),
        ],
        title: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 10),
          // decoration: BoxDecoration(
          //     border: Border(bottom: BorderSide(color: Colors.grey.shade800))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                    fontSize: 20,
                  ))
            ],
          ),
        ),
        content: SizedBox(
          height: screenHeight * 0.4,
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              content,
              // style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
        ));
  }
}
