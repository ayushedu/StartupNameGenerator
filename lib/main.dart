import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:async' show Future;

void main() => runApp(MyApp());



class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to flutter',
      theme: ThemeData(
        primaryColor: Colors.white
      ),
      home: RandomWords(),
    );
  }
}

class Model {
  final String name;
  final String meaning;

  Model({this.name, this.meaning});

  factory Model.fromJson(Map<String, dynamic> json) => Model(
    name: json["name"],
    meaning: json["meaning"],
  );
}

class RandomWords extends StatefulWidget {
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <Model>[];
  final _saved = Set<String>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  void initState() {
    super.initState();
    _loadSavedItems();
  }

  // load saved items
  _loadSavedItems() async {
    String data = await rootBundle.loadString("assets/names.json");
    var jsonData = json.decode(data)['names'].map(
        (data) => Model.fromJson(data)
    ).toList();
    //_suggestions.addAll(jsonData);

    jsonData.forEach((x) => _suggestions.add(x));
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      var _savedList = (prefs.getStringList("saved"));
      if(_savedList != null &&_savedList.length > 0) {
        _savedList.forEach(
                (str) {
              //var words = str.split("=");
              //var wp = Model(name: words[0], meaning: words[1]);
              _saved.add(str);
            }
        );
      }
    });
  }

  _saveSavedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList('saved', _saved.toList());
    });
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/

          final index = i ~/ 2; /*3*/
          /*if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10)); *//*4*//*

          }*/

          if(index < _suggestions.length) {
            return _buildRow(_suggestions[index]);
          } else return null;

        });
  }

  Widget _buildRow(Model pair) {
    String str = pair.name + '=' + pair.meaning;
    final bool alreadySaved = _saved.contains(str);
    return ListTile(
      title: Text(
        pair.name,
        style: _biggerFont,
      ),
      subtitle: Text(
        pair.meaning
      ),

      trailing: Icon(
        alreadySaved ? Icons.favorite: Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if(alreadySaved) {
            _saved.remove(str);
          } else {
            _saved.add(str);
          }
          _saveSavedItems();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.playlist_add, color: Colors.black87,), onPressed: _pushSaved,)
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
       builder: (BuildContext context) {
         final Iterable<ListTile> tiles = _saved.map(
             (String pair) {
               var str = pair.split('=');
               return ListTile(
                 title: Text(
                   str[0],
                   style: _biggerFont,
                 ),
                 subtitle: Text(
                   str[1]
                 ),
               );
             },
         );
         final List<Widget> divided = ListTile
         .divideTiles(
           context: context,
           tiles: tiles
         ).toList();
         return Scaffold(
           appBar: AppBar(
             title: Text('Saved Suggestions'),
           ),
           body: ListView(children: divided,),
         );
       }
      )
    );
  }
}