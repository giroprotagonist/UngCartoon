import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';

class PageWidget extends StatefulWidget {
  PageWidget();

  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<PageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 42),
              child: ElevatedButton(
                child: const Text('Post User Location'),
                onPressed: insertDataToFirestore,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Null> insertDataToFirestore() async {
  await Firebase.initializeApp();
  FirebaseAuth auth = FirebaseAuth.instance;
  Position _fetchedUserLocation = await Geolocator.getCurrentPosition();
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
