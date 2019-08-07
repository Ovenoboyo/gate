import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gate_user/tabs/CodeGen.dart';
import 'package:gate_user/tabs/ProfilePage.dart';
import 'dart:async';
import 'login_signup_page.dart';
import 'package:gate_user/services/authentication.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:gate_user/ApprovalScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:gate_user/tabs/LogPage.dart';

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

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final databaseReference = FirebaseDatabase.instance.reference();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FirebaseMessaging firebaseMessaging = new FirebaseMessaging();

  var vibrationPattern = Int64List(4);
  var name, time, flat, id, userid, type;

  Color firstColor = Color(0xFFF47D15);
  Color secondColor = Color(0xFFEF772C);

  int _currentIndex = 0;

  final List<Widget> _children = new List();

  @override
  void initState() {
    super.initState();
    fcmSubscribe();
    firebaseCloudMessaging_Listeners();
    print(widget.userId);
    _children.add(LogPage(userid: widget.userId));
    _children.add(CodeGen(userid: widget.userId));
    _children.add(ProfilePage());
  }

  Future<void> getUID() async {
    final FirebaseUser user = await firebaseAuth.currentUser();
    userid = user.uid;
  }

  Future<void> confirmFlat() async {
    await getUID();
    var data = await databaseReference.child("FlatAssociates").once();
    Map<dynamic, dynamic> map = data.value;
    map.forEach((key, value) {
      Map<dynamic, dynamic> map1 = value;
      map1.forEach((key1, value1) {
        if (value1 == widget.userId) {
          flat = key;
        }
      });
    });
    //print(flat);
  }

  void fcmSubscribe() async {
    await confirmFlat();
    firebaseMessaging.subscribeToTopic(flat);
    print("Subscribed");
  }

  void fcmUnSubscribe() {
    firebaseMessaging.unsubscribeFromTopic(flat);
  }

  void firebaseCloudMessaging_Listeners() {
    if (Platform.isIOS) iOS_Permission();

    firebaseMessaging.getToken().then((token) {
      print(token);
    });

    firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
      print('on message $message');
      var data = message['data'];
      name = data['name'];
      flat = data['flat'];
      time = data['time'];
      id = data['entrynode'];
      type = data['type'];
      print(data['type']);

      if (type == "1") {
        pushNotification1((data['name']), (data['time']), (data['flat']));
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return new ApprovalScreen(
              data['name'], data['time'], data['flat'], data['entrynode']);
        }));
      } else if (type == "2") {
        pushNotification2((data['name']), (data['time']), (data['flat']));
      }
    }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
    });
  }

  Future onDidReceiveLocalNotification(
      int i, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
            title: new Text(title),
            content: new Text(body),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: new Text('Ok'),
                onPressed: () async {
                  Navigator.of(context, rootNavigator: true).pop();
                  await Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) =>
                          new ApprovalScreen(name, time, flat, id),
                    ),
                  );
                },
              )
            ],
          ),
    );
  }

  String getDateTime(String val) {
    if (val.isEmpty) {
      return val;
    } else {
      var date = new DateTime.fromMillisecondsSinceEpoch(int.parse(val));
      var formatter = new DateFormat('hh:mm, dd-MM-yyyy');
      String formatted = formatter.format(date);
      return formatted;
    }
  }

  pushNotification1(String name, String time, String flat) async {
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'org.sahil.gupte.gate_user.HeadsUpChannel',
        'Visitor Entry',
        'Only for Headsup',
        importance: Importance.High,
        priority: Priority.High,
        ticker: '$name Needs Approval',
        ongoing: true,
        autoCancel: false,
        vibrationPattern: vibrationPattern);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        flat,
        name + " is requesting approval at " + getDateTime(time),
        platformChannelSpecifics,
        payload: 'item x');
  }

  pushNotification2(String name, String time, String flat) async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'org.sahil.gupte.gate_user.normalChannel',
        'Service Entry',
        'Only for normal',
        importance: Importance.Default,
        priority: Priority.Default,
        ticker: '$name Service',
        autoCancel: false);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        flat,
        name + " has entered the premises at " + getDateTime(time),
        platformChannelSpecifics,
        payload: 'item x');
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    Navigator.popUntil(
        context, ModalRoute.withName(Navigator.defaultRouteName));
    await Navigator.push(
      context,
      new MaterialPageRoute(
          builder: (context) => new ApprovalScreen(name, time, flat, id)),
    );
  }

  void iOS_Permission() {
    firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
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
          content:
              new Text("Link to verify account has been sent to your email"),
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
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return new LoginSignUpPage(
        auth: widget.auth,
        onSignedIn: _onSignedup,
        formMode: FormMode.SIGNUP,
      );
    }));
  }

  void _onSignedup() {}

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
      fcmUnSubscribe();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkEmailVerification();
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('Gate User'),
        actions: <Widget>[
          new FlatButton(
              child: new Text('Logout',
                  style: new TextStyle(fontSize: 17.0, color: Colors.white)),
              onPressed: _signOut)
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            title: Text("Code"),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

class CustomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0.0, size.height);

    var firstEndPoint = Offset(size.width * .5, size.height - 30.0);
    var firstControlpoint = Offset(size.width * 0.25, size.height - 50.0);
    path.quadraticBezierTo(firstControlpoint.dx, firstControlpoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondEndPoint = Offset(size.width, size.height - 80.0);
    var secondControlPoint = Offset(size.width * .75, size.height - 10);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => true;
}
