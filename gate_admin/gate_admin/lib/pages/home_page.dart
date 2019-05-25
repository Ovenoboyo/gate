import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'login_signup_page.dart';
import 'package:gate_admin/services/authentication.dart';

import 'service_create_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isEmailVerified = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      //_showVerifyEmailDialog();
    }
  }



  void _resentVerifyEmail(){
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Please verify account in the link sent to email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Resent link"),
              onPressed: () {
                Navigator.of(context).pop();
                _resentVerifyEmail();
              },
            ),
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onRegisterUser() {
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return new LoginSignUpPage(auth: widget.auth, onSignedIn: _onSignedup, formMode: FormMode.SIGNUP, flatUser: true,);
    })
    );
  }

  void onRegisterService() {
    Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) {
      return new ServiceCreatePage ();
    })
    );
  }

  void _onSignedup() {

  }
  
  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    _checkEmailVerification();
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter login demo'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: _signOut)
          ],
        ),
        body: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new RaisedButton(onPressed: onRegisterUser),
            new RaisedButton(onPressed: onRegisterService),
          ],
        )
    );
  }
}
