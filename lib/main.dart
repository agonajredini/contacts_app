// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart'; 
import 'package:contacts_app/details.dart';
import 'package:collection/collection.dart';
import 'package:permission_handler/permission_handler.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        //useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Contacts'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
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
    getPermissions();
    
  }
  //Merr Permission
  getPermissions() async {
    if(await Permission.contacts.request().isGranted){
      getAllContacts();
      searchCon.addListener(() {
      searchContacts();
    });
    }
  }

  //Formaton krejt numrin me nji String 
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
      _contacts.retainWhere((contact){ //Nese search bar nuk eshte empty largon prej liste kontaktet
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
        
        //Search me numer
        var phone = contact.phones!.firstWhereOrNull((phn){
          String phnFlatten = flattenPhoneNumber(phn.value.toString()); //Formaton numrin
          return phnFlatten.contains(searchInputFlatten);
        });
        return phone != null;

      });
      
      setState(() {
        contactsSearch = _contacts; //I nxjerr kontaktet e kerkuara
      });
    }
    else if (searchCon.text.isEmpty){
      setState(() {
        contactsSearch = contacts; //I nxjerr krejt kontaktet (nese search bar eshte empty)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool searching = searchCon.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
              itemCount: searching == true ?contactsSearch.length : contacts.length, //Merr itemCount mvaresisht nese ije tu be search ose jo
              itemBuilder: (context, index){
                Contact contact = searching == true ?contactsSearch[index] : contacts[index];
                var avatar = contact.avatar;
                return ListTile(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context)=>ContactDetails(
                        contact,
                        onContactDelete: (Contact _contact){ //Nese fshin kontaktin nxjerr listen e re
                          getAllContacts();
                          Navigator.of(context).pop();
                        },
                        onContactUpdate: (Contact _contact){ //Nese edit kontaktin nxjerr listen e re
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
                  CircleAvatar(child: Text(contact.initials()),), //Avatare mvaresisht nese ka foto ose jo
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