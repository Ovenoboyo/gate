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
  String address, name;
  final TextEditingController controllerName = new TextEditingController();
  final TextEditingController controllerCode = new TextEditingController();
  final TextEditingController controllerAddress0 = new TextEditingController();
  final TextEditingController controllerAddress1 = new TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();
  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();
  final _formKey = new GlobalKey<FormState>();

  FormMode1 _formMode;
  String time;
  String _approval = "Waiting...";
  var submitted = false;
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
            //fcmUnSubscribe();
          } else if (_approval == "Denied") {
            Navigator.of(context).pop();
            _showDialog(context);
            await new Future.delayed(const Duration(seconds: 3));
            Navigator.of(context).pop();
            _approval = "Waiting...";
            submitted = false;
            //fcmUnSubscribe();
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
      body:
      Builder(builder: (context) =>
        Column(
          key: _formKey,
          mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              VisitorCardWidget(),
              ServiceCardWidget(),
              GenericSubmitButton("Submit", context),
              GenericSwitchButton(_formMode == FormMode1.VISITOR ? "Enter Code" : "Visitor Details", context)
          ],
        ),
      ),
    );
  }

  void _switchFormToVisitor() {
    //_formKey.currentState.reset();
    setState(() {
      _formMode = FormMode1.VISITOR;
    });
  }

  void _switchFormToService() {
    //_formKey.currentState.reset();
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
    } else {
      return new Container();
    }
  }

  void addData(String address) {
    removePendingApproval();
    addPendingExit(name, address);
    databaseReference
        .child("Data").child(address).child("" + DateTime
        .now()
        .millisecondsSinceEpoch
        .toString()).set({'Name': name, 'ExitTime': "null"});
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool submitVisitor(String nameVal, String addressVal0, String addressVal1, BuildContext context) {
      time = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString();
      if (submitted) {
        print("ongoing instance");
        return false;
      } else {
        submitted = true;
        name = nameVal;
        address = addressVal0 + "-" + addressVal1;
        databaseReference
            .child("FlatAssociates")
            .once()
            .then((DataSnapshot snapshot) {
          if (snapshot.value != null) {
            for (var data in snapshot.value.keys) {
              if (address == data) {
                addNotificationRequest(name, address);
                addPendingApproval(name, address);
                _showDialog(context);
                return true;
              }
            }
          }
          _showToast(context);
        });
      }
      return false;
  }

  bool onSubmit(String nameVal, String addressVal0, String addressVal1, BuildContext context) {

    if(_validateAndSave()) {
      try {
        if (_formMode == FormMode1.VISITOR) {
          submitVisitor(nameVal, addressVal0, addressVal1, context);
        } else if (_formMode == FormMode1.SERVICE) {
          //service code
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
    //TODO: Remove pending approvals
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
