import 'package:alumni/globals.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:alumni/widgets/custom_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddNoticePopUp extends StatelessWidget {
  final String? id;
  final String? message;
  const AddNoticePopUp({this.id, this.message, Key? key}) : super(key: key);

  void _addNotice(String message) async {
    Timestamp currentTime = Timestamp.fromDate(DateTime.now());
    var doc = await firestore!
        .collection("notices")
        .add({"noticeMessage": message, "noticePostedOn": currentTime});
    firestore!
        .collection("notices")
        .doc(doc.id)
        .set({"noticeID": doc.id}, SetOptions(merge: true));
    newNotice = {
      "new?": true,
      "noticeID": doc.id,
      "noticeMessage": message,
      "noticePostedOn": currentTime
    };
  }

  void _updateNotice(String message) {
    firestore!.collection("notices").doc(id).update({"noticeMessage": message});
    newNotice = {"new?": false, "noticeMessage": message};
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _message = TextEditingController(text: message);
    return CustomAlertDialog(
        height: screenHeight * 0.65,
        actions: [
          TextButton(
              onPressed: () async {
                message == null
                    ? _addNotice(_message.text)
                    : _updateNotice(_message.text);
                Navigator.of(context).pop();
              },
              child: const Text("Submit"))
        ],
        title:
            Text(id == null ? "Add notice to the home page" : "Update notice"),
        content: InputField(
          autoCorrect: true,
          maxLines: 24,
          controller: _message,
          labelText: "Message",
          keyboardType: TextInputType.multiline,
        ));
  }
}
