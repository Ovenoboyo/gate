import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

String username, userid, useremail, userphotourl;

class ProfilePage extends StatefulWidget {
  ProfilePageState createState() => new ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  var email, name, uid;

  bool loggedIn = false;
  Future<Null> _function() async {
    await inputData();
    this.setState(() {
      loggedIn = true;
      username = name;
      userid = uid;
      useremail = email;
      userphotourl = "https://i.imgur.com/Upq2ElC.png";
    });
  }

  Future<void> inputData() async {
    final FirebaseUser user = await firebaseAuth.currentUser();
    uid = user.uid;
    name = user.displayName;
    email = user.email;
  }

  @override
  Widget build(BuildContext context) {
   print(username);
   print(userid);
   print(useremail);
   print(userphotourl);
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("Profile"),
        ),
        body: new Container(
          alignment: Alignment.center,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(16.0),
                child: new FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: userphotourl,
                  height: 250.0,
                  width: 250.0,
                  fadeInDuration: const Duration(milliseconds: 1000),
                  alignment: Alignment.topCenter,
                  fit: BoxFit.contain,
                ),
              ),
              new Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 8.0),
                child: new Text(
                  username,
                  style: new TextStyle(
                      fontSize: 22.0, fontWeight: FontWeight.bold),
                ),
              ),
              new Text(
                useremail,
                style: new TextStyle(fontSize: 18.0,color: Colors.blueAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    this._function();
  }
}