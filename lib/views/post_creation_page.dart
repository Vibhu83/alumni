import 'package:alumni/ThemeData/dark_theme.dart';
import 'package:alumni/globals.dart';
import 'package:alumni/views/a_post_page.dart';
import 'package:alumni/views/main_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePostPage extends StatefulWidget {
  final String? postID;
  final String? postTitle;
  final String? postBody;
  const CreatePostPage({this.postID, this.postTitle, this.postBody, Key? key})
      : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  Function? createFireStoreDoc;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  void popOldPostPage() {
    Navigator.of(context).pop();
  }

  Future<String> addPost(String postTitle, String authorID, int postVotes,
      String postBody, Timestamp postTime) async {
    String temp = await firestore!.collection('posts').add({
      "postAuthorID": authorID,
      "postTitle": postTitle,
      "postVotes": postVotes,
      "postBody": postBody,
      "postedOn": postTime
    }).then((value) {
      return value.id;
    });
    return temp;
  }

  void updatePost(String postTitle, String postBody) {
    firestore!.collection("posts").doc(widget.postID).update({
      "postTitle": postTitle,
      "postBody": postBody,
    });
    updatedPostID = widget.postID;
    updatedPostData = {
      "postTitle": postTitle,
      "postBody": postBody,
    };
  }

  void saveOrUpdateData() async {
    String postTitle = _titleController.text;
    String authorID = userData["uid"];
    int postVotes = 0;
    String postBody = _bodyController.text;
    Timestamp postTime = Timestamp.now();
    if (widget.postID == null) {
      String postID =
          await addPost(postTitle, authorID, postVotes, postBody, postTime);
      Navigator.of(context).pop();
      String authorName = await getAuthorNameByID(authorID);
      Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
        return APost(
            postID: postID,
            postTitle: postTitle,
            authorID: authorID,
            authorName: authorName,
            postBody: postBody,
            postedDuration:
                printDuration(postTime.toDate().difference(DateTime.now())));
      })));
    } else {
      updatePost(postTitle, postBody);
      print(updatedPostData);
      Navigator.of(context).pop();
    }
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    //   return const MainPage(
    //     startingIndex: 3,
    //   );
    // }));
  }

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.postTitle);
    if (widget.postTitle != null) {
      createFireStoreDoc = saveOrUpdateData;
    }
    _bodyController = TextEditingController(text: widget.postBody);
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
        createFireStoreDoc = saveOrUpdateData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title;
    String buttonText;
    if (widget.postTitle != null) {
      title = "Edit the post";
      buttonText = "Edit";
    } else {
      title = "Create a post";
      buttonText = "Post";
    }
    double appBarHeight = screenHeight * 0.045;
    return Scaffold(
      backgroundColor: const Color(postPageBackground),
      resizeToAvoidBottomInset: false,
      appBar: buildAppBar(
        leading: buildAppBarIcon(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icons.close_rounded,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextButton(
                  style: TextButton.styleFrom(primary: Colors.blue.shade100),
                  onPressed: createFireStoreDoc as void Function()?,
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  )))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
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
      ),
    );
  }
}
