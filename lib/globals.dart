library globals;

import 'dart:io';
import 'dart:math';

import 'package:alumni/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

bool noticesSeen = false;
bool emailPopUpShown = false;

int? currentHomeTab;

FirebaseApp? app;
FirebaseAuth? auth;
FirebaseFirestore? firestore;
FirebaseStorage? storage;
FirebaseChatCore? chat;

Future<FirebaseApp> _initialiseFireBaseApp() async {
  if (Firebase.apps.isEmpty) {
    var temp = await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform)
        .then((value) {
      return value;
    });
    return temp;
  } else {
    return Firebase.apps[Firebase.apps.length - 1];
  }
}

Future<bool> initialiseFlutterFire() async {
  bool? returnVal = false;
  returnVal = await _initialiseFireBaseApp().then((app) async {
    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;
    storage = FirebaseStorage.instance;
    chat = FirebaseChatCore.instance;
    chat!.setConfig(FirebaseChatCoreConfig(app.name, "chatRooms", "users"));
    return true;
  });
  return returnVal;
}

Map<String, dynamic> userData = {};

late double screenHeight;
late double screenWidth;
late Orientation orientation;

String printDuration(Duration duration) {
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

bool isNumerical(String str) {
  RegExp _numberExp = RegExp(r'^-?[0-9]+$');
  return _numberExp.hasMatch(str);
}

String formatDateTime(DateTime dateTime, {bool showTime = true}) {
  final Map monthMap = {
    1: "January",
    2: "February",
    3: "March",
    4: "April",
    5: "May",
    6: "June",
    7: "July",
    8: "August",
    9: "September",
    10: "October",
    11: "November",
    12: "December"
  };
  DateTime current = DateTime.now();
  String year = "";
  String month = "";
  String date = "";
  String returnString = "";
  String datePostFix = "";
  if (current.year != dateTime.year) {
    year = dateTime.year.toString();
    month = monthMap[dateTime.month];
    date = dateTime.day.toString();
    int temp = dateTime.day % 10;
    if (temp == 1) {
      datePostFix = "st";
    } else if (temp == 2) {
      datePostFix = "nd";
    } else if (temp == 3) {
      datePostFix = "rd";
    } else {
      datePostFix = "th";
    }
    date += datePostFix;
    returnString = month + " " + date + ", " + year;
  } else {
    if (current.month != dateTime.month) {
      month = monthMap[dateTime.month];
      date = dateTime.day.toString();
      int temp = dateTime.day % 10;
      if (temp == 1) {
        datePostFix = "st";
      } else if (temp == 2) {
        datePostFix = "nd";
      } else if (temp == 3) {
        datePostFix = "rd";
      } else {
        datePostFix = "th";
      }
      date += datePostFix;
      returnString = month + " " + date;
    } else {
      if (current.day == dateTime.day) {
        date = "Today";
      } else {
        date = dateTime.day.toString();
        int temp = dateTime.day % 10;
        if (temp == 1) {
          datePostFix = "st";
        } else if (temp == 2) {
          datePostFix = "nd";
        } else if (temp == 3) {
          datePostFix = "rd";
        } else {
          datePostFix = "th";
        }
        date += datePostFix;
      }
      returnString = date;
    }
  }

  String hour = dateTime.hour.toString();
  String minute = dateTime.minute.toString();
  if (dateTime.minute < 10) {
    minute = "0" + minute;
  }
  if (showTime == true) {
    returnString += " at " + hour + ":" + minute;
  }
  return returnString;
}

Future<String> getAuthorNameByID(String authorID) async {
  String authorName = "";
  authorName =
      await firestore!.collection("users").doc(authorID).get().then((value) {
    if (value.data() != null) {
      return value.data()!["name"];
    } else {
      return "[deleted user]";
    }
  });
  return authorName;
}

bool? deleteLastOpenedRecommendation;
String? updateLastRecommendationText;

String? updatedPostID;
Map<String, dynamic> updatedPostData = {};

bool? postAdded;
Map<String, dynamic>? addedPostData = {};

void setScreenDimensions(BuildContext context) {
  var mediaQuery = MediaQuery.of(context);
  orientation = mediaQuery.orientation;
  if (orientation == Orientation.landscape) {
    screenHeight = mediaQuery.size.width;
    screenWidth = mediaQuery.size.height;
  } else {
    screenHeight = mediaQuery.size.height;
    screenWidth = mediaQuery.size.width;
  }
}

final Map voteOffsetToVoteBoolMap = {
  -1: false,
  0: null,
  1: true,
};

final Map voteBoolToVoteOffsetMap = {false: -1, null: 0, true: 1};

int? lastPostNewVotes;
bool? lastPostBool;

int? lastEventAttendeeChange;
bool? lastEventBool;

void changeVote(String postID, int changeBy) {
  DateTime postedOn;
  int votes = 0;

  firestore!.collection("posts").doc(postID).get().then((value) {
    votes = value.data()!["postVotes"];
    Timestamp temp = value.data()!["postedOn"];
    postedOn = temp.toDate();
    firestore!
        .collection("posts")
        .doc(postID)
        .update({"postVotes": votes + changeBy});
    firestore!
        .collection("userVotes")
        .doc(userData["uid"])
        .update({postID: lastPostBool});
    int totalVotes = votes + changeBy;
    int rating = getRating(totalVotes, postedOn);
    firestore!.collection("posts").doc(postID).update({"rating": rating});
  });
}

int getRating(
  int score,
  DateTime postedOn,
) {
  double order = log(max(score.abs(), 1)) / ln10;
  int sign = 0;
  if (score > 0) {
    sign = 1;
  } else if (sign < 0) {
    sign = 0;
  } else {
    sign = -1;
  }
  int seconds = getEpochSeconds(postedOn) - 1134028003;
  return (sign * order + seconds / 45000).round();
}

int getEpochSeconds(DateTime postedOn) {
  int difference = postedOn.difference(DateTime(1970, 1, 1)).inSeconds;
  return difference;
}

void changeAttendeeNumberInDB(String eventID) {
  firestore!.collection("events").doc(eventID).get().then((value) {
    int dbAttendeeNum = value["eventAttendeesNumber"];
    firestore!.collection("events").doc(eventID).update(
        {"eventAttendeesNumber": dbAttendeeNum + lastEventAttendeeChange!});
    firestore!
        .collection("eventAttendanceStatus")
        .doc(userData["uid"])
        .update({eventID: lastEventBool});
  });
}

Future<String> uploadFileAndGetLink(
    String path, String uid, BuildContext context) async {
  var storage = FirebaseStorage.instance;
  var uploadTask = storage.ref(uid).putFile(File(path));
  String url = await uploadTask.then((p0) {
    return p0.storage.ref(uid).getDownloadURL();
  });
  return url;
}

Map<String, dynamic>? newNotice;

// ColorThemes? currentTheme;
