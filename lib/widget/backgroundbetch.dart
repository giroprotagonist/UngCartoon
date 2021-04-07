import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:background_fetch/background_fetch.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

const EVENTS_KEY = "fetch_events";

class BackgroundBetcher extends StatefulWidget {
  @override
  _BetcherState createState() => new _BetcherState();
}

class _BetcherState extends State<BackgroundBetcher> {
  bool _enabled = true;
  int _status = 0;
  List<String> _events = [];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Load persisted fetch events from SharedPreferences
    var prefs = await SharedPreferences.getInstance();
    var json = prefs.getString(EVENTS_KEY);
    if (json != null) {
      setState(() {
        _events = jsonDecode(json).cast<String>();
      });
    }

    // Configure BackgroundFetch.
    try {
      var status = await BackgroundFetch.configure(BackgroundFetchConfig(
        minimumFetchInterval: 15,
        forceAlarmManager: false,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ), _onBackgroundFetch, _onBackgroundFetchTimeout);
      print('[BackgroundFetch] configure success: $status');
      setState(() {
        _status = status;
      });

      // Schedule a "one-shot" custom-task in 10000ms.
      // These are fairly reliable on Android (particularly with forceAlarmManager) but not iOS,
      // where device must be powered (and delay will be throttled by the OS).
      BackgroundFetch.scheduleTask(TaskConfig(
          taskId: "com.transistorsoft.customtask",
          delay: 10000,
          periodic: false,
          forceAlarmManager: true,
          stopOnTerminate: false,
          enableHeadless: true
      ));

    } catch(e) {
      print("[BackgroundFetch] configure ERROR: $e");
      setState(() {
        _status = e as int;
      });
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  void _onBackgroundFetch(String taskId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime timestamp = new DateTime.now();
    // This is the fetch-event callback.
    print("[BackgroundFetch] Event received: $taskId");
    setState(() {
      _events.insert(0, "$taskId@${timestamp.toString()}");
    });
    // Persist fetch events in SharedPreferences
    prefs.setString(EVENTS_KEY, jsonEncode(_events));

    if (taskId == "flutter_background_fetch") {
      await Firebase.initializeApp();
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
      await collectionReference2.doc(' $displayNamed').set(map2).then((
          value) {
        print('Upload Success Dawgydeuce');
      });
    }
    // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
    // for taking too long in the background.
    BackgroundFetch.finish(taskId);
  }

  /// This event fires shortly before your task is about to timeout.  You must finish any outstanding work and call BackgroundFetch.finish(taskId).
  void _onBackgroundFetchTimeout(String taskId) {
    print("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }

  void _onClickEnable(enabled) {
    setState(() {
      _enabled = enabled;
    });
    if (enabled) {
      BackgroundFetch.start().then((int status) {
        print('[BackgroundFetch] start success: $status');
      }).catchError((e) {
        print('[BackgroundFetch] start FAILURE: $e');
      });
    } else {
      BackgroundFetch.stop().then((int status) {
        print('[BackgroundFetch] stop success: $status');
      });
    }
  }

  void _onClickStatus() async {
    int status = await BackgroundFetch.status;
    print('[BackgroundFetch] status: $status');
    setState(() {
      _status = status;
    });
  }

  void _onClickClear() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(EVENTS_KEY);
    setState(() {
      _events = [];
    });
  }
  @override
  Widget build(BuildContext context) {
    const EMPTY_TEXT = Center(child: Text('Waiting for fetch events.  Simulate one.\n [Android] \$ ./scripts/simulate-fetch\n [iOS] XCode->Debug->Simulate Background Fetch'));

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text('BackgroundFetch Example', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.amberAccent,
            brightness: Brightness.light,
            actions: <Widget>[
              Switch(value: _enabled, onChanged: _onClickEnable),
            ]
        ),
        body: (_events.isEmpty) ? EMPTY_TEXT : Container(
          child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (BuildContext context, int index) {
                List<String> event = _events[index].split("@");
                return InputDecorator(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 5.0, top: 5.0, bottom: 5.0),
                        labelStyle: TextStyle(color: Colors.blue, fontSize: 20.0),
                        labelText: "[${event[0].toString()}]"
                    ),
                    child: Text(event[1], style: TextStyle(color: Colors.black, fontSize: 16.0))
                );
              }
          ),
        ),
        bottomNavigationBar: BottomAppBar(
            child: Container(
                padding: EdgeInsets.only(left: 5.0, right:5.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ElevatedButton(onPressed: _onClickStatus, child: Text('Status: $_status')),
                      ElevatedButton(onPressed: _onClickClear, child: Text('Clear'))
                    ]
                )
            )
        ),
      ),
    );
  }
}
