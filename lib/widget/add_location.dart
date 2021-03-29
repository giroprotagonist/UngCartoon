import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class AddLocation extends StatefulWidget {
  final double? lat;
  final double? lng;
  final double? speed;
  AddLocation({Key? key, this.lat, this.lng, this.speed}) : super(key: key);
  @override
  _AddLocationState createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  // Field
  double? lat, lng;
  double? speed;
  String? dateString;

  // Method
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      setState(() {});
    });

    // create an instance of Location
    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event
    insertDataToFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(right: 42),
              child: OutlinedButton(
                child: const Text('Post User Location'),
                onPressed: insertDataToFirestore,
              ),
            ),
          ],
        ),
      ),
    );
  }

    Future<Stream<Null>> insertDataToFirestore() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    Position _fetchedUserLocation = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    log(_fetchedUserLocation.latitude.toString() +
        _fetchedUserLocation.longitude.toString());

    User firebaseUser = (auth.currentUser)!;
    String email = firebaseUser.email!;
    String uid = firebaseUser.uid;
    String displayName = firebaseUser.displayName!;
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
    map['DisplayName'] = displayName;
    map['Latitude'] = latitude;
    map['Longitude'] = longitude;
    map['Speed'] = speed;
    map['Heading'] = heading;
    map['Timestamp'] = timestamp;

    Map<String, dynamic> map2 = Map();
    map2['DateTime'] = dateString;
    map2['Detail'] = displayName;
    map2['Lat'] = latitude;
    map2['Lng'] = longitude;
    map2['Name'] = speed;
    map2['Uid'] = uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collectionReference =
    firestore.collection('locations');
    await collectionReference.doc('$dateString' + ' $displayName').set(map).then((
        value) {
      print('Upload Success Dawg');
    });

    FirebaseFirestore firestore2 = FirebaseFirestore.instance;
    CollectionReference collectionReference2 =
    firestore2.collection('usertest');
    await collectionReference2.doc(displayName).set(map2).then((
        value) {
      print('Upload Success Dawgydeuce');
    });
    return insertDataToFirestore();
  }
}
