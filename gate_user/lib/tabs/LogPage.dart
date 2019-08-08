import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart';
import 'package:gate_user/pages/home_page.dart';

class LogPage extends StatefulWidget {
  LogPage({this.userid});

  final userid;

  @override
  State<StatefulWidget> createState() {
    return LogPageState();
  }
}

class LogPageState extends State<LogPage> {
  final List<String> nameList = new List();
  final List<String> phoneList = new List();

  final databaseReference = FirebaseDatabase.instance.reference();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String flat, uid;

  Color firstColor = Colors.blue;
  Color secondColor = Colors.blue[400];

  PageController controller;
  int currentpage = 0;

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  @override
  initState() {
    super.initState();
    controller = new PageController(
      initialPage: currentpage,
      keepPage: false,
      viewportFraction: 0.5,
    );
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Stack(children: <Widget>[
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
      new Container(
        child: slider(context),
      )
    ]);
  }

  Widget slider(BuildContext context){
    return new FutureBuilder(
        future: _getServiceDetails(),
        initialData: "Loading text..",
        builder: (BuildContext context, AsyncSnapshot<Object> list) {
          print(list);
          if (!list.hasData) {
            return new Center(
            );
          } else {
            return new PageView.builder(
                onPageChanged: (value) {
                  setState(() {
                    currentpage = value;
                  });
                },
                controller: controller,
                itemBuilder: (context, index) => sliderCard(index),
                itemCount: nameList.length
            );
          }
        });
  }

  sliderCard(int index) {
    return new AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double value = 1.0;
        if (controller.position.haveDimensions) {
          value = controller.page - index;
          value = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
        }

        return new Center(
          child: new SizedBox(
            height: Curves.easeOut.transform(value) * 300,
            width: Curves.easeOut.transform(value) * 250,
            child: child,
          ),
        );
      },
      child:
      new GestureDetector(
        onTap: (){
        print("Container clicked");
        },

        child: new Container(
          margin: const EdgeInsets.all(4.0),
          color: index % 2 == 0 ? Colors.blue : Colors.red,
          child:
              new Column(
                children: <Widget>[
                  new Container(
                      margin: const EdgeInsets.only(top: 35),
                      child: new Text(nameList[index], style: new TextStyle(fontSize: 32.0, color: Colors.white))
                  ),

                  new Container(
                      margin: const EdgeInsets.only(top: 66),
                    child: new Text("+91 "+ phoneList[index], style: new TextStyle(fontSize: 28.0, color: Colors.black))
                  ),


                ],
              )
        ),
      )
    );
  }

  Future<dynamic> _getServiceDetails() {
    return this._memoizer.runOnce(() async {
      await getFlat();
      List<List<String>> finalList = new List();

      nameList.clear();
      phoneList.clear();

      var data = await databaseReference.child("ServiceAssociates").once();
      Map<dynamic, dynamic> serviceCode = data.value;
      serviceCode.forEach((key, value) {
        int i = 0;
        while (value['flat$i'] != null) {
          if ((value['flat$i'].toString()).compareTo(flat) == 0) {
            phoneList.add(value['mobile_number'].toString());
            nameList.add(value['name'].toString());
          }
          i++;
        }
      });
      finalList.add(nameList);
      finalList.add(phoneList);
      return finalList;
    });
  }

  Future<void> getUID() async {
    final FirebaseUser user = await firebaseAuth.currentUser();
    uid = user.uid;
  }

  Future<void> getFlat() async {
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

  String getDateTime(String val) {
    if (val == "null") {
      return val;
    } else {
      var date = new DateTime.fromMillisecondsSinceEpoch(int.parse(val));
      var formatter = new DateFormat('hh:mm dd-MM-yyyy');
      String formatted = formatter.format(date);
      return formatted;
    }
  }
}
