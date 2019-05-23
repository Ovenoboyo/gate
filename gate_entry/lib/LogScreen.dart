import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(new LogScreen());
}

class LogScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return LogScreenState();
  }
}

class LogScreenState extends State<LogScreen> {
  final databaseReference = FirebaseDatabase.instance.reference();

  List<String> nameList = new List();
  List<String> timeList = new List();
  List<String> exitTimeList = new List();
  List<String> flatList = new List();
  List<String> uniqueList = new List();
  List<List<int>> finalPositionList = new List();

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
                  child: Text('Log Screen'),
                ),
              ),
            ),
          ),
        ),
        body: ListBuilder()
    );
  }

  String getDateTime(String val) {
    if (val == "null") {
      return val;
    } else {
      //print(val);
      var date = new DateTime.fromMillisecondsSinceEpoch(int.parse(val));
      //print(date);
      var formatter = new DateFormat('HH:MM dd-MM-yyyy');
      String formatted = formatter.format(date);
      return formatted;
    }
  }

  Future<List<List<String>>> getValues() async {
    List<List<String>> finalList = new List();
    flatList.clear();
    nameList.clear();
    timeList.clear();
    exitTimeList.clear();
    var data = await databaseReference.child("Data").once();
    Map<dynamic, dynamic> map = data.value;
    map.forEach((key, value) {
      Map<dynamic, dynamic> map1 = value;
      map1.forEach((key1, value1) {
        flatList.add(key);
        //print(key);
        timeList.add(key1);
        //print(key1);
        Map<dynamic, dynamic> map2 = value1;
        map2.forEach((key2, value2) {
          if (key2 == "Name") {
            nameList.add(value2);
          } else if (key2 == "ExitTime") {
            exitTimeList.add(value2);
          }
        });
      });
    });
    print(exitTimeList);
    finalList.add(flatList);
    finalList.add(nameList);
    finalList.add(timeList);
    finalList.add(exitTimeList);
    return finalList;
  }

  @override
  void initState() {
    super.initState();
  }

  Widget ListBuilder() {
    return new FutureBuilder(
        future: getValues(),
        initialData: "Loading text..",
        builder: (BuildContext context, AsyncSnapshot<Object> list) {
          sortList();

          if(!list.hasData) {
            return new Center(
              child: new Text("No Data"),
            );
          } else {
            return new Container(
              child: new ListView.builder(
                itemCount: uniqueList.length,
                itemBuilder: (BuildContext context, int index) {
                  return new ExpansionTile(
                    title: new Text(
                      uniqueList[index],
                      style: new TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: <Widget>[
                      new ListView.builder(
                          shrinkWrap: true,
                          itemCount: finalPositionList[index].length,
                          itemBuilder: (BuildContext context, int index1) {
                            return new ExpansionTile(
                              title: new Center(
                                  child: new Text((nameList[
                                  (finalPositionList[index][index1])]))),
                              children: <Widget>[
                                new Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 20, top: 7, bottom: 7),
                                  child: new Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      new Text("Entry Time:"),
                                      new Text(getDateTime(timeList[
                                      (finalPositionList[index][index1])]))
                                    ],
                                  ),
                                ),
                                new Container(
                                  padding: EdgeInsets.only(
                                      left: 10, right: 20, top: 7, bottom: 7),
                                  child: new Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      new Text("Exit Time:"),
                                      new Text(getDateTime(
                                          exitTimeList[(finalPositionList[index][index1])]))
                                    ],
                                  ),
                                ),
                              ],
                            );
                          })
                    ],
                  );
                },
              ),
            );
          }
        });
  }

  void sortList() {
    uniqueList.clear();
    for (int i = 0; i < flatList.length; i++) {
      if (!uniqueList.contains(flatList[i])) {
        uniqueList.add(flatList[i]);
      }
    }
    for (int i = 0; i < uniqueList.length; i++) {
      List<int> positionList = new List();
      for (int j = 0; j < flatList.length; j++) {
        if (uniqueList[i] == flatList[j]) {
          positionList.add(j);
        }
      }
      finalPositionList.add(positionList);
    }
  }
}
