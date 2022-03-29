import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:the_argus/map.dart';
import 'package:toast/toast.dart';
import 'models/subject-model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Track extends StatefulWidget {
  @override
  _TrackState createState() => _TrackState();
}

class _TrackState extends State<Track> {
  String contact;
  final DatabaseReference locUpdate = FirebaseDatabase.instance.reference();
  List<Widget> subjectWidget = [];

  @override
  void initState() {
    super.initState();
    getValuesSF();
  }

  getValuesSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('contactSF');
    contact = stringValue;

    getUserAmount();
  }

  getUserAmount() async {
    final response =
        await locUpdate.child("subjects/$contact/subjects/").once();

    List<SubjectModel> users = [];

    Map<dynamic, dynamic> s = response.value;
    s.forEach((k, v) {
      users.add(createSubjectModel(v));
    });
    print(users.length);
    setState(() {
      for (SubjectModel item in users) {
        subjectWidget.add(Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              MapPage(item.mobile.toString())));
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.yellow[300],
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 40,
                        width: 300,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                          child: Text(
                            item.name,
                            style: TextStyle(color: Colors.black, fontSize: 22),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.mobile.toString(),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Container(
            color: Colors.yellow[300],
            child: Center(
              child: ListTile(
                  title: Center(
                      child: Text(
                'Select to Track',
                style: TextStyle(color: Colors.black, fontSize: 24),
              ))),
            ),
            height: 80.0,
          ),
          Column(
            children: subjectWidget,
          ),
        ],
      ),
    );
  }
}
