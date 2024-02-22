import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ContactDetails extends StatefulWidget {
   ContactDetails(this.contact, {super.key, required this.onContactUpdate, required this.onContactDelete});

  Contact contact;
  final Function(Contact) onContactUpdate;
  final Function(Contact) onContactDelete;

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

    deleteConfirmation(){ //Confirmation boxi nese dum ta fshijme kontaktin
      Widget cancel = TextButton (
        style: TextButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 187, 187, 187),
        foregroundColor: Colors.black
      ),
        child: const Text('Cancel'),
        onPressed: (){
          Navigator.of(context).pop();
        },

      );

      Widget delete = TextButton(
        style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white
      ),
        child: const Text('Delete'),
        onPressed: () async{
          await ContactsService.deleteContact(widget.contact); //Fshije
          widget.onContactDelete(widget.contact);
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        },
      );

      AlertDialog alert =  AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Do you want to delete this contact?'),
        actions: <Widget>[
          cancel,
          delete
        ],
      );

      showDialog(
        context: context,
         builder: (BuildContext context) {
            return alert;
         }
         );
         
    }

    onAction(String action) async {
      switch(action){
        case 'Edit':
          try{
            Contact updateContact = await ContactsService.openExistingContact(widget.contact);
            setState(() {
              widget.contact = updateContact; //Edit kontaktin
            });
            widget.onContactUpdate(widget.contact);
          }
          on FormOperationException catch (e) {
            switch(e.errorCode){
              case FormOperationErrorCode.FORM_OPERATION_CANCELED:
              case FormOperationErrorCode.FORM_COULD_NOT_BE_OPEN:
              case FormOperationErrorCode.FORM_OPERATION_UNKNOWN_ERROR:
              case null:

            }
          }
          break;
        case 'Delete':
        deleteConfirmation();
          break;
      }
    }
    var avatar2 = widget.contact.avatar; 
    var bdaystr = "";
    var bdayToStr = "";

    DateFormat dateFormat = DateFormat("dd-MM-yyyy"); //Format ditlindjen
    DateTime? bday = widget.contact.birthday;
    if(bday != null){
      bdaystr="birthday";
      bdayToStr = dateFormat.format(bday).toString(); //Kthen ditlindjen ne String per ta perdor me .map
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
                  CircleAvatar( //Shfaq avatarin mvaresisht nese ka foto (ose inicialet)
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
                        icon: const Icon(Icons.arrow_back), //Butoni back
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
                        onSelected: onAction,
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
                        widget.contact.displayName.toString(), //Shfaq Emrin
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
                    Column(
                      children: widget.contact.phones!
                        .map(
                          (i) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListTile( //Shfaq listen e numrave
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
                            child: ListTile( //Shfaq email-in
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
                            child: ListTile(//Shfaq ditlindjen
                              title: Text(bdaystr, style: const TextStyle(fontSize: 19.0),),
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