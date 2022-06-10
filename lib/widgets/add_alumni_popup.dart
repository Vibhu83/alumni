import 'package:alumni/globals.dart';
import 'package:alumni/widgets/custom_alert_dialog.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:flutter/material.dart';

class AddAlumniPopUp extends StatelessWidget {
  final bool editFlag;
  final String uid;
  final String message;
  const AddAlumniPopUp(
      {this.editFlag = false, required this.uid, this.message = "", Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _message = TextEditingController(text: message);
    return CustomAlertDialog(
      height: screenHeight * 0.5,
      title: const Text("About this alumni"),
      actions: [
        TextButton(
            onPressed: () async {
              if (editFlag == false) {
                await firestore!
                    .collection("topAlumni")
                    .doc(uid)
                    .set({"uid": uid, "message": _message.text});
                Navigator.of(context).pop();
              } else {
                print("editing");
                await firestore!
                    .collection("topAlumni")
                    .doc(uid)
                    .update({"message": _message.text});
                Navigator.of(context)
                    .pop(_message.text == "" ? null : _message.text);
              }
            },
            child: const Text("Submit"))
      ],
      content: InputField(
        controller: _message,
        labelText: "About(Optional)",
        maxLines: (screenHeight * 0.024).toInt(),
      ),
    );
  }
}
