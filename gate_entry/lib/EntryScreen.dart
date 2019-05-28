import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class EntryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EntryScreenState();
  }
}

enum FormMode1 { VISITOR, SERVICE }

class EntryScreenState extends State<EntryScreen> {
  String address, name, nameService, count;
  final TextEditingController controllerName = new TextEditingController();
  final TextEditingController controllerCount = new TextEditingController();
  final TextEditingController controllerCode = new TextEditingController();
  final TextEditingController controllerAddress0 = new TextEditingController();
  final TextEditingController controllerAddress1 = new TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final _formKey = new GlobalKey<FormState>();

  List<String> serviceFlats = new List();

  BuildContext mContext;

  FormMode1 _formMode;
  String time;
  String _approval = "Waiting...";
  var submitted = false;
  var codeResult, codeType;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  var id;

  @override
  void initState() {
    super.initState();
    _formMode = FormMode1.VISITOR;
    fcmSubscribe();
  }

  void setID() async {
    await getUID();
  }

  Future<void> getUID() async {
    final FirebaseUser user = await firebaseAuth.currentUser();
    id = user.uid;
  }

  void fcmSubscribe() async {
    await getUID();
    firebaseMessaging.subscribeToTopic(id);
    print("Subscribed");
  }

  void fcmUnSubscribe() {
    firebaseMessaging.unsubscribeFromTopic(id);
  }

