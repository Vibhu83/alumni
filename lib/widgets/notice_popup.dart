import 'package:alumni/globals.dart';
import 'package:alumni/widgets/add_notice_popup.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Notices extends StatefulWidget {
  final List<Map<String, dynamic>>? notices;
  const Notices({required this.notices, Key? key}) : super(key: key);

  @override
  State<Notices> createState() => _NoticesState();
}

class _NoticesState extends State<Notices> {
  bool shouldReturnEmpty = false;
  late List<Map<String, dynamic>> sortedNotices;
  late int currentIndex;

  @override
  void initState() {
    currentIndex = 0;
    sortedNotices = widget.notices!;
    sortedNotices.sort((a, b) {
      Timestamp aPostedOn = a["noticePostedOn"];
      Timestamp bPostedOn = b["noticePostedOn"];
      return bPostedOn.compareTo(aPostedOn);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (newNotice != null) {
      if (newNotice!["new?"] == true) {
        newNotice!.remove("new?");
        setState(() {
          sortedNotices.insert(0, newNotice!);
        });
        newNotice = null;
      }
    }
    List<Widget> header = [
      const Text(
        "Notices",
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    ];
    if (userData["accessLevel"] == "admin") {
      header.add(Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildAppBarIcon(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AddNoticePopUp(
                          id: sortedNotices[currentIndex]["noticeID"],
                          message: sortedNotices[currentIndex]["noticeMessage"],
                        );
                      }).then((value) {
                    if (newNotice != null) {
                      if (newNotice!["new?"] == false) {
                        setState(() {
                          sortedNotices[currentIndex]["noticeMessage"] =
                              newNotice!["noticeMessage"];
                        });
                        newNotice = null;
                      }
                    }
                  });
                },
                icon: Icons.edit,
                padding: EdgeInsets.zero),
            buildAppBarIcon(
                onPressed: () {
                  firestore!
                      .collection("notices")
                      .doc(sortedNotices[currentIndex]["noticeID"])
                      .delete();
                  setState(() {
                    sortedNotices.removeAt(currentIndex);
                  });
                },
                icon: Icons.delete,
                padding: EdgeInsets.zero)
          ]));
    }
    if (shouldReturnEmpty == true) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color.fromARGB(120, 0, 162, 255)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey))),
            width: double.maxFinite,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
            ),
            child: Row(
              children: header,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            height: 300,
            child: PageView.builder(
                onPageChanged: (value) {
                  setState(() {
                    currentIndex = value;
                  });
                },
                itemCount: sortedNotices.length,
                itemBuilder: ((context, index) {
                  return SingleChildScrollView(
                      child: Text(sortedNotices[index]["noticeMessage"]));
                })),
          ),
          Container(
            width: double.maxFinite,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey))),
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () {
                setState(() {
                  shouldReturnEmpty = true;
                });
              },
              child: const Text(
                "Dismiss",
                style: TextStyle(
                    color: Color.fromARGB(255, 141, 0, 0),
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
