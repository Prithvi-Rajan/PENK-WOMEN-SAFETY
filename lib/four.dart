import 'dart:async';
import 'dart:ffi';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:the_argus/tracking.dart';
import 'map.dart';
import 'profile.dart';
import 'tracking.dart';
import 'second.dart';
import 'package:location/location.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:volume/volume.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:firebase_messaging/firebase_messaging.dart';

class Four extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Maphome();
  }
}

class Maphome extends State<Four> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String contact;
  final DatabaseReference locUpdate = FirebaseDatabase.instance.reference();
  var location = Location();
  FirebaseMessaging fcm = FirebaseMessaging();
  List<String> availableKeys = [];
  String token, name, url;
  final DatabaseReference nomCheck = FirebaseDatabase.instance.reference();
  bool _enabled;
  Location locForBG = Location();
  List<String> recipents = [];
  bool _dialVisible = true;

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) {
    if (message.containsKey('data')) {
      // Handle data message
      BuildContext context;
      String target = message['data']['target'];
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => MapPage(target)));
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      final dynamic notification = message['notification'];
    }

    return null;
  }

  void _onClickEnable(enabled) {
    if (enabled) {
      // Reset odometer.
      bg.BackgroundGeolocation.start().then((bg.State state) {
        print('[start] success $state');
        setState(() {
          _enabled = state.enabled;
        });
      }).catchError((error) {
        print('[start] ERROR: $error');
      });
    } else {
      bg.BackgroundGeolocation.stop().then((bg.State state) {
        print('[stop] success: $state');

        setState(() {
          _enabled = state.enabled;
        });
      });
    }
  }

  getRecepients() async {
    nomCheck.child('subjects/' + contact + '/nominees').once().then((snapshot) {
      Map<dynamic, dynamic> s = snapshot.value;
      s.forEach((k, v) {
        recipents.add(k);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getContact();

    location.requestPermission();
    _initPlatformState();
    getRecepients();
    getname();

    String geoPath = "geoPaths";
    Geofire.initialize(geoPath);
    final DatabaseReference locUpdate = FirebaseDatabase.instance.reference();
    final QuickActions quickActions = QuickActions();
    quickActions.initialize((shortcutType) {
      if (shortcutType == 'SOS') {
        print('The user tapped on the "SOS" action.');
        geoQuery();
      }
    });
    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(type: 'SOS', localizedTitle: 'SOS', icon: 'icon_main'),
    ]);

    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                  child: Text('Track'),
                  onPressed: () {
                    print(message);
                    String target = message['data']['target'];
                    print(target);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MapPage(target)));
                  }),
            ],
          ),
        );
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        String target = message['data']['target'];
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MapPage(target)));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        String target = message['data']['target'];
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => MapPage(target)));
      },
    );
  }

  Future getname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('nameSF');
    name = stringValue;
  }

  getLoc() async {
    locForBG.getLocation().then((locBG) {
      String time = locBG.time.toString();
      locUpdate.child('subjects/' + contact + '/time').set(time);
      locUpdate
          .child('subjects/' + contact + '/location/')
          .set({'lat': locBG.latitude, 'lon': locBG.longitude});
      Geofire.setLocation(contact, locBG.latitude, locBG.longitude);
    });
  }

  void _onLocation(bg.Location location) {
    print('[location] - $location');
    locForBG.getLocation().then((locBG) {
      String time = locBG.time.toString();
      double bat = (location.battery.level) * 100;
      locUpdate.child('subjects/' + contact + '/battery').set(bat);
      locUpdate.child('subjects/' + contact + '/time').set(time);
      locUpdate
          .child('subjects/' + contact + '/location/')
          .set({'lat': locBG.latitude, 'lon': locBG.longitude});
      Geofire.setLocation(contact, locBG.latitude, locBG.longitude);
    });
  }

  void _onLocationError(bg.LocationError error) {
    print('[location] ERROR - $error');
  }

  void _onMotionChange(bg.Location location) {
    print('[motionchange] - $location');
    locForBG.getLocation().then((locBG) {
      String time = locBG.time.toString();
      double bat = (location.battery.level) * 100;
      locUpdate.child('subjects/' + contact + '/battery').set(bat);
      locUpdate.child('subjects/' + contact + '/time').set(time);
      locUpdate
          .child('subjects/' + contact + '/location/')
          .set({'lat': locBG.latitude, 'lon': locBG.longitude});
      Geofire.setLocation(contact, locBG.latitude, locBG.longitude);
    });
  }

  // void _onActivityChange(bg.ActivityChangeEvent event) {
  //   print('[activitychange] - $event');
  // }

  // void _onProviderChange(bg.ProviderChangeEvent event) {
  //   print('$event');
  // }

  void _onConnectivityChange(bg.ConnectivityChangeEvent event) {
    getLoc();
  }

  Future<Null> _initPlatformState() async {
    bg.BackgroundGeolocation.onLocation(_onLocation, _onLocationError);
    bg.BackgroundGeolocation.onMotionChange(_onMotionChange);
    //bg.BackgroundGeolocation.onActivityChange(_onActivityChange);
    //bg.BackgroundGeolocation.onProviderChange(_onProviderChange);
    bg.BackgroundGeolocation.onConnectivityChange(_onConnectivityChange);

    bg.BackgroundGeolocation.ready(bg.Config(
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 5.0,
            stopOnTerminate: false,
            startOnBoot: true,
            debug: true,
            enableHeadless: true,
            notificationText: "Actively monitored by ARGUS!",
            notificationTitle: "ARGUS!",
            forceReloadOnMotionChange: true,
            logLevel: bg.Config.LOG_LEVEL_VERBOSE,
            reset: true))
        .then((bg.State state) {
      setState(() {
        _enabled = state.enabled;
      });
    }).catchError((error) {
      print('[ready] ERROR: $error');
    });
  }

  void _sendSMS(List<String> recipents) async {
    String message = name +
        " is in danger! They are stranded without mobile data. Click the link to track from the last recorded location: " +
        url;
    String _result =
        await FlutterSms.sendSMS(message: message, recipients: recipents)
            .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  Future getContact() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('contactSF');
    contact = stringValue;
    url = 'https://argustest.000webhostapp.com/leaflet.html?number=' + contact;
    getRecepients();
  }

  getToken(key) async {
    nomCheck.child('subjects/' + key + '/token').once().then((value) {
      token = value.value.toString();
    });
  }

  sosCall() {
    availableKeys.forEach((f) {
      if (f != contact) {
        getToken(f);
        nomCheck.child('subjects/' + f + '/sos').set({contact: token});
      } else {
        print(f);
      }
    });
    recipents.forEach((f) {
      if (f != contact) {
        getToken(f);
        nomCheck.child('subjects/' + f + '/sos').set({contact: token});
      } else {
        print(f);
      }
    });
  }

  void geoQuery() async {
    //Volume.setVol(0);
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

  signout() async {
    final GoogleSignIn googleSignIn = new GoogleSignIn();
    await googleSignIn.signOut();
    FirebaseAuth.instance.signOut();
    Toast.show("Logout Successful", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Track(),
        elevation: 20,
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState.openDrawer();
          },
        ),
        title: Center(
          child: Text(
            " Argus",
          ),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: "Profile",
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 180),
              child: GestureDetector(
                onLongPress: () {
                  _sendSMS(recipents);
                },
                onTap: () {
                  geoQuery();
                  Toast.show("SOS Called!", context);
                },
                child: ClipOval(
                  child: Container(
                    color: Colors.red[300],
                    height: 240.0, // height of the button
                    width: 240.0, // width of the button
                    child: Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(
                          Icons.add_alert,
                          size: 100,
                        ),
                        Text('SOS', style: TextStyle(fontSize: 52)),
                      ],
                    )),
                  ),
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              color: Colors.red,
              child: Container(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Toggle Location Services "),
                    ),
                    Switch(
                      activeColor: Colors.black,
                      inactiveThumbColor: Colors.grey,
                      value: _enabled,
                      onChanged: _onClickEnable,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
