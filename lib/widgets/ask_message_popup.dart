import 'package:alumni/globals.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:alumni/widgets/my_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AskMessagePopUp extends StatelessWidget {
  final String? title;
  final String? authorName;
  final String? id;
  final String? type;
  final String? content;
  final String? recommendationId;
  final bool? editingFlag;
  const AskMessagePopUp(
      {required this.editingFlag,
      required this.title,
      required this.authorName,
      required this.id,
      required this.type,
      this.content,
      this.recommendationId,
      Key? key})
      : super(key: key);

  void shareThisPostWithMessage(String? content) async {
    firestore!.collection("recommendationFromAdmins").add({}).then((value) {
      String recommendationID = value.id;
      firestore!
          .collection("recommendationFromAdmins")
          .doc(recommendationID)
          .set({
        "recommendationID": recommendationID,
        "recommendedItemID": id,
        "recommendedTime": Timestamp.fromDate(DateTime.now()),
        "recommendationType": type,
        "recommendationMessage": content
      }, SetOptions(merge: true));
      return recommendationID;
    });
  }

  void updateTheRecommendation(String content) {
    firestore!
        .collection("recommendationFromAdmins")
        .doc(recommendationId)
        .update({"recommendationMessage": content});
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _messageController =
        TextEditingController(text: content);
    return buildAlertDialog(
        height: 425,
        actions: [
          TextButton(
              onPressed: () {
                if (editingFlag == false) {
                  shareThisPostWithMessage(_messageController.text);
                } else {
                  updateLastRecommendationText = _messageController.text;
                  updateTheRecommendation(_messageController.text);
                }
                Navigator.of(context).pop();
              },
              child: const Text("Submit"))
        ],
        title: const Text("Share a message with this recommendation?"),
        content: InputField(
          autoCorrect: true,
          maxLines: 20,
          controller: _messageController,
          labelText: "Message(Optional)",
          keyboardType: TextInputType.multiline,
        ));
  }
}
