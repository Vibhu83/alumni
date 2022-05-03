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
