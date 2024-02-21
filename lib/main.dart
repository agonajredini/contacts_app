import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp( MyApp());
}

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
   MyApp({super.key});


  final List <String> _searchList = 
  [
    'Agon Ajredini'
    'Bleron Ajredini'
    'Filan Fisteku'
  ];

  var items = <String>[];

  @override
  void initState()
  {
    //super.initState();
    items.addAll(_searchList);
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar:AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: false,
          title: Text('Contacts', style: GoogleFonts.lato(
            textStyle: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w900, fontSize: 35
            )
          ),),
        ) ,
        body:  Column(
          children: <Widget>[
             Container(
              padding: const EdgeInsets.all(2.0),
              margin: const EdgeInsets.all(5.0),
              child: const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0))
                    ),
                    prefix: Icon(Icons.search),
                    hintText: 'Search'
                ),
               // onChanged: {
                  //do something
              //  },
              ),
            ),
             Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index){
                return  Card(
                  elevation: 1.0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.white70, width: 1),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Container(
                    margin: EdgeInsets.all(9.0),
                    padding: EdgeInsets.all(6.0),
                    child: new Row(
                      children: <Widget>[
                        new CircleAvatar(
                          child: new Text('${items[index][0]}'),
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        new Padding(padding: EdgeInsets.all(8.0)),
                        new Text(
                          '${items[index]}',
                          style: TextStyle(fontSize: 20.0),
                        )
                      ],
                    ),
                  ),
                );
              },
              ) ,
            )
          ],
        ),
        )
      
    );
  }
}

