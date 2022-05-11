library globals;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

FirebaseApp? app;
FirebaseAuth? auth;
FirebaseFirestore? firestore;

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

String formatDateTime(DateTime dateTime) {
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
  if (minute == "0") {
    minute = "00";
  }
  returnString += " at " + hour + ":" + minute;
  return returnString;
}

Future<String> getAuthorNameByID(String authorID) async {
  String authorName = "";
  authorName = await firestore!
      .collection("users")
      .doc(authorID)
      .get()
      .then((value) => value.data()!["name"]);
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

int? lastPostChangeInVote;
bool? lastPostBool;

int? lastEventAttendeeChange;
bool? lastEventBool;

void changeVote(String postID) {
  firestore!.collection("posts").doc(postID).get().then((value) {
    int votes = value.data()!["postVotes"];
    firestore!
        .collection("posts")
        .doc(postID)
        .update({"postVotes": votes + lastPostChangeInVote!}).then((value) {
      lastPostChangeInVote = null;
    });
    firestore!
        .collection("userVotes")
        .doc(userData["uid"])
        .update({postID: lastPostBool}).then((value) {
      lastPostBool = null;
    });
  });
}

void changeAttendeeNumber(String eventID) {
  firestore!.collection("events").doc(eventID).get().then((value) {
    int dbAttendeeNum = value["eventAttendeesNumber"];
    firestore!.collection("events").doc(eventID).update({
      "eventAttendeesNumber": dbAttendeeNum + lastEventAttendeeChange!
    }).then((value) {
      lastEventAttendeeChange = null;
    });
    firestore!
        .collection("eventAttendanceStatus")
        .doc(userData["uid"])
        .update({eventID: lastEventBool}).then((value) {
      lastEventBool = null;
    });
  });
}
