import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:random_string/random_string.dart';

class ServiceCreatePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new ServiceCreatePageState();

}

class ServiceCreatePageState extends State<ServiceCreatePage> {
  final databaseReference = FirebaseDatabase.instance.reference();

  var count = 0;
  List<TextEditingController> _countControllerWing = new List();
  List<TextEditingController> _countControllerHouse = new List();
  TextEditingController _emailController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _addCount();
  }

  @override
  Widget build(BuildContext context) {
    _countControllerHouse.add(new TextEditingController());
    _countControllerWing.add(new TextEditingController());
    return new Scaffold(
        appBar: new AppBar(
        title: new Text('Flutter login demo'),
    ),
    body: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _showNameInput(),
        new Expanded(child:
        _showFlatList()
        ),
        _showPrimaryButton(),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _showAddButton(),
            _showRemoveButton()
          ],
        )
      ],
    )
    );
  }

  Widget _showNameInput() {
    return Container(
        margin: const EdgeInsets.only(top: 20.0),
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
        child: new TextField(
          textAlign: TextAlign.center,
          decoration: new InputDecoration(
              hintText: 'Name',
              icon: new Icon(
                Icons.mail,
                color: Colors.grey,
              )
          ),
          controller: _emailController,
        )
    );
  }

  Widget _showFlatList() {
    return new Container(
        margin: const EdgeInsets.only(top: 5.0),
      padding: const EdgeInsets.fromLTRB(5.0, 10.0, 10.0, 5.0),
      child: new ListView.builder(
          shrinkWrap: true,
          itemCount: count,
          itemBuilder: (BuildContext context, int index){
            return flatListItem(_countControllerWing[index], _countControllerHouse[index]);
      })
    );
  }

  Widget flatListItem(TextEditingController controllerWing, TextEditingController controllerHouse) {
    return new Container(
        margin: const EdgeInsets.only(top: 20.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Expanded(
            child: new TextField(
              textAlign: TextAlign.center,
              decoration: new InputDecoration(hintText: "Wing",
                  icon: new Icon(
                    Icons.hotel,
                    color: Colors.grey,
                  )),
              textCapitalization: TextCapitalization.characters,
              inputFormatters:[
                LengthLimitingTextInputFormatter(1),
              ],
              controller: controllerWing,
            ),
          ),
          new Expanded(
            child: new TextField(
              textAlign: TextAlign.center,
              decoration: new InputDecoration(hintText: "House Number"),
              controller: controllerHouse,
              keyboardType: TextInputType.number,
            ),
          )
        ],
      )
    );
  }

  Widget _showAddButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            color: Colors.red,
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            child: new Text('Add Item', style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _addCount,
          ),
        ));
  }

  Widget _showRemoveButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            color: Colors.red,
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            child: new Text('Remove Item', style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _removeCount,
          ),
        ));
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            color: Colors.blue,
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            child: new Text('Create account', style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _onSubmit,
          ),
        ));
  }

  void _onSubmit() {
    var name = _emailController.text;
    print(name);
    var code = (randomAlpha(3)+randomNumeric(3)).toUpperCase();
    Map<String, dynamic> map = new Map();
    for (int i = 0; i<count; i++) {
      var address = _countControllerWing[i].text+"-"+_countControllerHouse[i].text;
          print(address);
          map['Flat$i'] = address;
    }
    map['Name'] = name;
    print(map);
    databaseReference
        .child("ServiceAssociates").child(code).update(map);
    _reset();
  }

  void _addCount(){
    setState(() {
      count++;
    });
  }

  void _reset() {
    setState(() {
      _countControllerHouse.clear();
      _countControllerWing.clear();
      _emailController.clear();
      count = 1;
    });

  }

  void _removeCount(){
    setState(() {
      if(count > 1){
        count--;
      }else{
        count = 1;
      }
    });
  }

}