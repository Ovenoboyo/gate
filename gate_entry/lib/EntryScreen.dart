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

class EntryScreenState extends State<EntryScreen> {
  String address, name;
  final TextEditingController controllerName = new TextEditingController();
  final TextEditingController controllerAddress0 = new TextEditingController();
  final TextEditingController controllerAddress1 = new TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  String _approval = "Waiting...";
  var submitted = false;

  var id = "1";

  void fcmSubscribe() {
    firebaseMessaging.subscribeToTopic(id);
    print("Subscribed");
  }

  void fcmUnSubscribe() {
    firebaseMessaging.unsubscribeFromTopic("entry_"+id);
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

  void addPendingExit(String name, String address) {
    databaseReference
        .child("PendingExit")
        .child("" + DateTime.now().millisecondsSinceEpoch.toString())
        .child(address)
        .set({
      'Name': name,
    });
  }

  void addPendingApproval(String name, String address) {
    databaseReference
        .child("PendingApproval")
        .child("" + DateTime.now().millisecondsSinceEpoch.toString())
        .child(address)
        .set({
      'Name': name,
    });
  }

  void addNotificationRequest(String name, String address) {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    databaseReference
        .child("notificationRequests").child("from")
        .child("" + time)
        .set({
      'name': name,
      'flat': address,
      'time': time,
      'entrynode': id
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
                child: Text('Second Screen'),
              ),
            ),
          ),
        ),
      ),
      body: Builder(builder: (context) =>
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[MainCardWidget(), GenericButton("Submit", context)],
        ),
      ),
    );
  }

  Widget GenericButton(String text, BuildContext mContext) {
    return RaisedButton(
      textColor: Colors.white,
      color: Colors.blue,
      onPressed: () {
        onSubmit(controllerName.text, controllerAddress0.text,
            controllerAddress1.text, mContext);
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

  Widget MainCardWidget() {
    Widget inputField = inputTextField(controllerName, "Name");
    return Center(
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InputTextFieldRows(inputField, "Name:", "Name"),
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
  }

  void addData(String address) {
    databaseReference
        .child("Data").child(address).child("" + DateTime
        .now()
        .millisecondsSinceEpoch
        .toString()).set({'Name': name, 'ExitTime': "null"});
  }

  bool onSubmit(String nameVal, String addressVal0, String addressVal1, BuildContext context) {
    if (submitted) {
      print("ongoing instance");
      return false;
    } else {
      submitted = true;
      name = nameVal;
      address = addressVal0 + "-" + addressVal1;
      //print(name);
      databaseReference
          .child("FlatAssociates")
          .once()
          .then((DataSnapshot snapshot) {
        if (snapshot.value != null) {
          for (var data in snapshot.value.keys) {
            if (address == data) {
              addPendingExit(name, address);
              addNotificationRequest(name, address);
              addPendingApproval(name, address);
              _showDialog(context);
              return true;
            }
          }
        }
        _showToast(context);
      });
      return false;
    }
  }

  void _showDialog(BuildContext context) {
    fcmSubscribe();
    firebaseCloudMessaging_Listeners();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Awaiting Approval..."),
          content: new Text('$_approval'),
        );
      },
    );
  }

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('No such house'),
        action: SnackBarAction(
            label: 'Hide', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }
}
