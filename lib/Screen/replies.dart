import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class Replies extends StatefulWidget {
  const Replies({Key? key,required this.uid}) : super(key: key);
  final String uid;
  @override
  State<Replies> createState() => _RepliesState();
}

class _RepliesState extends State<Replies> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Replies"),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
            stream:FirebaseFirestore.instance
                .collection("Replies").doc(widget.uid).collection("RepliesList").orderBy("time")
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData){
                return  Center(child: CircularProgressIndicator());
              }
              else if(snapshot.data!.docs.isEmpty){
                return Center(child: Column(
                  children: [
                    SizedBox(height: 300,),
                    Text("No Reply"),
                  ],
                ));
              }
              return  ListView(
                  shrinkWrap: true,
                  children:getExpenseItems(snapshot));
            }),
      ),
    );
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot,) {
    return snapshot.data!.docs
        .map((doc) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(doc['name'])
            .text
            .subtitle1(context)
            .make()
            .box
            .color(Vx.green200)
            .p16
            .rounded
            .alignCenter
            .makeCentered(),
        Expanded(child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(doc["reply"]),
        )),
      ],
    ).p8()
    )
        .toList();
  }

}
