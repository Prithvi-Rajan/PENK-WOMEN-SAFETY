import 'package:flutter/material.dart';
import 'package:the_argus/four.dart';
import 'package:toast/toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:contact_picker/contact_picker.dart';
import 'four.dart';

class Nominee extends StatefulWidget {
  String contact;
  Nominee(this.contact);
  @override
  State<StatefulWidget> createState() {
    return Nom(contact);
  }
}

class Nom extends State<Nominee> {
  String name;
  String nome, contact;
  int count = 0;

  Nom(this.contact);

  final DatabaseReference nomCheck = FirebaseDatabase.instance.reference();

  final ContactPicker _contactPicker = new ContactPicker();

  void toastmsg(String msg) {
    Toast.show(msg, context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }

  Future check(String nomid) async {
    nomCheck.child('subjects/' + nomid).once().then((DataSnapshot data) {
      if (data.value != null) {
        nomCheck
            .child('subjects/' + contact + '/name')
            .once()
            .then((DataSnapshot nam) {
          name = nam.value.toString();
        });

        nomCheck
            .child('subjects/' + contact + '/nominees/' + nomid)
            .set('nominee');
        DatabaseReference keystore =
            nomCheck.child('subjects/' + nomid + '/subjects/');
        keystore.push().set({
          'mobile': contact,
          'name': 'name',
        });

        toastmsg("Nominee addded!");
        count++;
      } else {
        toastmsg("Nominee not found!");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          title: Text("Nominees"),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Text(
                  'argus.',
                  style: TextStyle(color: Colors.red[400], fontSize: 108.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 50, left: 15, right: 15, bottom: 15),
                child: TextField(
                  cursorColor: Colors.red,
                  maxLength: 10,
                  onChanged: (text) {
                    nome = text;
                  },
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: "Nominee Number",
                      suffixIcon: IconButton(
                        icon: Icon(
                          (Icons.contacts),
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          Contact contact1 =
                              await _contactPicker.selectContact();
                          String num1 = contact1.phoneNumber.number.toString();
                          String num2 = num1.substring(num1.length - 11);
                          check(num2.replaceAll(new RegExp(r"\s+\b|\b\s"), ""));
                        },
                      ),
                      labelStyle: TextStyle(color: Colors.red),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: RaisedButton(
                  child: Text(
                    "Add",
                    style: TextStyle(color: Colors.black87),
                  ),
                  color: Colors.red[400],
                  onPressed: () {
                    check(nome);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: RaisedButton(
                  child: Text("Finish"),
                  onPressed: () {
                    if (count > 0) {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => Four()));
                    } else {
                      toastmsg("Please Add a Nominee!");
                    }
                  },
                  color: Colors.red[400],
                ),
              )
            ],
          ),
        ));
  }
}
