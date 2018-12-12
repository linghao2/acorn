
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart';


class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>{

  List<String> _languageList = List<String>();
  List<String> _translateToList = List<String>();

  String _language;
  String _translateTo;

  double _wordCountValue = 8.0;

  @override
  void initState() {
    super.initState();

    _languageList.addAll(['English']);
    _language = _languageList.elementAt(0);
    _translateToList.addAll(Globals.supportedTranslation.values);
    //_translateTo = _translateTpList.elementAt(0);

    _loadPreferences();
  }

  _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _wordCountValue = (prefs.getInt(Globals.PreferenceTestWordCount) ?? 8).toDouble();
      String lang =  (prefs.getString(Globals.PreferenceTranslateToLang) ?? 'none');
      _translateTo = Globals.supportedTranslation[lang];
    });
  }

  void _languageOnChanged(String languageValue) {
    setState(() {
      _language = languageValue;
    });
  }

  void _translateToOnChanged(String translateTo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _translateTo = translateTo;
      String translateToLang = 'none';
      for (MapEntry<String,String> translation in Globals.supportedTranslation.entries) {
        if (translation.value == translateTo) {
          translateToLang = translation.key;
          break;
        }
      }
      prefs.setString(Globals.PreferenceTranslateToLang, translateToLang);
    });
  }

  _wordCountOnChanged(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _wordCountValue = value;
      prefs.setInt(Globals.PreferenceTestWordCount, value.round());
    });
  }

  Widget build(BuildContext context){

    Widget testingTitle = Container(
      padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: Row(
        children: <Widget>[
          Text('Acorn Test ',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );

    Widget wordCount = Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Slider(
          activeColor: Globals.darkYellow,
          inactiveColor: Globals.medYellow,
          value: _wordCountValue,
          min: 4.0,
          max: 20.0,
          divisions: 16,
          label: '${_wordCountValue.round()}',
          onChanged: (double value) {_wordCountOnChanged(value);},
        ),
        Text('${_wordCountValue.round()} words per testing session', style: TextStyle(fontSize: 17.0)),
      ],
    );


    Widget languageTitle = Container(
      padding: EdgeInsets.only(top: 40.0, bottom: 20.0),
      child: Row(
        children: <Widget>[
          Text('Language ',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );

    Widget learning = Container(
      child: Row(
          children: <Widget>[
          Container(
            child: Text('I am learning   ', style: TextStyle(fontSize: 18.0)),
          ),
          DropdownButton(
            value: _language == ""? null : _language,
            items: _languageList.map((String value){
              return DropdownMenuItem(
                  value: value,
                  child: Text('${value}', style: TextStyle(fontSize: 17.0))
              );
            }).toList(),
            onChanged: (String languageValue){_languageOnChanged(languageValue);},
          )
        ],
      ),
    );

    Widget translateTo = Container(
      padding: EdgeInsets.only(top: 6.0),
      child:Row(
        children: <Widget>[
          Container(
            child: Text('Translate to  ', style: TextStyle(fontSize: 18.0)),
          ),
          DropdownButton(
            value: _translateTo == ""? null: _translateTo,
            items: _translateToList.map((String value) {
              return DropdownMenuItem(
                  value: value,
                  child: Text('${value}', style: TextStyle(fontSize: 17.0))
              );
            }).toList(),
            onChanged: (String translateTo){_translateToOnChanged(translateTo);},
          )
        ],
      ),
    );


    return ListView(
      children: <Widget>[
        testingTitle,
        wordCount,
        languageTitle,
        learning,
        translateTo,
      ],
    );
  }
}

