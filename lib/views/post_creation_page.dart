import 'package:alumni/firebase_options.dart';
import 'package:alumni/widgets/InputField.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  Function? createFireStoreDoc;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String? _titleError;
  void checkTitle() {
    if (_titleController.text.isEmpty) {
      setState(() {
        _titleError = "A post requires a title";
        createFireStoreDoc = null;
      });
    } else {
      setState(() {
        _titleError = null;
        createFireStoreDoc = () async {
          await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform);
          var firebaseInstance = FirebaseFirestore.instance;
          String title = _titleController.text;
          String author = getCurrentUserName();
          int votes = 0;
          int commentNumber = 0;
          String postContent = _bodyController.text;
          Timestamp postTime = Timestamp.now();

          firebaseInstance.collection('postSummaries').add({
            "title": title,
            "author": author,
            "votes": votes,
            "commentNumber": commentNumber,
            "postContent": postContent,
            "postTime": postTime
          }).then((value) {});
          Navigator.pop(context);
        };
      });
    }
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

  String getCurrentUserName() {
    return "Vibhu";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Create a Post"),
        actions: [
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                  style: TextButton.styleFrom(primary: Colors.blue.shade100),
                  onPressed: () {
                    createFireStoreDoc!();
                  },
                  child: const Text(
                    "Post",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  )))
        ],
      ),
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            children: [
              InputField(
                autoCorrect: true,
                maxLines: 2,
                controller: _titleController,
                labelText: "Title",
                errorText: _titleError,
                onChanged: (value) => checkTitle(),
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(
                height: 20,
              ),
              InputField(
                autoCorrect: true,
                maxLines: 20,
                controller: _bodyController,
                labelText: "Body(Optional)",
                keyboardType: TextInputType.multiline,
              )
            ],
          )),
    );
  }
}
