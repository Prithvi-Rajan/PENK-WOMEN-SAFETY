import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:volume/volume.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapPage extends StatefulWidget {
  final String subjectToBeTracked;
  MapPage(this.subjectToBeTracked);

  @override
  MapState createState() => MapState(subjectToBeTracked);
}

class MapState extends State<MapPage> {
  String subjectToBeTracked, contact, url, name, mail;
  MapState(this.subjectToBeTracked);
  GoogleMapController mycontroller;
  Geolocator geolocator = Geolocator();
  double subLat = 21.1458, subLon = 79.0882;
  final DatabaseReference nomCheck = FirebaseDatabase.instance.reference();
  var location = Location();
  var currentLocation = LocationData;
  Position subloc = Position(latitude: 21.1458, longitude: 79.0882);
  bool _dialVisible = true;
  List<String> availableKeys = [];
  List<String> recipents = [];

  Marker marker = Marker(
    markerId: MarkerId('user'),
    position: LatLng(21.1458, 79.0882),
  );
  Future getContact() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('contactSF');
    setState(() {
      contact = stringValue;
    });
  }

  getRecepients() async {
    nomCheck
        .child('subjects/' + subjectToBeTracked + '/nominees')
        .once()
        .then((snapshot) {
      Map<dynamic, dynamic> s = snapshot.value;
      s.forEach((k, v) {
        recipents.add(k);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
    getContact();
  }

  @override
  Widget build(BuildContext context) {
    String token;

    getToken(key) async {
      nomCheck.child('subjects/' + key + '/token').once().then((value) {
        token = value.value.toString();
      });
    }

    sosCall() {
      availableKeys.forEach((f) {
        if (f != subjectToBeTracked) {
          getToken(f);
          nomCheck
              .child('subjects/' + f + '/sos')
              .set({subjectToBeTracked: token});
        } else {
          print(f);
        }
      });
    }

    void geoQuery() async {
      Volume.setVol(0);
      double latG, lonG;
      await location.getLocation().then((LocationData currentLocation) {
        setState(() {
          latG = currentLocation.latitude;
          lonG = currentLocation.longitude;
        });
      });
      // var coor = new Coordinates(latG, lonG);
      // var address = await Geocoder.local.findAddressesFromCoordinates(coor);
      // print(address);
      double radius = 5;
      Geofire.initialize('geoPaths');
      Geofire.queryAtLocation(latG, lonG, radius).listen((map) {
        print(map);

        if (map != null) {
          var callBack = map['callBack'];

          switch (callBack) {
            case Geofire.onKeyEntered:
              availableKeys.add(map["key"]);
              print(availableKeys);
              break;
            // case Geofire.onKeyExited:
            //   // availableKeys.remove(map["key"]);
            //   print("key removed: " + map["key"]);
            //   break;
            case Geofire.onGeoQueryReady:
              sosCall();
              break;
          }
        } else {
          setState(() {
            radius++;
          });
        }
      });
    }

    void _sendSMS() async {
      name = 'Shruthi';
      nomCheck
          .child('subjects/' + subjectToBeTracked + 'name')
          .once()
          .then((onValue) {
        name = onValue.toString();
      });
      url =
          'https://argustest.000webhostapp.com/leaflet.html?number=$subjectToBeTracked';
      getRecepients();
      String message =
          "$name is in danger! Click the link to track from the last recorded location: $url";
      String _result =
          await FlutterSms.sendSMS(message: message, recipients: recipents)
              .catchError((onError) {
        print(onError);
      });
      print(_result);
    }

    return Scaffold(
      floatingActionButton: SpeedDial(
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        visible: _dialVisible,
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.red,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.accessibility),
              backgroundColor: Colors.red,
              label: 'Share Location',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => _sendSMS()),
          SpeedDialChild(
            child: Icon(Icons.brush),
            backgroundColor: Colors.blue,
            label: 'SOS',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              print('SECOND CHILD');
              geoQuery();
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition:
            CameraPosition(zoom: 5, target: LatLng(subLat, subLon)),
        mapType: MapType.normal,
        markers: {marker},
        onMapCreated: (controller) {
          mycontroller = controller;
        },
      ),
    );
  }

  _getLocation() async {
    print(subjectToBeTracked);

    final currentLat = await nomCheck
        .child('subjects/' + subjectToBeTracked + '/location/lat')
        .once();

    final currentLon = await nomCheck
        .child('subjects/' + subjectToBeTracked + '/location/lon')
        .once();
    var lat1 = await currentLat.value;
    var lon1 = await currentLon.value;

    setState(() {
      print(currentLon.value);

      marker = Marker(
        markerId: MarkerId('user'),
        position: LatLng(lat1, lon1),
      );

      mycontroller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat1, lon1), zoom: 14.0)));
    });
  }
}
