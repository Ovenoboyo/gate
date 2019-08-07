import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:gate_user/main.dart';
import 'package:gate_user/pages/home_page.dart';
import 'package:gate_user/model/swipe_button.dart';

class ApprovalScreen extends StatefulWidget {

  var name, time, flat, id;

  @override
  State<StatefulWidget> createState() {
    return ApprovalScreenState();
  }

  ApprovalScreen(String name, String time, String flat, String id) {
    print(name);
    this.name = name;
    this.time = time;
    this.flat = flat;
    this.id = id;
  }
}

class ApprovalScreenState extends State<ApprovalScreen> {

  final databaseReference = FirebaseDatabase.instance.reference();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  Color firstColor = Colors.blue;
  Color secondColor = Colors.blue[400];

  @override
  void initState() {
    databaseReference
        .child("pendingApproval")
        .onChildRemoved
        .listen((Event event) {
      moveScreens();
    });
    super.initState();
  }

  Future<void> cancelNotifs() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<bool> childExists() async {
    var data = await databaseReference.child("pendingApproval").child(
        widget.time).once();
    if (data.value == null) {
      return false;
    } else {
      return true;
    }
  }

  moveScreens() async {
    if (await childExists() == false) {
      Navigator.of(context).pop();
    }
  }

  void _onPressedAccept() {
    addNotificationRequest("Approved");
    cancelNotifs();
    Navigator.of(context).pop();
  }

  void _onPressedDecline() {
    addNotificationRequest("Denied");
    cancelNotifs();
    Navigator.of(context).pop();
  }

  void addNotificationRequest(String status) {
    String time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    databaseReference
        .child("notificationRequests")
        .child("to")
        .child("" + time)
        .set({
      'statusr': status,
      'entrynode': widget.id
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Approve Entry'),
        ),
        body: Stack(
          children: <Widget>[
            ClipPath(
              clipper: CustomShapeClipper(),
              child: Container(
                height: 400.0,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [firstColor, secondColor],
                  ),
                ),
              ),
            ),
            Center(
                child: new Column(
                  children: <Widget>[
                    new Container(
                      margin: EdgeInsets.only(
                          left: 10, right: 10, top: 20, bottom: 10),
                      child: new Text(widget.flat, style: new TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    new Container(
                      margin: EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 50),
                      child: new Text(widget.name + " is requesting approval", style: new TextStyle(color: Colors.white)),
                    ),

                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                        child: SwipeButton(
                          thumb: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Align(widthFactor: 0.33, child: Icon(Icons.radio_button_unchecked)),
                            ],
                          ),
                          content: Center(
                            child: Text(''),
                          ),
                          onChanged: (result) {
                            if (result == SwipePosition.SwipeLeft) {
                              _onPressedDecline();
                            } else if( result == SwipePosition.SwipeRight) {
                              _onPressedAccept();
                            }
                          },
                        ),
                        )
                      ],
                    )
                  ],
                )
            )

          ],
        ));
  }
}