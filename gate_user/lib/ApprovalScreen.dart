import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';
import 'package:gate_user/main.dart';

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

  @override
  void initState() {
    databaseReference.child("pendingApproval").onChildRemoved.listen((Event event) {
      moveScreens();
    });
    super.initState();
  }

  Future<bool> childExists() async {
    var data = await databaseReference.child("pendingApproval").child(widget.time).once();
      if (data.value == null) {
        return false;
      } else {
        return true;
      }
  }

  moveScreens() async {
    if(await childExists() == false ) {
      Navigator.of(context).pop();
    }
  }

  void _onPressedAccept() {
    addNotificationRequest("Approved");
    Navigator.of(context).pop();

  }

  void _onPressedDecline() {
    addNotificationRequest("Denied");
    Navigator.of(context).pop();
  }

  void addNotificationRequest(String status) {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
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
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Approve'),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: new Column(
          children: <Widget>[
            new Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
              child: new Text(widget.flat,  style: new TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            new Container(
              margin: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 7),
              child: new Text(widget.name+" is requesting approval"),
            ),

            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new RaisedButton(child: new Text("Accept"), onPressed: _onPressedAccept),
                new RaisedButton(onPressed: _onPressedDecline, child: new Text("Decline"),)
              ],
            )
          ],
        )
      )
    );
  }
}