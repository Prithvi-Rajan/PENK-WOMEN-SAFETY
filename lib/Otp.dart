import 'dart:ffi';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'form.dart';

class OTP extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OTPSTATE();
  }
}

class OTPSTATE extends State {
  String phoneno;
  String smscode;
  String verificationid;
  Future<Void> verify() async {
    time() {
      final PhoneCodeAutoRetrievalTimeout verify = (String id) {
        verificationid = id;
      };
    }

    sent() {
      final PhoneCodeSent send = (String iid, [int a]) {
        verificationid = iid;
      };
    }

    verifyok() {
      final PhoneVerificationCompleted = (FirebaseUser user) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ThirdRoute()));
      };
    }

    verifyno() {
      addStringToSF(phoneno);
      final PhoneVerificationCompleted = (AuthException exception) {
        Toast.show('Verification Failed $exception', context,
            duration: Toast.LENGTH_LONG, gravity: Toast.CENTER);
      };
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneno,
        codeAutoRetrievalTimeout: time(),
        codeSent: sent(),
        timeout: Duration(seconds: 60),
        verificationCompleted: verifyok(),
        verificationFailed: verifyno());
  
  }

  Future<bool> dialog(BuildContext context){
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        title:Text('Enter OTP code');
        content: TextField(
          onChanged: (value){
            this.smscode=value;
          },
        );
        contenPadding:EdgeInsets.all(10.0);
        action:<Widget>
        {
          new FlatButton(
            child:Text('verified'),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ThirdRoute()));
            },
          )
        };
             
      });
  }

  addStringToSF(String val) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('contactSF', val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(title: Text("Argus")),
      body: Column(
        children: <Widget>[
          Text(
            'argus.',
            style: TextStyle(color: Colors.red[400], fontSize: 108.0),
          ),
          TextField(
              onChanged: (value) {
                this.phoneno = value;
              },
              decoration: InputDecoration(hintText: 'Enter you phone number')),
          SizedBox(
            height: 10.0,
          ),
          RaisedButton(
            onPressed: () {
              verify();
            },
          )
        ],
      ),
    );
  }
}
