import 'package:alumni/globals.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:alumni/widgets/my_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddNoticePopUp extends StatelessWidget {
  const AddNoticePopUp({Key? key}) : super(key: key);

  void addNotice(String message) async {
    var doc = await firestore!.collection("notices").add({
      "noticeMessage": message,
      "noticePostedOn": Timestamp.fromDate(DateTime.now())
    });
    firestore!
        .collection("notices")
        .doc(doc.id)
        .set({"noticeID": doc.id}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _message = TextEditingController();
    return buildAlertDialog(
        height: 500,
        actions: [
          TextButton(
              onPressed: () {
                addNotice(_message.text);
                Navigator.of(context).pop();
              },
              child: const Text("Submit"))
        ],
        title: const Text("Add notice to the home page"),
        content: InputField(
          autoCorrect: true,
          maxLines: 24,
          controller: _message,
          labelText: "Message",
          keyboardType: TextInputType.multiline,
        ));
  }
}
