import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gson/gson.dart';

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

class RandomWords extends StatefulWidget {
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  void initState() {
    super.initState();
    _loadSavedItems();

  }

  // load saved items
  _loadSavedItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      var _savedList = (prefs.getStringList("saved"));
      
      _savedList.forEach(
          (str) {
            var words = str.split(new RegExp(r"(?=[A-Z])"));
            var wp = WordPair(words[0], words[1]);
            _saved.add(wp);
            _suggestions.insert(0, wp);
            //_saved.add(str);
          }
      );
      //_suggestions.addAll(_saved);

    });
  }

  _saveSavedItems() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList('saved', _saved.map((WordPair wordPairItem) => wordPairItem.asPascalCase).toList());
    });
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: /*1*/ (context, i) {
          if (i.isOdd) return Divider(); /*2*/

          final index = i ~/ 2; /*3*/
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10)); /*4*/
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite: Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if(alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
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
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved,)
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
             (WordPair pair) {
               return ListTile(
                 title: Text(
                   pair.asPascalCase,
                   style: _biggerFont,
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