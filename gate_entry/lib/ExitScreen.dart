import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ExitScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ExitScreenState();
  }
}

class ExitScreenState extends State<ExitScreen> {
  final databaseReference = FirebaseDatabase.instance.reference();
  List<String> nameList = new List();
  List<DropdownMenuItem<int>> dropDown = new List();
  var _value = 0;
  String timestamp, flat;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "DropDownButton",
      home: new Scaffold(
          appBar: AppBar(
            title: Text("DropDownButton"),
          ),
          body: FutureBuilder<List<List<String>>>(
            future: getValues(),
            builder: (BuildContext context,
                AsyncSnapshot<List<List<String>>> snapshot) {
              if (!snapshot.hasData) {
                //while data is loading:
                return Center(
                  child: Text("No data"),
                );
              } else {
                return new Column(children: <Widget>[
                  new Center(
                    child: new DropdownButton<int>(
                  items: dropDown,
                  value: _value,
                  onChanged: (value) {
                    setState(() {
                      _value = value;
                    });
                  },
                )),
                  new RaisedButton(
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: onSubmit,
                  )
              ]);
              }
            },
          )),
    );
  }

  void buildDropdownMenu() {
    int i = 0;
    //print(nameList);
    dropDown.clear();
    for (String name in nameList) {
      dropDown.add(
        new DropdownMenuItem<int>(
          value: i,
          child: Text(name),
        ),
      );
      i++;
    }
  }

  onSubmit() async {
    var data = await databaseReference.child("PendingExit").once();
      Map<dynamic, dynamic> map = data.value;
      map.forEach((key, value) {
        //print(key);
        //timestamp = key;
        Map<dynamic, dynamic> map1 = value;
        map1.forEach((key1, value1) {
          //print(key1);
          //flat = key1;
          Map<dynamic, dynamic> map2 = value1;
          map2.forEach((key2, value2){
            //print(value2);
            if (value2 == nameList[_value]) {
              flat = key1;
              timestamp = key;
              print(flat+" "+timestamp);
            }
          });
        });
      });
      
      databaseReference.child("Data").child(flat).child(timestamp).set({
        'ExitTime': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      databaseReference.child("PendingExit").child(timestamp).remove();
    setState(() {});
  }

  Future<List<List<String>>> getValues() async {
    nameList.clear();
    List<List<String>> finalList = new List();
    var data = await databaseReference.child("PendingExit").once();
    Map<dynamic, dynamic> map = data.value;
    map.forEach((key, value) {
      Map<dynamic, dynamic> map1 = value;
      map1.forEach((key1, value1) {
        Map<dynamic, dynamic> map2 = value1;
        map2.forEach((key2, value2) {
          nameList.add(value2);
        });
      });
    });
    //print(nameList);
    buildDropdownMenu();
    finalList.add(nameList);
    return finalList;
  }
}