  void firebaseCloudMessaging_Listeners() async {
    firebaseMessaging.getToken().then((token){
      print(token);
    });

    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
          var data = message['data'];
          print(data['statusr']);
          _approval = data['statusr'];
          if (_approval == "Approved") {
            addData(address);
            Navigator.of(context).pop();
            _showDialog(context);
            await new Future.delayed(const Duration(seconds: 3));
            Navigator.of(context).pop();
            _approval = "Waiting...";
            submitted = false;
            fcmUnSubscribe();
          } else if (_approval == "Denied") {
            Navigator.of(context).pop();
            _showDialog(context);
            await new Future.delayed(const Duration(seconds: 3));
            Navigator.of(context).pop();
            _approval = "Waiting...";
            submitted = false;
            fcmUnSubscribe();
          }
        },
        onResume: (Map<String, dynamic> message) async {
          print('on resume $message');
        },
        onLaunch: (Map<String, dynamic> message) async {
          print('on launch $message');
        }
    );
  }

  void addPendingExit(String name, String address, String time) {
    databaseReference
        .child("PendingExit")
        .child(time)
        .child(address)
        .set({
      'Name': name,
    });
  }

  void addPendingApproval(String name, String address) {
    databaseReference
        .child("PendingApproval")
        .child("" + time)
        .child(address)
        .set({
      'Name': name,
    });
  }

  void removePendingApproval() {
    databaseReference
        .child("PendingApproval")
        .child("" + time)
        .remove();
  }

  void addNotificationRequestVisitor(String name, String address) {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    databaseReference
        .child("notificationRequests").child("from")
        .child("" + time)
        .set({
      'name': name,
      'flat': address,
      'time': time,
      'entrynode': id,
      'type': 1
    });
  }

  void addNotificationRequestService(String name, int time) async {
    for (int i = 0; i < serviceFlats.length; i++) {
      databaseReference
          .child("notificationRequests").child("from")
          .child((time+i).toString())
          .set({
        'name': name,
        'flat': serviceFlats[i],
        'time': time+i,
        'entrynode': id,
        'type': 2
      });
      await new Future.delayed(const Duration(seconds: 3));
    }

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
                child: Text('Second Screen'),
              ),
            ),
          ),
        ),
      ),
      body:
      Builder(builder: (context) =>
          Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                VisitorCardWidget(),
                ServiceCardWidget(),
                GenericSubmitButton("Submit", context),
                GenericSwitchButton(_formMode == FormMode1.VISITOR ? "Enter Code" : "Visitor Details", context)
              ],
            ),
          )
      ),
    );
  }

  void _switchFormToVisitor() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode1.VISITOR;
    });
  }

  void _switchFormToService() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode1.SERVICE;
    });
  }

  Widget GenericSwitchButton(String text, BuildContext mContext) {
    return RaisedButton(
      textColor: Colors.white,
      color: Colors.blue,
      onPressed:
        _formMode == FormMode1.SERVICE
            ? _switchFormToVisitor
            : _switchFormToService,

      child: new Text(text),
    );
  }

  Widget GenericSubmitButton(String text, BuildContext mContext) {
    return RaisedButton(
      textColor: Colors.white,
      color: Colors.blue,
      onPressed: () {
        onSubmit(controllerName.text, controllerAddress0.text,
            controllerAddress1.text, controllerCount.text, mContext);
      },
      child: new Text(text),
    );
  }

  Widget inputTextField(TextEditingController controller, String hint) {
    return Flexible(
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 20, top: 7, bottom: 7),
        child: new TextField(
          textAlign: TextAlign.center,
          decoration: new InputDecoration(hintText: hint),
          controller: controller,
        ),
      ),
    );
  }

  Row InputTextFieldRows(Widget inputField, String text, String hint) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Container(
          width: 50,
          height: 20,
          margin: EdgeInsets.only(left: 10, right: 20, top: 7, bottom: 7),
          child: new Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
        inputField
      ],
    );
  }

  Widget ServiceCardWidget() {
    if (_formMode == FormMode1.SERVICE) {
      Widget inputField = inputTextField(controllerCode, "Code");
      return Center(
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InputTextFieldRows(inputField, "Code:", "Code"),
            ],
          ),
        ),
      );
    } else {
      return new Container();
    }
  }

  Widget VisitorCardWidget() {
    if (_formMode == FormMode1.VISITOR) {
      Widget inputFieldName = inputTextField(controllerName, "Name");
      Widget inputFieldCount = inputTextField(controllerCount, "Count");
      return Center(
        child: Card(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InputTextFieldRows(inputFieldName, "Name:", "Name"),
              InputTextFieldRows(inputFieldCount, "Count:", "Count"),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Container(
                      width: 50,
                      height: 20,
                      margin:
                      EdgeInsets.only(left: 10, right: 20, top: 7, bottom: 7),
                      child: new Text(
                        "Address",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    inputTextField(controllerAddress0, "Wing"),
                    inputTextField(controllerAddress1, "Flat Number")
                  ]),
            ],
          ),
        ),
      );
    } else {
      return new Container();
    }
  }

  void addData(String address) {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    removePendingApproval();
    addPendingExit(name, address, time);
    databaseReference
        .child("Data").child(address).child(time).set({'Name': name, 'Count': count, 'ExitTime': "null"});
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool submitVisitor(String nameVal, String addressVal0, String addressVal1, String countVal, BuildContext context) {
      time = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      if(_validateAndSave()) {
        if (submitted) {
          print("ongoing instance");
          return false;
        } else {
          submitted = true;
          name = nameVal;
          count = countVal;
          address = addressVal0 + "-" + addressVal1;
          databaseReference
              .child("FlatAssociates")
              .once()
              .then((DataSnapshot snapshot) {
            if (snapshot.value != null) {
              for (var data in snapshot.value.keys) {
                if (address == data) {
                  addNotificationRequestVisitor(name, address);
                  addPendingApproval(name, address);
                  _showDialog(context);
                  return true;
                }
              }
            }
            _showToast(context, "Invalid Flat");
          });
        }
        return false;
      } else {
        return false;
      }
  }

  Future<void> checkCode(String code) async {
    RegExp regExp = new RegExp(
      "[A-Z][A-Z][A-Z][0-9][0-9][0-9]",
      caseSensitive: false,
      multiLine: false,
    );

    RegExp regExp1 = new RegExp(
      r"[0-9][0-9][0-9][A-Z][A-Z][A-Z]",
      caseSensitive: false,
      multiLine: false,
    );

    if(regExp.stringMatch(code) == code) {
      print("RegExp match"+code);
      codeType = 1;
      serviceFlats.clear();
      var data = await databaseReference.child("ServiceAssociates").once();
      Map<dynamic, dynamic> map = data.value;
      map.forEach((key, value) {
        if(code == key) {
          Map<dynamic, dynamic> map2 = value;
          nameService = map2['Name'];
          codeResult = true;
          for (int i = 0; i < map2.keys.length -1; i++) {
            serviceFlats.add(map2['Flat$i']);
          }
          return null;
        }
      });
    } else if(regExp1.stringMatch(code) == code) {
      codeType = 2;
      var data = await databaseReference.child("UserCodes").once();
      Map<dynamic, dynamic> map = data.value;
      map.forEach((key, value) {
        if(code == key) {
          Map<dynamic, dynamic> map2 = value;
          name = map2['Name'];
          address = map2['Address'];
          count = map2['Count'];
          codeResult = true;
        }
      });
    } else {
      codeResult = false;
      return null;
    }
  }

  void submitService (String code , BuildContext context) async {
    await checkCode(code);
      if (codeResult) {
        print(serviceFlats);
        print(nameService);
        addServiceData(code, context);
      } else {
        _showToast(mContext, "Code not valid");
      }
  }

  void addServiceData (String code, BuildContext mContext) {
    int time = DateTime.now().millisecondsSinceEpoch;

    _showToast(mContext, "Code Verified!");

    if(codeType == 1) {
      databaseReference
          .child("ServiceEntry").child(nameService).child(time.toString())
          .set({'ExitTime': "null"});
      addNotificationRequestService(nameService, time);
      addPendingExit(nameService, "Service", time.toString());
    } else if(codeType == 2) {
      databaseReference
          .child("Data").child(address.toString()).child(time.toString())
          .set(
          {
            'Name': name,
            'Count': count,
            'ExitTime': "null"
          });
      databaseReference
          .child("UserCodes").child(code).remove();
      addNotificationRequestService(name, time);
      addPendingExit(name, "Service", time.toString());
    }

    Navigator.of(context).pop();
  }

  bool onSubmit(String nameVal, String addressVal0, String addressVal1, String countVal, BuildContext context) {

    if(_validateAndSave()) {
      try {
        if (_formMode == FormMode1.VISITOR) {
          submitVisitor(nameVal, addressVal0, addressVal1, countVal, context);
        } else if (_formMode == FormMode1.SERVICE) {
          submitService((controllerCode.text).toUpperCase(), context);
        }
      } catch (e) {
        print(e);
        return false;
      }
    }
    return false;
  }

  void _showDialog(BuildContext context) {
    firebaseCloudMessaging_Listeners();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Awaiting Approval..."),
          content: new Text('$_approval'),
          actions: <Widget>[
            new FlatButton(onPressed: dialogDismiss , child: new Text("Cancel"))
          ],
        );
      },
    );
  }

  void dialogDismiss() {
    submitted = false;
    Navigator.of(context).pop();
    removePendingApproval();
    setState((){});
  }

  void _showToast(BuildContext context, String message) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: new Text(message),
        action: SnackBarAction(
            label: 'Hide', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}
