import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatelessWidget {

  SettingsView();

  @override
  Widget build(BuildContext context) {
    return MySettingsPage();
  }
}

class MySettingsPage extends StatefulWidget {
  MySettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MySettingsPageState createState() => new _MySettingsPageState();
}

class _MySettingsPageState extends State<MySettingsPage>{
  bool _reminderValue = true;
  int _wordCount = 4;
  String _interval = null;
  String _language = null;
  String _motherTongue = null;

  List<int> _wordCountList = new List<int>();
  List<String> _intervalList = new List<String>();
  List<String> _languageList = new List<String>();
  List<String> _motherTongueList = new List<String>();

  void _toggleOnChanged(bool value){
    setState(() {
      _reminderValue = value;
    });
  }

  @override
  void initState() {
    _wordCountList.addAll([1,5,10,15]);
    _wordCount = _wordCountList.elementAt(0);
    _intervalList.addAll(['1 hour', '5 hours', '1 day', '5 days', '25 days']);
    _interval = _intervalList.elementAt(0);
    _languageList.addAll(['Chinese','English', 'French']);
    _language = _languageList.elementAt(0);
    _motherTongueList.addAll(['Chinese','English', 'French']);
    _motherTongue = _motherTongueList.elementAt(0);

  }

  void _wordCountOnChanged(int value){
    setState((){
      _wordCount = value;
    });
  }

  void _intervalOnChanged(String intervalValue){
    setState((){
      _interval = intervalValue;
    });
  }

  void _languageOnChanged(String languageValue){
    setState(() {
      _language = languageValue;
    });
  }

  void _motherTongueOnChanged(String motherTongue){
    setState(() {
      _motherTongue = motherTongue;
    });
  }


  Widget build(BuildContext context){

    Widget reminderToggle = Container(
      padding: EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('Acorn Reminder',
              style:new TextStyle(fontSize: 24.0)
          ),
          new Switch(value: _reminderValue,
              activeColor: Colors.green,
              onChanged: (bool value){_toggleOnChanged(value);}
          ),
        ],
      ),
    );

    Widget reminderFrequency = Container(
        padding: EdgeInsets.only(top: 20.0),
        child:Wrap(
          children: <Widget>[
            Text('I will be accorning ',
                style:new TextStyle (fontSize: 24.0)),
            new DropdownButton(
              value: _wordCount,
              iconSize: 30.0,
              items: _wordCountList.map((int value){
                return DropdownMenuItem(
                    value: value,
                    child: new Text('${value}'));
              }).toList(),
              onChanged: (int value){_wordCountOnChanged(value);},
            ),
            Text('words ',
                style:new TextStyle (fontSize: 24.0)),
            Text('every ',
                style:new TextStyle (fontSize: 24.0)),
            new DropdownButton(
              value: _interval == ""? null : _interval,
              iconSize: 30.0,
              items: _intervalList.map((String value){
                return DropdownMenuItem(
                    value: value,
                    child: new Text('${value}'));
              }).toList(),
              onChanged: (String value){_intervalOnChanged(value);},
            ),
          ],
        )
    );

    Widget intervalInfo = Container(
        padding: EdgeInsets.only(top: 20.0),
        child: new RichText(
            text: new TextSpan(
                children: [
                  new TextSpan(
                    text: 'The interval set is based on ',
                    style: new TextStyle(fontSize: 12.0, color: Colors.grey),
                  ),
                  new TextSpan(
                    text: 'Pimsleurs graduated interval recall',
                    style: new TextStyle(fontSize: 12.0, color: Colors.blue),
                    //gesture recognition
                  )
                ]
            )
        )
    );

    Widget languageTitle = new Container(
      padding: EdgeInsets.only(top: 20.0),
      child: Row(
        children: <Widget>[
          Text('Language ',
              style: new TextStyle(fontSize: 24.0)),
        ],
      ),
    );

    Widget learning = new Container(
      padding: EdgeInsets.only(top: 20.0),
      child: Row(
        children: <Widget>[
          Text('I am learning ',
            style: new TextStyle(fontSize: 24.0),
          ),
          new DropdownButton(
            value: _language == ""? null : _language,
            iconSize: 30.0,
            items: _languageList.map((String value){
              return DropdownMenuItem(
                  value: value,
                  child: new Text('${value}'));
            }).toList(),
            onChanged: (String languageValue){_languageOnChanged(languageValue);},
          )
        ],
      ),
    );

    Widget motherTongue = new Container(
      padding: EdgeInsets.only(top: 20.0),
      child: Row(
        children: <Widget>[
          Text('My Mother Tongue is ',
            style: new TextStyle(fontSize:  24.0),
          ),
          new DropdownButton(
            value: _motherTongue == ""? null: _motherTongue,
            iconSize: 30.0,
            items: _motherTongueList.map((String value) {
              return DropdownMenuItem(
                  value: value,
                  child: new Text('${value}'));
            }).toList(),
            onChanged: (String motherTongueValue){_motherTongueOnChanged(motherTongueValue);},
          )
        ],
      ),
    );


    return ListView(
      children: <Widget>[
        reminderToggle,
        reminderFrequency,
        intervalInfo,
        languageTitle,
        learning,
        motherTongue,
      ],
    );
  }
}

