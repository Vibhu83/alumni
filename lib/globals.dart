library globals;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

FirebaseApp? app;
FirebaseAuth? auth;
FirebaseFirestore? firestore;

Map<String, dynamic> userData = {};

late double screenHeight;
late double screenWidth;
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
  returnString += " At " + hour + ":" + minute;
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
