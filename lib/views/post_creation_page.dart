import 'package:alumni/firebase_options.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/widgets/InputField.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostPage extends StatefulWidget {
  final String? postId;
  final String? title;
  final String? postContent;
  const CreatePostPage({this.postId, this.title, this.postContent, Key? key})
      : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  Function? createFireStoreDoc;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.title);
    _bodyController = TextEditingController(text: widget.postContent);
    super.initState();
  }

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
          String title = _titleController.text;
          String authorId = userData["uid"];
          String author = userData["name"];
          int votes = 0;
          int commentNumber = 0;
          String postContent = _bodyController.text;
          Timestamp postTime = Timestamp.now();

          firestore!.collection('postSummaries').add({
            "authorId": authorId,
            "title": title,
            "authorName": author,
            "votes": votes,
            "commentNumber": commentNumber,
            "postContent": postContent,
            "postTime": postTime
          }).then((value) {});
          Navigator.of(context).popUntil(ModalRoute.withName(""));
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return const MainPage(
              startingIndex: 3,
            );
          }));
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title;
    String buttonText;
    if (widget.title != null) {
      title = "Edit the post";
      buttonText = "Edit";
    } else {
      title = "Create a post";
      buttonText = "Post";
    }
    double appBarHeight = screenHeight * 0.045;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0x24, 0x24, 0x24),
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade800))),
          child: AppBar(
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(8))),
            leading: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 20,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              title,
              style: const TextStyle(fontSize: 18),
            ),
            actions: [
              Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: TextButton(
                      style:
                          TextButton.styleFrom(primary: Colors.blue.shade100),
                      onPressed: () {
                        createFireStoreDoc!();
                      },
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      )))
            ],
          ),
        ),
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
