import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_argus/four.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:toast/toast.dart';
import 'Otp.dart';
import 'form.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<String> _testSignInWithGoogle() async {
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;

    // assert(user.email != null);
    // assert(user.displayName != null);
    // assert(!user.isAnonymous);
    // assert(await user.getIdToken() != null);

    //final FirebaseUser currentUser = await _auth.currentUser();
    // assert(user.uid == currentUser.uid);
    Toast.show("Login Successful", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ThirdRoute()));

    return 'signInWithGoogle succeeded: $user';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseUser>(
        future: FirebaseAuth.instance.currentUser(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.hasData) {
            return Four();
          }
          // other way there is no user logged.
          else
            return Scaffold(
                backgroundColor: Colors.black87,
                appBar: AppBar(
                  title: Text("Argus"),
                ),
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      'argus.',
                      style: TextStyle(color: Colors.red[400], fontSize: 108.0),
                    ),
                    Center(
                      child: FlatButton.icon(
                          color: Colors.blue[400],
                          textColor: Colors.white,
                          icon: Image.asset(
                            'res/google_logo.png',
                            width: 20,
                          ),
                          label: Text('SIGN IN WITH GOOGLE'),
                          onPressed: () {
                            _testSignInWithGoogle();
                          }),
                    ),
                  ],
                ));
        });
  }
}
