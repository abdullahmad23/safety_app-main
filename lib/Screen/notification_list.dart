import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'notification_details.dart';
// ignore_for_file: prefer_const_constructors

class NotificationList extends StatefulWidget {
  const NotificationList({Key? key, required this.uid}) : super(key: key);
  final String uid;
  @override
  State<NotificationList> createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  bool isReceived = true;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Notifications"),
          bottom: TabBar(
            indicatorWeight: 5,
            indicatorColor: Colors.white,
            onTap: (val) {
              if (val == 0) {
                isReceived = true;
              } else {
                isReceived = false;
              }
              setState(() {});
            },
            tabs: const [
              Tab(
                icon: Icon(Icons.arrow_downward_outlined),
                text: "Received",
              ),
              Tab(icon: Icon(Icons.arrow_upward_outlined), text: "Sent"),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
              stream: isReceived
                  ? FirebaseFirestore.instance
                      .collection("Notifications")
                      .doc(widget.uid.trim())
                      .collection("NotificationList")
                      .where("_id", whereNotIn: [widget.uid])
                      .orderBy('_id')
                      .orderBy("time", descending: true)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection("Notifications")
                      .doc(widget.uid)
                      .collection("NotificationList")
                      .where("_id", isEqualTo: widget.uid)
                      .orderBy("time", descending: true)
                      .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.data != null && snapshot.data!.docs.isEmpty) {
                  return Column(
                    children: const [
                      SizedBox(
                        height: 300,
                      ),
                      Center(
                        child: Text(
                          "No data found",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasData) {
                  return Column(
                    children: getExpenseItems(snapshot),
                  );
                } else {
                  return Center(child: const CircularProgressIndicator());
                }
              }),
        ),
      ),
    );
  }

  getExpenseItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data!.docs.map((doc) {
      update(doc.reference.id.toString());
      return InkWell(
        onTap: () {
          print(doc.reference.id);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NotificationDetails(
                        data: doc,
                        isReceived: isReceived,
                        refrence: doc.reference.id.toString(),
                      )));
        },
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    doc["sendBy"],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(
                      Icons.text_fields_outlined,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    doc["text"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Icon(Icons.arrow_right),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  update(String id) async {
    print(id);
    final ref = FirebaseFirestore.instance.collection("Notifications");
    await ref.doc(widget.uid).collection("NotificationList").doc(id).update({
      "isRead": true,
    });
  }
}
