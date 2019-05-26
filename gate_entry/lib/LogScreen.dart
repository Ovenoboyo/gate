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

enum FormMode2 { VISITOR, SERVICE }

class LogScreenState extends State<LogScreen> {
  final databaseReference = FirebaseDatabase.instance.reference();

  FormMode2 _formMode;
  final _formKey = new GlobalKey<FormState>();

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
          actions: <Widget>[
            new FlatButton(
                onPressed: _formMode == FormMode2.VISITOR
                    ? _switchFormToService
                    : _switchFormToVisitor,
                child: _formMode == FormMode2.VISITOR
                    ? new Text("Service",
                        style:
                            new TextStyle(fontSize: 17.0, color: Colors.white))
                    : new Text("Visitor",
                        style:
                            new TextStyle(fontSize: 17.0, color: Colors.white)))
          ],
        ),
        body: Form(
          key: _formKey,
          child: _formMode == FormMode2.VISITOR
              ? _listBuilderVisitor()
              : _listBuilderService(),
        ));
  }

  void _switchFormToVisitor() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode2.VISITOR;
    });
  }

  void _switchFormToService() {
    _formKey.currentState.reset();
    setState(() {
      _formMode = FormMode2.SERVICE;
    });
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

  Future<List<List<String>>> _getFinalValues() async {
    if (_formMode == FormMode2.VISITOR) {
      return await _getValuesVisitor();
    } else if (_formMode == FormMode2.SERVICE) {
      return await _getValuesService();
    } else {
      return new List<List<String>>();
    }
  }

  Future<List<List<String>>> _getValuesVisitor() async {
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
        timeList.add(key1);
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
    finalList.add(flatList);
    finalList.add(nameList);
    finalList.add(timeList);
    finalList.add(exitTimeList);
    return finalList;
  }

  Future<List<List<String>>> _getValuesService() async {
    List<List<String>> finalList = new List();
    nameList.clear();
    timeList.clear();
    exitTimeList.clear();
    var data = await databaseReference.child("ServiceEntry").once();
    Map<dynamic, dynamic> map = data.value;
    map.forEach((key, value) {
      Map<dynamic, dynamic> map1 = value;
      map1.forEach((key1, value1) {
        nameList.add(key);
        timeList.add(key1);
        exitTimeList.add(value1['ExitTime']);
      });
    });
    finalList.add(nameList);
    finalList.add(timeList);
    finalList.add(exitTimeList);
    return finalList;
  }

  @override
  void initState() {
    super.initState();
    _formMode = FormMode2.VISITOR;
  }

  Widget _listBuilderVisitor() {
    return new FutureBuilder(
        future: _getFinalValues(),
        initialData: "Loading text..",
        builder: (BuildContext context, AsyncSnapshot<Object> list) {
          _sortList(flatList);
          if (!list.hasData) {
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
                                      new Text(getDateTime(exitTimeList[
                                          (finalPositionList[index][index1])]))
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

  Widget _listBuilderService() {
    return new FutureBuilder(
        future: _getFinalValues(),
        initialData: "Loading text..",
        builder: (BuildContext context, AsyncSnapshot<Object> list) {
          _sortList(nameList);
          if (!list.hasData) {
            return new Center(
              child: new Text("No Data"),
            );
          } else {
            return new Container(
                child: new ListView.builder(
                    itemCount: uniqueList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new ExpansionTile(
                        title: new Center(
                          child: new Text(
                              uniqueList[index],
                              style: new TextStyle(fontWeight: FontWeight.bold)
                          ),
                        ),
                        children: <Widget>[
                          new ListView.builder(
                              shrinkWrap: true,
                              itemCount: timeList.length,
                              itemBuilder: (BuildContext context, int index1) {
                                return new Container(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 20, top: 7, bottom: 7),
                                    child: new Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    new Container(
                                      child: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          new Container(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 20, top: 2, bottom: 2),
                                            child: new Text("Entry Time"),
                                          ),
                                          new Container(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 20, top: 2, bottom: 2),
                                          child: new Text(getDateTime(timeList[
                                              finalPositionList[index]
                                                  [index1]]))
                                          ),
                                        ],
                                      ),
                                    ),
                                    new Container(
                                      child: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          new Container(
                                            padding: EdgeInsets.only(
                                                left: 10, right: 20, top: 2, bottom: 2),
                                            child: new Text("Exit Time"),
                                          ),
                                          new Container(
                                              padding: EdgeInsets.only(
                                                  left: 10, right: 20, top: 2, bottom: 2),
                                          child: new Text(getDateTime(exitTimeList[
                                              finalPositionList[index]
                                                  [index1]]))
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ));
                              })
                        ],
                      );
                    }));
          }
        });
  }

  void _sortList(List<String> list) {
    if(_formMode == FormMode2.SERVICE) {
      var tmp;
      for(int i = 0; i<timeList.length; i++) {
        for (int j = 0; j<i; j++) {
          if(int.parse(timeList[j]) > int.parse(timeList[j+1])) {

            //timeList
            tmp = timeList[j];
            timeList[j] = timeList[j+1];
            timeList[j+1] = tmp;

            //nameList
            tmp = nameList[j];
            nameList[j] = nameList[j+1];
            nameList[j+1] = tmp;

            //exitTimeList
            tmp = exitTimeList[j];
            exitTimeList[j] = exitTimeList[j+1];
            exitTimeList[j+1] = tmp;
          }
        }
      }
      print(timeList);
    }

    uniqueList.clear();
    for (int i = 0; i < list.length; i++) {
      if (!uniqueList.contains(list[i])) {
        uniqueList.add(list[i]);
      }
    }

    for (int i = 0; i < uniqueList.length; i++) {
      List<int> positionList = new List();
      for (int j = 0; j < list.length; j++) {
        if (uniqueList[i] == list[j]) {
          positionList.add(j);
        }
      }
      finalPositionList.add(positionList);
      print(timeList);
    }
  }
}
