import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_argus/form.dart';
import 'package:the_argus/nominee.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String url, mail, name = "Name is a sample", contact;
  File _cachedFile;
  static FirebaseAuth _auth = FirebaseAuth.instance;

  Future getPhoto() async {
    var user = await _auth.currentUser();
    mail = user.email;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('urlSF');
    url = stringValue;
    downloadFile();
  }

  Future getContact() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('contactSF');
    setState(() {
      contact = stringValue;
    });
  }

  Future<Null> downloadFile() async {
    final Directory tempDir = Directory.systemTemp;
    final File file = File('${tempDir.path}/$mail');

    final StorageReference ref =
        FirebaseStorage.instance.ref().child('profile/' + mail);
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);

    final int byteNumber = (await downloadTask.future).totalByteCount;

    print(byteNumber);

    setState(() => _cachedFile = file);
  }

  @override
  void initState() {
    super.initState();
    getContact();
    getPhoto();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Stack(children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: CircleAvatar(
                          backgroundColor: Colors.red[300],
                          radius: 100,
                          child: ClipOval(
                              child: SizedBox(
                            height: 185,
                            width: 185,
                            child: (_cachedFile != null)
                                ? Image.file(
                                    _cachedFile,
                                    fit: BoxFit.cover,
                                  )
                                : CircularProgressIndicator(
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.black)),
                          )))),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 180.0, right: 20, bottom: 10.0, left: 200),
                    child: IconButton(tooltip: "Edit Details",
                      icon: Icon(
                        Icons.edit,
                        color: Colors.black,
                        size: 35,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ThirdRoute()));
                      },
                    ),
                  )
                ]),
                Text(name),
                Text(contact),
              ],
            )
          ],
        ));
  }
}
