import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_string/random_string.dart';
import 'package:gate_user/pages/home_page.dart';

class CodeGen extends StatefulWidget {
  CodeGen({this.userid});

  String userid;

  @override
  State<StatefulWidget> createState() {
    return CodeGenState();
  }
}

class CodeGenState extends State<CodeGen> {
  TextEditingController _controllerName = new TextEditingController();
  TextEditingController _controllerCount = new TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  var flat, uid;

  Color firstColor = Colors.blue;
  Color secondColor = Colors.blue[400];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFlat();
  }

  Future<void> getUID() async {
    final FirebaseUser user = await firebaseAuth.currentUser();
    uid = user.uid;
  }

  void getFlat() async {
    await getUID();
    var data = await databaseReference.child("FlatAssociates").once();
    Map<dynamic, dynamic> map = data.value;
    map.forEach((key, value) {
      Map<dynamic, dynamic> map1 = value;
      map1.forEach((key1, value1) {
        if (value1 == uid) {
          flat = key;
        }
      });
    });
    print(flat);
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(
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
        new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[codeCard(), genericSubmitButton("Generate Code")],
        )
      ],
    );
  }

  Widget genericSubmitButton(String text) {
    return new Center(
        child: RaisedButton(
          textColor: Colors.white,
          color: Colors.blue[900],
          onPressed: () {
            _onSubmit(_controllerName.text, _controllerCount.text);
            },
          child: new Text(text),
    ));
  }

  Widget codeCard() {
    return new Card(
        child: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        inputField("Name:", "Name", _controllerName),
        inputField("Number of people:", "Count", _controllerCount)
      ],
    ));
  }

  Widget inputField(
      String text, String hint, TextEditingController controller) {
    return new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Expanded(
              flex: 4,
              //margin: EdgeInsets.only(left: 10, right: 20, top: 7, bottom: 7),
              child: new Container(
                margin: EdgeInsets.only(left: 10, right: 20, top: 7, bottom: 7),
                child: new Text(text),
              )),
          new Expanded(
              flex: 7,
              child: new Container(
                margin:
                    EdgeInsets.only(left: 10, right: 20, top: 7, bottom: 10),
                child: new TextField(
                  textAlign: TextAlign.center,
                  decoration: new InputDecoration(hintText: hint),
                  controller: controller,
                ),
              ))
        ],
      ),
    );
  }

  void _onSubmit(String name, String count) {
    var code = (randomNumeric(3) + randomAlpha(3)).toUpperCase();
    databaseReference
        .child("UserCodes")
        .child(code)
        .set({'Name': name, 'Count': count, 'Address': flat});
    _showDialog(context, code);
  }

  void _showDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Your Code is:"),
          content: new Text(
            code,
            style: new TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            new FlatButton(
                onPressed: () {
                  copyToClipboard(code);
                },
                child: new Text("Copy")),
            new FlatButton(onPressed: dialogDismiss, child: new Text("Okay")),
          ],
        );
      },
    );
  }

  void dialogDismiss() {
    setState(() {
      Navigator.of(context).pop();
      _controllerName.clear();
      _controllerCount.clear();
    });
  }

  void copyToClipboard(String code) {
    Clipboard.setData(ClipboardData(text: code));.then((result) {
      final snackBar = SnackBar(
        content: Text('Copied to Clipboard'),
        action: SnackBarAction(
          label: 'Okay',
          onPressed: () {},
        ),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }
}
