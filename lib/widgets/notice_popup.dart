import 'package:alumni/globals.dart';
import 'package:alumni/widgets/add_notice_popup.dart';
import 'package:alumni/widgets/appbar_widgets.dart';
import 'package:alumni/widgets/future_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Notices extends StatefulWidget {
  const Notices({Key? key}) : super(key: key);

  @override
  State<Notices> createState() => _NoticesState();
}

class _NoticesState extends State<Notices> {
  bool shouldReturnEmpty = false;
  late List<Map<String, dynamic>> sortedNotices;
  late int currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    currentIndex = 0;
    super.initState();
  }

  Future<bool> checkForNotices() async {
    DateTime oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
    Timestamp lastDate = Timestamp.fromDate(oneWeekAgo);

    var notices = await firestore!
        .collection("notices")
        .where("noticeID", whereNotIn: userData["noticesDismissed"])
        .limit(3)
        .where("noticePostedOn", isGreaterThanOrEqualTo: lastDate)
        .orderBy("noticePostedOn", descending: true)
        .get()
        .then((value) {
      return value.docs.map((e) {
        return e.data();
      }).toList();
    });
    if (notices.isNotEmpty) {
      sortedNotices = notices;
      sortedNotices.sort((a, b) {
        Timestamp aPostedOn = a["noticePostedOn"];
        Timestamp bPostedOn = b["noticePostedOn"];
        return bPostedOn.compareTo(aPostedOn);
      });
      return true;
    } else {
      Navigator.of(context).pop();
      return false;
    }
  }

  void dismissNotices() async {
    if (userData["uid"] != null) {
      for (Map map in sortedNotices) {
        userData["noticesDismissed"].add(map["noticeID"]);
      }
      firestore!
          .collection("users")
          .doc(userData["uid"])
          .update({"noticesDismissed": userData["noticesDismissed"]});
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: checkForNotices(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          List<Widget> children;
          if (snapshot.data == true) {
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
              Text(
                "Notices (" +
                    (currentIndex + 1).toString() +
                    "/" +
                    sortedNotices.length.toString() +
                    ")",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                                  message: sortedNotices[currentIndex]
                                      ["noticeMessage"],
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
              Navigator.of(context).pop();
              return const SizedBox();
            }

            return AlertDialog(
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                actionsPadding: EdgeInsets.zero,
                scrollable: true,
                backgroundColor: const Color.fromARGB(255, 0, 73, 116),
                title: Container(
                  decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey))),
                  width: double.maxFinite,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    children: header,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                ),
                content: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  alignment: Alignment.center,
                  height: screenHeight * 0.5,
                  width: screenWidth * 0.8,
                  child: PageView.builder(
                      controller: _pageController,
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
                actions: [
                  Container(
                    width: double.maxFinite,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                    decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey))),
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: currentIndex == sortedNotices.length - 1
                          ? () {
                              dismissNotices();
                              Navigator.of(context).pop();
                            }
                          : () {
                              _pageController.jumpToPage(currentIndex + 1);
                            },
                      child: Text(
                        currentIndex == sortedNotices.length - 1
                            ? "Dismiss"
                            : "Next",
                        style: TextStyle(
                            color: Colors.brown.shade900,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ]);
          } else if (snapshot.hasError) {
            children = buildFutureError(snapshot);
          } else {
            children = buildFutureLoading(snapshot);
          }
          return buildFuture(children: children);
        });
  }
}
