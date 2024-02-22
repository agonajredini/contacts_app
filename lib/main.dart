// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart'; 
import 'package:contacts_app/details.dart';
import 'package:collection/collection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        //useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Contacts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  List<Contact> contacts = [];
  List<Contact> contactsSearch = [];

  TextEditingController searchCon = TextEditingController();

  @override void initState() {
    super.initState();
    getAllContacts();
    searchCon.addListener(() {
      searchContacts();
    });
  }

  String flattenPhoneNumber(String phoneString){
    return phoneString.replaceAllMapped(RegExp(r'^(\+)|\D'), (Match m) {
      return m[0] == "+" ? "+" : "";
    });
  }

  getAllContacts() async {
    List<Contact> _contacts = await ContactsService.getContacts();
    setState(() {
      contacts = _contacts;
    });
  }
  
  searchContacts(){
    List<Contact> _contacts = [];
    _contacts.addAll(contacts);
    if(searchCon.text.isNotEmpty){
      _contacts.retainWhere((contact){
        String searchInput = searchCon.text.toLowerCase();
        String searchInputFlatten = flattenPhoneNumber(searchInput);
        String contactName = contact.displayName!.toLowerCase();
        bool nameMatches = contactName.contains(searchInput);
        if(nameMatches == true){
          return true;
        }

        if(searchInputFlatten.isEmpty){
          return false;
        }
        
        var phone = contact.phones!.firstWhereOrNull((phn){
          String phnFlatten = flattenPhoneNumber(phn.value.toString());
          return phnFlatten.contains(searchInputFlatten);
        });
        return phone != null;

      });
      
      setState(() {
        contactsSearch = _contacts;
      });
    }
    else if (searchCon.text.isEmpty){
      setState(() {
        contactsSearch = contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool searching = searchCon.text.isNotEmpty;
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title,
        style: const TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold
        ),),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(183, 3, 168, 244),
        onPressed: () async {
          try {
            await ContactsService.openContactForm();
            getAllContacts();
                    } on FormOperationException catch (e) {
            switch(e.errorCode){
              case FormOperationErrorCode.FORM_OPERATION_CANCELED:
              case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
              case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
              case null:

            }
          } 
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: <Widget>[
            TextField(
              controller: searchCon,
              decoration: InputDecoration(
                hintText: 'Search',
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor
                  )
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).primaryColor,
                )
              ),
            ),

            Expanded(child: ListView.builder(
              shrinkWrap: true,
              itemCount: searching == true ?contactsSearch.length : contacts.length,
              itemBuilder: (context, index){
                Contact contact = searching == true ?contactsSearch[index] : contacts[index];
                var avatar = contact.avatar;
                return ListTile(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context)=>ContactDetails(
                        contact,
                        onContactDelete: (Contact _contact){
                          getAllContacts();
                          Navigator.of(context).pop();
                        },
                        onContactUpdate: (Contact _contact){
                         getAllContacts();
                        },
                        )
                      ));
                  },
                  title: Text(contact.displayName.toString()),
                  subtitle: Text(
                    contact.phones!.elementAt(0).value.toString()
                  ),
                  leading: (contact.avatar != null && contact.avatar!.isNotEmpty) ?
                  CircleAvatar(
                    backgroundImage: MemoryImage(avatar!),
                  ) :
                  CircleAvatar(child: Text(contact.initials()),),
                );
              }
            ))
          ],
        ),
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}