import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final List<String> countList = new List();
  final List<String> timeList = new List();
  final List<String> exitTimeList = new List();
  final List<String> flatList = new List();

  final databaseReference = FirebaseDatabase.instance.reference();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String flat, uid;

  Color firstColor = Colors.blue;
  Color secondColor = Colors.blue[400];

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
        child: _listBuilderVisitor(),
      )
    ]);
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

  Future<List<List<String>>> _getValuesVisitor() async {
    await getFlat();
    List<List<String>> finalList = new List();
    nameList.clear();
    countList.clear();
    timeList.clear();
    exitTimeList.clear();
    var data = await databaseReference.child("Data").child(flat).once();
    print("here1");
    Map<dynamic, dynamic> map = data.value;
    map.forEach((key, value) {
      Map<dynamic, dynamic> map1 = value;
      print(map1);
      nameList.add(map1['Name']);
      countList.add(map1['Count']);
      timeList.add(key);
      exitTimeList.add(map1['ExitTime']);
    });
    finalList.add(nameList);
    finalList.add(countList);
    finalList.add(timeList);
    finalList.add(exitTimeList);
    sortLists();
    return finalList;
  }

  void sortLists() {
    var tmp;
    for (int i = 0; i < timeList.length; i++) {
      for (int j = 0; j < i; j++) {
        if (int.parse(timeList[j]) < int.parse(timeList[j + 1])) {
          //timeList
          tmp = timeList[j];
          timeList[j] = timeList[j + 1];
          timeList[j + 1] = tmp;

          //nameList
          tmp = nameList[j];
          nameList[j] = nameList[j + 1];
          nameList[j + 1] = tmp;

          //exitTimeList
          tmp = exitTimeList[j];
          exitTimeList[j] = exitTimeList[j + 1];
          exitTimeList[j + 1] = tmp;
        }
      }
    }
    print(timeList);
  }

  Widget _listBuilderVisitor() {
    return new FutureBuilder(
        future: _getValuesVisitor(),
        initialData: "Loading text..",
        builder: (BuildContext context, AsyncSnapshot<Object> list) {
          print(list);
          if (list.connectionState == ConnectionState.waiting) {
            return new Center(child: CircularProgressIndicator());
          } else if (!list.hasData) {
            return new Center(
              child: new Text("No Data"),
            );
          } else {
            return new Container(
                padding: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 10),
                child: new ListView.builder(
                  itemCount: nameList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return new Card(
                        child: new ExpansionTile(
                      title: new Center(
                          child: new Text(nameList[index],
                              style: new TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 22))),
                      children: <Widget>[
                        new Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Container(
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 2, bottom: 2),
                              child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Container(
                                    padding: EdgeInsets.only(
                                        left: 0, right: 20, top: 2, bottom: 2),
                                    child: new Text("Count"),
                                  ),
                                  new Container(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 0, top: 2, bottom: 2),
                                    child: new Text(countList[index]),
                                  ),
                                ],
                              ),
                            ),
                            new Container(
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 2, bottom: 2),
                              child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Container(
                                    padding: EdgeInsets.only(
                                        left: 0, right: 20, top: 2, bottom: 2),
                                    child: new Text("Entry Time"),
                                  ),
                                  new Container(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 0, top: 2, bottom: 2),
                                    child:
                                        new Text(getDateTime(timeList[index])),
                                  ),
                                ],
                              ),
                            ),
                            new Container(
                              padding: EdgeInsets.only(
                                  left: 20, right: 20, top: 2, bottom: 2),
                              child: new Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Container(
                                    padding: EdgeInsets.only(
                                        left: 0, right: 20, top: 2, bottom: 2),
                                    child: new Text("Exit Time"),
                                  ),
                                  new Container(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 0, top: 2, bottom: 2),
                                    child: new Text(
                                        getDateTime(exitTimeList[index])),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ));
                  },
                ));
          }
        });
  }
}
