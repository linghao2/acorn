
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';
import 'globals.dart';


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
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  bool _reminderValue = true;
  bool _visible = true;
  String _language = null;
  String _motherTongue = null;
  String _timePeriod = 'am';
  TimeOfDay _time = new TimeOfDay(hour: 10, minute: 00);

  List<String> _languageList = new List<String>();
  List<String> _motherTongueList = new List<String>();


  void _toggleOnChanged(bool value){
    setState(() {
      _reminderValue = value;
      if(_reminderValue == true)
        _showDailyNotificationAtTime(_time);
      else
        _cancelNotification();
      _visible = !_visible;
    });
  }

  @override
  void initState() {
    _languageList.addAll(['Chinese','English', 'French']);
    _language = _languageList.elementAt(0);
    _motherTongueList.addAll(Globals.supportedTranslation.keys);
    _motherTongue = _motherTongueList.elementAt(0);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        selectNotification: onSelectNotification);
    if (_reminderValue == true) {
      _showDailyNotificationAtTime(_time);
    }
  }

  Future onSelectNotification(String payload) async{
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
      Navigator.pop(context);
    }
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

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
        context: context,
        initialTime: _time
    );

    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
        _showDailyNotificationAtTime(_time);
        if(_time.period.toString() == 'DayPeriod.am')
          _timePeriod = 'am';
        else
          _timePeriod = 'pm';

      });
    }
  }

  Future _cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  /// Schedules a notification that specifies a different icon, sound and vibration pattern
  Future _scheduleNotification() async {
    var scheduledNotificationDateTime =
    new DateTime.now().add(new Duration(seconds: 5));
    var vibrationPattern = new Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        'your other channel description',
        icon: 'secondary_icon',
        sound: 'slow_spring_board',
        largeIcon: 'sample_large_icon',
        largeIconBitmapSource: BitmapSource.Drawable,
        vibrationPattern: vibrationPattern,
        color: const Color.fromARGB(255, 255, 0, 0));
    var iOSPlatformChannelSpecifics =
    new IOSNotificationDetails(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
        0,
        'scheduled title',
        'scheduled body',
        scheduledNotificationDateTime,
        platformChannelSpecifics);
  }

  Future _showDailyNotificationAtTime(TimeOfDay ScheduledTime) async {
    var time = new Time(ScheduledTime.hourOfPeriod, ScheduledTime.minute, 0);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'repeatDailyAtTime channel id',
        'repeatDailyAtTime channel name',
        'repeatDailyAtTime description');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'Acorn',
        "Hey! It's time for you to acorn! Good Luck!",
        time,
        platformChannelSpecifics);
  }

  String _toTwoDigitString(int value) {
    return value.toString().padLeft(2, '0');
  }


  Widget build(BuildContext context){

    Widget reminderToggle = Container(
      padding: EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('Acorn Reminder',
              style:new TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
              )
          ),
          new Switch(value: _reminderValue,
              activeColor: Colors.green,
              onChanged: (bool value){_toggleOnChanged(value); }
          ),
        ],
      ),
    );


    Widget reminderFrequency = Container(
        padding: EdgeInsets.only(top: 20.0),
        child: AnimatedOpacity(
          opacity:  _visible? 1.0 : 0.2,
          duration: Duration(milliseconds: 100),
          child:Wrap(
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: new Text('I will be accorning at ', style:new TextStyle (fontSize: 24.0)),
              ),
              new RaisedButton(
                child: new Text(
                    _time != null ? '${_time.hourOfPeriod}' + ':'  + "${_time.minute > 10? _time.minute: '0'+_time.minute.toString()} ${_timePeriod}" : 'Select Time'),
                color: Color(0xFFFFB20A),
                onPressed: (){_selectTime(context);},
              ),
            ],
          ),
        )
    );

    Widget languageTitle = new Container(
      padding: EdgeInsets.only(top: 80.0),
      child: Row(
        children: <Widget>[
          Text('Language ',
              style: new TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );

    Widget learning = new Container(
      padding: EdgeInsets.only(top: 20.0),
      child:Wrap(
          children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: Text('I am learning   ', style: new TextStyle(fontSize: 24.0)),
          ),
          new DropdownButton(
            value: _language == ""? null : _language,
            iconSize: 30.0,
            items: _languageList.map((String value){
              return DropdownMenuItem(
                  value: value,
                  child: new Text('${value}', style:new TextStyle(fontSize: 24.0))
              );
            }).toList(),
            onChanged: (String languageValue){_languageOnChanged(languageValue);},
          )
        ],
      ),
    );

    Widget motherTongue = new Container(
      padding: EdgeInsets.only(top: 20.0),
      child:Wrap(
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: Text('My mother tongue is ', style: new TextStyle(fontSize: 24.0)),
          ),
          new DropdownButton(
            value: _motherTongue == ""? null: _motherTongue,
            iconSize: 30.0,
            items: _motherTongueList.map((String value) {
              return DropdownMenuItem(
                  value: value,
                  child: new Text('${value}', style:new TextStyle(fontSize: 24.0))
              );
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
        languageTitle,
        learning,
        motherTongue,
      ],
    );
  }
}

