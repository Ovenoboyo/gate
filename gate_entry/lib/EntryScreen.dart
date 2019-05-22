import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

  void addPendingExit(String name, String address) {
    databaseReference
        .child("PendingExit")
        .child("" + DateTime.now().millisecondsSinceEpoch.toString())
        .child(address)
        .set({
      'Name': name,
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

  bool onSubmit(String nameVal, String addressVal0, String addressVal1, BuildContext context) {
    name = nameVal;
    address = addressVal0 + "-" + addressVal1;
    //print(name);
    databaseReference
        .child("FlatAssociates")
        .once()
        .then((DataSnapshot snapshot) {
          if(snapshot.value != null) {
            for (var data in snapshot.value.keys) {
              if (address == data) {
                databaseReference
                    .child("Data").child(address).child("" + DateTime
                    .now()
                    .millisecondsSinceEpoch
                    .toString()).set({'Name': name, 'Exit': "null"});
                addPendingExit(name, address);
                return true;
              }
            }
          }
          _showToast(context);
    });
    return false;
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
