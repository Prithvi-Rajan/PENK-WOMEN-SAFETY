import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'second.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:toast/toast.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'nominee.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:mlkit/mlkit.dart';

class ThirdRoute extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Threeone();
  }
}

class Threeone extends State<ThirdRoute> {
  static FirebaseMessaging fcm = FirebaseMessaging();
  String token;
  String platformImei;
  String pinCode, contact;

  VisionFaceDetectorOptions options = new VisionFaceDetectorOptions(
      modeType: VisionFaceDetectorMode.Accurate,
      landmarkType: VisionFaceDetectorLandmark.All,
      classificationType: VisionFaceDetectorClassification.All,
      minFaceSize: 0.15,
      isTrackingEnabled: true);

  FirebaseVisionFaceDetector detector = FirebaseVisionFaceDetector.instance;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    // getContact();
    getToken();
  }

  getToken() async {
    token = await fcm.getToken();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.

    platformImei =
        await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
    if (!mounted) return;

    setState(() {
      platformImei = platformImei;
    });
  }

  Future getContact() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('contactSF');
    contact = stringValue;
  }

  addStringToSF(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('contactSF', val);
  }

  addNameToSF(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('nameSF', val);
  }

  addURLToSF(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('urlSF', val);
  }

  final fireApp = FirebaseDatabase.instance.reference();
  static var now = DateTime.now();
  static var formatter = new DateFormat('dd-MM-yyyy');
  String selectedDate = formatter.format(now);
  static var menu = ['Male', 'Female', 'Others'];

  void toastmsg(String msg) {
    Toast.show(msg, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
  }

  File _profile;
  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    checkImage(image);
  }

  checkImage(_file) async {
    var face =
        await detector.detectFromBinary(_file?.readAsBytesSync(), options);
    if (face.isEmpty) {
      toastmsg("Face not found! Select a different Photo..");
    } else {
      setState(() {
        _profile = _file;
      });
    }
  }

  String mail;
  static FirebaseAuth _auth = FirebaseAuth.instance;
  String name, address, bloodgroup, gender;

  Future uploadPhoto() async {
    var user = await _auth.currentUser();
    mail = user.email;
    StorageReference ref =
        FirebaseStorage.instance.ref().child('profile/' + mail);
    StorageUploadTask uploadTask = ref.putFile(_profile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String url = taskSnapshot.ref.getDownloadURL().toString();
    addURLToSF(url);
    addStringToSF(contact);

    fireApp.child('subjects/' + contact).set({
      'name': name,
      'address': address,
      'gender': gender,
      'group': bloodgroup,
      'dob': selectedDate,
      'imei': platformImei,
      'mail': mail,
      'token': token,
      'pin': pinCode
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Nominee(contact)));
  }

  final List<DropdownMenuItem<String>> _dropDownMenuItems = menu
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        ),
      )
      .toList();

  static const menuItems = <String>[
    'Sign Out',
  ];
  final List<PopupMenuItem<String>> _popUpItems = menuItems
      .map(
        (String value) => PopupMenuItem<String>(
          value: value,
          child: Text(value),
        ),
      )
      .toList();

  Future signout() async {
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
        backgroundColor: Colors.black87,
        appBar: AppBar(
          title: Text("Register"),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String newValue) {
                signout();
              },
              itemBuilder: (BuildContext context) => _popUpItems,
            ),
          ],
        ),
        body: ListView(children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: CircleAvatar(
                      radius: 100,
                      child: ClipOval(
                        child: SizedBox(
                          height: 185,
                          width: 185,
                          child: (_profile == null)
                              ? Image.asset(
                                  'res/default-user.png',
                                  color: Colors.black87,
                                )
                              : Image.file(_profile, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 180.0, right: 20, bottom: 10.0, left: 200),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 35,
                      ),
                      onPressed: () {
                        getImage();
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                    keyboardType: TextInputType.text,
                    onChanged: (text) {
                      name = text;
                    },
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle:
                          TextStyle(color: Colors.red[400], fontSize: 20.0),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    onChanged: (text) {
                      address = text;
                    },
                    decoration: InputDecoration(
                      labelText: "Address",
                      labelStyle:
                          TextStyle(color: Colors.red[400], fontSize: 20.0),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.red)),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                    style: TextStyle(color: Colors.white),
                    maxLength: 10,
                    onChanged: (text) {
                      contact = text;
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Mobile number",
                      labelStyle:
                          TextStyle(color: Colors.red[400], fontSize: 20.0),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.red)),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.text,
                    onChanged: (text) {
                      bloodgroup = text;
                    },
                    decoration: InputDecoration(
                      labelText: "Blood Group",
                      labelStyle:
                          TextStyle(color: Colors.red[400], fontSize: 20.0),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.red)),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                    style: TextStyle(color: Colors.white),
                    maxLength: 6,
                    onChanged: (text) {
                      pinCode = text;
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Pin Code",
                      labelStyle:
                          TextStyle(color: Colors.red[400], fontSize: 20.0),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: Colors.red)),
                    )),
              ),
              new Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.black87,
                  ),
                  child: ListTile(
                    title: Text(
                      'Gender',
                      style: TextStyle(color: Colors.red[400], fontSize: 20.0),
                    ),
                    trailing: DropdownButton<String>(
                      value: gender,
                      hint: Text(
                        "Choose",
                        style: TextStyle(color: Colors.red),
                      ),
                      style: TextStyle(color: Colors.red[400], fontSize: 20.0),
                      onChanged: (String newValue) {
                        setState(() {
                          gender = newValue;
                        });
                      },
                      items: _dropDownMenuItems,
                    ),
                  )),
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10),
                  child: FlatButton(
                      onPressed: () {
                        showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1970),
                                lastDate: DateTime(2020))
                            .then((date) {
                          setState(() {
                            selectedDate = formatter.format(date).toString();
                          });
                        });
                      },
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Select DOB',
                            style: TextStyle(
                                color: Colors.red[400], fontSize: 20.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 15, bottom: 15, left: 10),
                            child: Text(
                              selectedDate.toString(),
                              style: TextStyle(
                                  color: Colors.red[400], fontSize: 20.0),
                            ),
                          )
                        ],
                      )),
                ),
              ),
              RaisedButton(
                  child: Text("Submit"),
                  color: Colors.blue[400],
                  padding: EdgeInsets.all(10.0),
                  onPressed: () {
                    if (contact.length < 10) {
                      toastmsg("Enter a valid Mobile Number");
                    } else if (_profile == null) {
                      toastmsg("Please select a Profile Photo");
                    } else {
                      uploadPhoto();
                    }
                  })
            ],
          ),
        ]));
  }
}
