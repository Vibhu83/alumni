import 'dart:io';

import 'package:alumni/globals.dart';
import 'package:alumni/views/a_post_page.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/group_box.dart';
import 'package:alumni/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class CreatePostPage extends StatefulWidget {
  final String? postID;
  final String? postTitle;
  final String? postBody;
  final List<String>? imageUrls;
  final List<Image>? images;
  final String? postLink;
  const CreatePostPage(
      {this.postID,
      this.postTitle,
      this.postBody,
      this.imageUrls,
      this.images,
      this.postLink,
      Key? key})
      : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  Function? createFireStoreDoc;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _postLink;
  late List<Image> _images;
  late List<String> _imageUrls;
  String? _linkError;

  @override
  void initState() {
    _imageUrls = [];
    _images = [];
    if (widget.images != null) {
      _images = widget.images!;
      _imageUrls = widget.imageUrls!;
    }
    _titleController = TextEditingController(text: widget.postTitle);
    if (widget.postTitle != null) {
      createFireStoreDoc = saveOrUpdateData;
    }
    _postLink = TextEditingController(text: widget.postLink);
    _bodyController = TextEditingController(text: widget.postBody);
    super.initState();
  }

  void popOldPostPage() {
    Navigator.of(context).pop();
  }

  Future<String> addPost(String postTitle, String authorID, int postVotes,
      String postBody, Timestamp postTime) async {
    String postID =
        await firestore!.collection("posts").add({}).then((value) async {
      String postID = value.id;
      int count = 0;
      List<String> imageUrls = [];
      for (String path in _imageUrls) {
        if (path.substring(0, 5) == "/data") {
          count++;
          imageUrls.add(await uploadFileAndGetLink(
              path, postID + "/postImages" + count.toString(), context));
        }
      }
      await firestore!.collection('posts').doc(postID).set({
        "postID": postID,
        "postAuthorID": authorID,
        "postTitle": postTitle,
        "postVotes": postVotes,
        "postBody": postBody,
        "postedOn": postTime,
        "rating": 0,
        "postLink": _postLink.text,
        "images": imageUrls,
      }, SetOptions(merge: true));
      postAdded = true;
      addedPostData = {
        "postID": postID,
        "postAuthorID": authorID,
        "postTitle": postTitle,
        "postVotes": postVotes,
        "postBody": postBody,
        "postedOn": postTime,
        "rating": 0,
        "postLink": _postLink.text,
        "images": imageUrls,
      };
      return postID;
    });
    return postID;
  }

  void updatePost(String postTitle, String postBody) async {
    List<String> imageUrls = [];
    int count = _imageUrls.length - 1;
    for (String path in _imageUrls) {
      if (path.substring(0, 5) == "/data") {
        count++;
        imageUrls.add(await uploadFileAndGetLink(
            path, widget.postID! + "/postImage" + count.toString(), context));
      } else {
        imageUrls.add(path);
      }
    }
    firestore!.collection("posts").doc(widget.postID).update({
      "postTitle": postTitle,
      "postBody": postBody,
      "postLink": _postLink.text,
      "images": imageUrls
    });
    updatedPostID = widget.postID;
    updatedPostData = {
      "postTitle": postTitle,
      "postBody": postBody,
      "postLink": _postLink.text,
      "images": _images,
      "imagesUrls": imageUrls
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
      String authorName = userData["name"];
      Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
        return APost(
            postID: postID,
            postTitle: postTitle,
            authorID: authorID,
            postVotes: postVotes,
            authorName: authorName,
            postBody: postBody,
            postedDuration:
                printDuration(postTime.toDate().difference(DateTime.now())));
      })));
    } else {
      updatePost(postTitle, postBody);
      Navigator.of(context).pop();
    }
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    //   return const MainPage(
    //     startingIndex: 3,
    //   );
    // }));
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

  Widget _buildImagesInput() {
    return GroupBox(
        titleBackground: Theme.of(context).canvasColor,
        title: "Add images",
        // titleBackground: pageBackground,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            SizedBox(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(4)),
                      child: ListTile(
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: IconButton(
                                  splashRadius: 1,
                                  iconSize: 20,
                                  onPressed: () {
                                    setState(() {
                                      _images.removeAt(index);
                                      _imageUrls.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.close)),
                            ),
                            SizedBox(
                              height: screenHeight * 0.025,
                            ),
                          ],
                        ),
                        title: _buildImage(() {
                          ImagePicker()
                              .pickImage(source: ImageSource.gallery)
                              .then((value) {
                            if (value != null) {
                              _images[index] = Image.file(File(value.path));
                              _imageUrls.add(value.path);
                            }
                          });
                        }, _images[index]),
                        onTap: () {},
                      ),
                    );
                  }),
            ),
            IconButton(
                splashRadius: 16,
                onPressed: () {
                  ImagePicker().pickMultiImage().then((value) {
                    if (value != null) {
                      var newImages = _images;
                      var newImageUrls = _imageUrls;
                      for (XFile e in value) {
                        newImages.add(Image.file(File(e.path)));
                        newImageUrls.add(e.path);
                        print(_imageUrls);
                      }
                      setState(() {
                        _images = newImages;
                        _imageUrls = newImageUrls;
                      });
                    }
                  });
                },
                icon: const Icon(Icons.add))
          ],
        ));
  }

  Widget _buildImage(void Function()? onClicked, Image image) {
    var imageProvider = image.image;
    return Material(
      color: Colors.transparent,
      child: Ink.image(
        image: imageProvider,
        fit: BoxFit.scaleDown,
        width: 128,
        height: 128,
        child: InkWell(
          onTap: onClicked,
        ),
      ),
    );
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
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      resizeToAvoidBottomInset: true,
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
                  style: const ButtonStyle(),
                  onPressed: createFireStoreDoc as void Function()?,
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  )))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                SizedBox(
                  height: screenHeight * 0.0085,
                ),
                InputField(
                  autoCorrect: true,
                  maxLines: (screenHeight * 0.035).toInt(),
                  controller: _bodyController,
                  labelText: "Body(Optional)",
                  keyboardType: TextInputType.multiline,
                ),
                _buildImagesInput(),
                InputField(
                  errorText: _linkError,
                  onChanged: (p0) {
                    if (p0.isNotEmpty) {
                      if (Uri.tryParse(p0)!.hasAbsolutePath != true) {
                        setState(() {
                          _linkError = "Invalid Link";
                          createFireStoreDoc = null;
                        });
                      } else {
                        setState(() {
                          _linkError = null;
                          createFireStoreDoc = saveOrUpdateData;
                        });
                      }
                    } else {
                      setState(() {
                        _linkError = null;
                        createFireStoreDoc = saveOrUpdateData;
                      });
                    }
                  },
                  keyboardType: TextInputType.url,
                  controller: _postLink,
                  labelText: "Share some link (Optional)",
                )
              ],
            )),
      ),
    );
  }
}
