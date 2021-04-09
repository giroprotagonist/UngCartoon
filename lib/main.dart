import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rideyrbiketracker/router.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

const EVENTS_KEY = "fetch_events";

String initialRoute = '/authen';

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  var taskId = task.taskId;
  var timeout = task.timeout;
  if (timeout) {

    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  print("[BackgroundFetch] Headless event received: $taskId");

  var timestamp = DateTime.now();

  var prefs = await SharedPreferences.getInstance();

  // Read fetch_events from SharedPreferences
  var events = <String>[];
  var json = prefs.getString(EVENTS_KEY);
  if (json != null) {
    FirebaseAuth auth = FirebaseAuth.instance;
    Position _fetchedUserLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    log(_fetchedUserLocation.latitude.toString() +
        _fetchedUserLocation.longitude.toString());

    User firebaseUser = (auth.currentUser)!;
    String email = firebaseUser.email!;
    String uid = firebaseUser.uid;
    String displayNamed = firebaseUser.displayName!;
    DateTime dateTime = DateTime.now();
    String dateString = DateFormat('dd-MM-yyyy - kk:mm').format(dateTime);
    double latitude = _fetchedUserLocation.latitude.toDouble();
    double longitude = _fetchedUserLocation.longitude.toDouble();
    String speed = _fetchedUserLocation.speed.toString();
    String heading = _fetchedUserLocation.heading.toString();
    String timestamp = _fetchedUserLocation.timestamp.toString();

    Map<String, dynamic> map = Map();
    map['DateTime'] = dateString;
    map['Email'] = email;
    map['Uid'] = uid;
    map['DisplayName'] = displayNamed;
    map['Latitude'] = latitude;
    map['Longitude'] = longitude;
    map['Speed'] = speed;
    map['Heading'] = heading;
    map['Timestamp'] = timestamp;

    Map<String, dynamic> map2 = Map();
    map2['DateTime'] = dateString;
    map2['Detail'] = displayNamed;
    map2['Lat'] = latitude;
    map2['Lng'] = longitude;
    map2['Name'] = speed;
    map2['Uid'] = uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collectionReference =
    firestore.collection('locations');
    await collectionReference.doc('$dateString' + ' $displayNamed').set(map).then((
        value) {
      print('Upload Success Dawg');
    });

    FirebaseFirestore firestore2 = FirebaseFirestore.instance;
    CollectionReference collectionReference2 =
    firestore2.collection('usertest');
    await collectionReference2.doc('$displayNamed').set(map2).then((
        value) {
      print('Upload Success Dawgydeuce');
    });
    events = jsonDecode(json).cast<String>();

  }
  // Add new event.
  events.insert(0, "$taskId@$timestamp [Headless]");
  // Persist fetch events in SharedPreferences
  prefs.setString(EVENTS_KEY, jsonEncode(events));

  if (taskId == 'flutter_background_fetch') {
    FirebaseAuth auth = FirebaseAuth.instance;
    Position _fetchedUserLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    log(_fetchedUserLocation.latitude.toString() +
        _fetchedUserLocation.longitude.toString());

    User firebaseUser = (auth.currentUser)!;
    String email = firebaseUser.email!;
    String uid = firebaseUser.uid;
    String displayNamed = firebaseUser.displayName!;
    DateTime dateTime = DateTime.now();
    String dateString = DateFormat('dd-MM-yyyy - kk:mm').format(dateTime);
    double latitude = _fetchedUserLocation.latitude.toDouble();
    double longitude = _fetchedUserLocation.longitude.toDouble();
    String speed = _fetchedUserLocation.speed.toString();
    String heading = _fetchedUserLocation.heading.toString();
    String timestamp = _fetchedUserLocation.timestamp.toString();

    Map<String, dynamic> map = Map();
    map['DateTime'] = dateString;
    map['Email'] = email;
    map['Uid'] = uid;
    map['DisplayName'] = displayNamed;
    map['Latitude'] = latitude;
    map['Longitude'] = longitude;
    map['Speed'] = speed;
    map['Heading'] = heading;
    map['Timestamp'] = timestamp;

    Map<String, dynamic> map2 = Map();
    map2['DateTime'] = dateString;
    map2['Detail'] = displayNamed;
    map2['Lat'] = latitude;
    map2['Lng'] = longitude;
    map2['Name'] = speed;
    map2['Uid'] = uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collectionReference =
    firestore.collection('locations');
    await collectionReference.doc('$dateString' + ' $displayNamed').set(map).then((
        value) {
      print('Upload Success Dawg');
    });

    FirebaseFirestore firestore2 = FirebaseFirestore.instance;
    CollectionReference collectionReference2 =
    firestore2.collection('usertest');
    await collectionReference2.doc('$displayNamed').set(map2).then((
        value) {
      print('Upload Success Dawgydeuce');
    });
  }
    BackgroundFetch.scheduleTask(TaskConfig(
        taskId: "com.transistorsoft.customtask",
        delay: 5000,
        periodic: false,
        forceAlarmManager: false,
        stopOnTerminate: false,
        enableHeadless: true
    ));
  //BackgroundFetch.finish(taskId);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp().then((value) async {
    FirebaseAuth.instance.authStateChanges().listen((event) {
      if (event != null) {
        initialRoute = '/myService';
      }
  runApp(MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    });
  });
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: routes,
      initialRoute: initialRoute,
    );
  }
}