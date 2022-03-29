import 'package:location/location.dart';
import 'models/user_location.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'models/subject-model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  UserLocation _currentLocation;

  var location = Location();

  Future<UserLocation> getLocation() async {
    try {
      var userLocation = await location.getLocation();
      _currentLocation = UserLocation(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
      );
    } on Exception catch (e) {
      print('Could not get location: ${e.toString()}');
    }

    return _currentLocation;
  }

  StreamController<UserLocation> _locationController =
      StreamController<UserLocation>();

  Stream<UserLocation> get locationStream => _locationController.stream;

  LocationService() {
    String contact;

    String geoPath = "geoPaths";
    Geofire.initialize(geoPath);
    // Request permission to use location
    location.requestPermission().then((permissionStatus) {
      if (permissionStatus.index == 1) {
        // If granted listen to the onLocationChanged stream and emit over our controller
        location.onLocationChanged().listen((locationData) {
          if (locationData != null) {
            _locationController.add(UserLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
            ));
          }

          final DatabaseReference locUpdate =
              FirebaseDatabase.instance.reference();
          locUpdate.child('subjects/' + '971598250' + '/location').set(
              {'lat': locationData.latitude, 'lon': locationData.longitude});
          Geofire.setLocation(
              '9715982529', locationData.latitude, locationData.longitude);
        });
      }
    });
  }
}
