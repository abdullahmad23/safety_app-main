import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_safety_main_app/Screen/add_contact.dart';

import '../utilities/app_color.dart';
import '../utilities/loding.dart';
// ignore_for_file: prefer_const_constructors

class ContactList extends StatefulWidget {
  const ContactList({Key? key,required this.uid}) : super(key: key);
  final String uid;
  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddContact()));
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Contacts"),
      ),
      body: SafeArea(
          child:StreamBuilder<QuerySnapshot>(
              stream:FirebaseFirestore.instance
                  .collection('/Contacts/${widget.uid}/contactList')
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData){
                  return  Center(child: CircularProgressIndicator());
                }
                else if(snapshot.data!.docs.isEmpty){
                  return Center(child: Text("No Contact Found"));
                }
                return  ListView(children:getExpenseItems(snapshot));
              })
      )
    );
  }
  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot,) {
    return snapshot.data!.docs
        .map((doc) => Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(Icons.person),),
        title: Text(doc["name"]),
        subtitle: Text(doc["phone"]),
        trailing: IconButton(
          onPressed: ()async{
            showAlertDialog(context,doc.reference.id);
          },
          icon: Icon(Icons.delete),
        ),
      ),
    ))
        .toList();
  }


  showAlertDialog(BuildContext context, var id){
    // set up the buttons
    Widget cancelButton = OutlinedButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        backgroundColor: MaterialStateProperty.all<Color>(kPrimaryColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
      child: Text("Yes"),
      onPressed: () async{
        Navigator.pop(context);
        Loading.showLoading("loading");
        final ref1 = FirebaseFirestore.instance.collection('Contacts');
         await ref1
            .doc(widget.uid)
            .collection("contactList").doc(id).delete();
        Loading.closeLoading();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmation"),
      content: Text("Do you want to add this contact?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}


