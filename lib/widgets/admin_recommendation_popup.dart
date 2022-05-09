import 'package:alumni/globals.dart';
import 'package:alumni/widgets/ask_message_popup.dart';
import 'package:flutter/material.dart';

class AdminRecommendationPopUp extends StatelessWidget {
  final void Function()? onPressed;
  final String recommendedItemTitle;
  final String content;
  final String recommendationId;
  const AdminRecommendationPopUp(
      {required this.recommendationId,
      required this.onPressed,
      required this.recommendedItemTitle,
      required this.content,
      Key? key})
      : super(key: key);

  void deleteRecommendation() {
    firestore!
        .collection("recommendationFromAdmins")
        .doc(recommendationId)
        .delete();
    deleteLastOpenedRecommendation = true;
  }

  @override
  Widget build(BuildContext context) {
    String title = "Admin Team has recommended this post:";
    List<Widget> recommendationItemActions = [];
    if (userData["uid"] != null) {
      recommendationItemActions.add(IconButton(
          splashRadius: 14,
          onPressed: () {
            deleteRecommendation();
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

    return AlertDialog(
        backgroundColor: const Color.fromARGB(255, 25, 33, 36),
        titlePadding: EdgeInsets.zero,
        actions: [
          Container(
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade800))),
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: recommendationItemActions),
          )
        ],
        title: Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade800))),
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
          height: 400,
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
        ));
  }
}
