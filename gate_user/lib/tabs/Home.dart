import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogPage extends StatelessWidget {

  LogPage({this.flat});

  final databaseReference = FirebaseDatabase.instance.reference();

  final flat;

  final List<String> nameList = new List();
  final List<String> timeList = new List();
  final List<String> exitTimeList = new List();
  final List<String> flatList = new List();


  @override
  Widget build(BuildContext context) {
    return new Container(
      child: _listBuilderVisitor(),
    );
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
    return await _getValuesVisitor();
  }

  Future<List<List<String>>> _getValuesVisitor() async {
    List<List<String>> finalList = new List();
    nameList.clear();
    timeList.clear();
    exitTimeList.clear();
    var data = await databaseReference.child("Data").child(flat).once();
    Map<dynamic, dynamic> map = data.value;
    map.forEach((key, value) {
      Map<dynamic, dynamic> map1 = value;
      nameList.add(map1['Name']);
      timeList.add(key);
      exitTimeList.add(map1['ExitTime']);
    });
    finalList.add(nameList);
    finalList.add(timeList);
    finalList.add(exitTimeList);
    return finalList;
  }

  Widget _listBuilderVisitor() {
    return new FutureBuilder(
        future: _getFinalValues(),
        initialData: "Loading text..",
        builder: (BuildContext context, AsyncSnapshot<Object> list) {
          if (!list.hasData) {
            return new Center(
              child: new Text("No Data"),
            );
          } else {
            return new Container(
                child: new ListView.builder(
                  itemCount: nameList.length,
                  itemBuilder: (BuildContext context, int index) {
                    new ExpansionTile(
                      title: new Center(
                       child: new Text(nameList[index])
                      ),
                      children: <Widget>[
                        new Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Container(
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Container(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 20, top: 2, bottom: 2),
                                    child: new Text("Entry Time"),
                                  ),
                                  new Container(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 20, top: 2, bottom: 2),
                                    child: new Text(timeList[index]),
                                  ),
                                ],
                              ),
                            ),
                            new Container(
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Container(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 20, top: 2, bottom: 2),
                                    child: new Text("Exit Time"),
                                  ),
                                  new Container(
                                    padding: EdgeInsets.only(
                                        left: 10, right: 20, top: 2, bottom: 2),
                                    child: new Text(exitTimeList[index]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  },
                )
            );
          }
        });
  }
}