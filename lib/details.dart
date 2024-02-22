import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContactDetails extends StatefulWidget {
  const ContactDetails(this.contact, {super.key});

  final Contact contact;
  @override
  // ignore: library_private_types_in_public_api
  _ContactDetailsState createState() => _ContactDetailsState();
}

class _ContactDetailsState extends State<ContactDetails> {

  
  @override
  Widget build(BuildContext context) {
    List<String> actions = <String>[
      'Edit',
      'Delete'
    ];
    var avatar2 = widget.contact.avatar;
    var bdaystr = "";
    var bdayToStr = "";

    DateFormat dateFormat = DateFormat("dd-MM-yyyy");
    DateTime? bday = widget.contact.birthday;
    if(bday != null){
      bdaystr="birthday";
      bdayToStr = dateFormat.format(bday).toString();
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  Center(
                    child: (avatar2 != null && avatar2.isNotEmpty) ?
                  CircleAvatar(
                    backgroundImage: MemoryImage(avatar2),
                    radius: 60.0 
                  ) :
                  CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 126, 124, 124),
                    radius: 60.0,
                    child: Text(
                      widget.contact.initials(),
                      style: const TextStyle(
                        fontSize: 40.0,
                        color: Colors.white
                        ),
                      )
                    ),
                    ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PopupMenuButton(
                        itemBuilder: (BuildContext context) {
                          return actions.map((String action) {
                            return PopupMenuItem(
                              value: action,
                              child: Text(action),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
            Center(
                      child:
                       Text(
                        widget.contact.displayName.toString(),
                        style: const TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold
                        ),
                        ),
                    ),
            Expanded(
              child: ListView(shrinkWrap: true, children: <Widget>[
                Column(
                  children: <Widget>[
                    const ListTile(title: Text("Phones")),
                    Column(
                      children: widget.contact.phones!
                        .map(
                          (i) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListTile(
                              title: Text(i.label ?? "", style: const TextStyle(fontSize: 19.0),),
                              subtitle: Text(i.value ?? "", style: const TextStyle(
                                fontSize: 20.0,
                                color: Color.fromARGB(255, 38, 125, 255)
                                )
                                ),
                            ),
                          ),
                        )
                        .toList(),
                    ),
                    Column(
                      children: widget.contact.emails!
                        .map(
                          (i) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListTile(
                              title: const Text("email", style: TextStyle(fontSize: 19.0),),
                              subtitle: Text(i.value ?? "", style: const TextStyle(
                                fontSize: 20.0,
                                color: Color.fromARGB(255, 38, 125, 255)
                                )
                                ),
                            ),
                          ),
                        )
                        .toList(),
                    ),
                    Column(
                      children: widget.contact.emails!
                        .map(
                          (i) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListTile(
                              title: Text(bdaystr, style: TextStyle(fontSize: 19.0),),
                              subtitle: Text(bdayToStr, style: const TextStyle(
                                fontSize: 20.0,
                                color: Color.fromARGB(255, 38, 125, 255)
                                )
                                ),
                            ),
                          ),
                        )
                        .toList(),
                    )
                  ],
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}