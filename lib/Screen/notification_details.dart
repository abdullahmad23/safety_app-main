import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_safety_main_app/Services/config.dart';
import 'package:my_safety_main_app/utilities/app_color.dart';

import '../Services/auth.dart';
import '../utilities/alert.dart';
import 'image_preview_details.dart';
import 'video_preview_details.dart';
// ignore_for_file: prefer_const_constructors

class NotificationDetails extends StatefulWidget {
  const NotificationDetails(
      {Key? key,
      required this.data,
      required this.isReceived,
      required this.refrence})
      : super(
          key: key,
        );
  final dynamic data;
  final bool isReceived;
  final String refrence;
  @override
  State<NotificationDetails> createState() => _NotificationDetailsState();
}

class _NotificationDetailsState extends State<NotificationDetails> {
  TextEditingController controller = TextEditingController();
  List<String> quickReply = [
    "I am Coming",
    "I am on the way",
    "Don't Worry",
    "Please be Patience"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details"),
        actions: [
          // widget.isReceived
          //     ? ElevatedButton.icon(
          //         icon: Icon(Icons.close),
          //         onPressed: () {
          //           showAlertDialog(context);
          //         },
          //         label: Text(
          //           "Make it false",
          //           style: TextStyle(color: Colors.white),
          //         ))
          //     : Container()
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: widget.data["type"] == "text"
                  ? textDetails()
                  : widget.data["type"] == "image"
                      ? imageDetails()
                      : videoDetails(),
            ),
          ),
          widget.isReceived?Container(
            height: 150,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: quickReply.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: (){
                              reply(quickReply[index]);
                              Navigator.pop(context);
                            },
                            child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        width: 1, color: kPrimaryColor)),
                                child: Center(child: Text(quickReply[index]))),
                          );
                        }),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(child: TextField(
                        controller:controller,
                        decoration: InputDecoration(
                          hintText: "Type here",
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                      )),
                      SizedBox(width: 15,),
                      InkWell(
                        onTap: (){
                          if(controller.text == ""){
                            return;
                          }
                          reply(controller.text);
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          child: Icon(Icons.send),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ):SizedBox()
        ],
      ),
    );
  }

  reply(String rep)async{
    final ref = FirebaseFirestore.instance.collection("Replies");
    await ref.doc(widget.data["sentByID"]).collection("RepliesList").add({
      "reply":rep,
      "time":DateTime.now(),
      "name": Config.userData["name"],
    });
    Alert.showAlert("Sent");
    Config.callOnFcmApiSendPushNotifications(rep);
  }
  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Yes"),
      onPressed: () async {
        Navigator.pop(context);
        Navigator.pop(context);
        var uid = await Auth.getUid();
        final ref1 = FirebaseFirestore.instance.collection("Notifications");
        var d = await ref1
            .doc(uid)
            .collection("NotificationList")
            .doc(widget.refrence)
            .get();
        var doc = d.data();
        if (doc!["isAlertTrue"] == false) {
          Alert.showAlert("Alert is already false");
        } else {
          final ref = FirebaseFirestore.instance.collection("Users");
          var data = await ref.doc(widget.data["sentByID"]).get();
          if (data.exists) {
            var doc = data.data();
            if (doc!["false_alert"] == null) {
              await ref.doc(widget.data["sentByID"]).update({
                "false_alert": 1,
              });
              await ref1
                  .doc(uid)
                  .collection("NotificationList")
                  .doc(widget.refrence.trim())
                  .update({
                "isAlertTrue": false,
              });
            } else {
              await ref.doc(widget.data["sentByID"]).update({
                "false_alert": ++doc["false_alert"],
              });
              await ref1
                  .doc(uid)
                  .collection("NotificationList")
                  .doc(widget.refrence.trim())
                  .update({
                "isAlertTrue": false,
              });
            }
            Alert.showAlert("Alert false is submitted");
          }
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Confirmation"),
      content: Text("Do you want to make this alert false?"),
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

  Widget textDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Sent By",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  widget.data["sendBy"],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            SizedBox(
              height: 15,
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Time",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  DateFormat('yyyy-MM-dd – kk:mm')
                      .format(widget.data['time'].toDate())
                      .toString(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            SizedBox(
              height: 15,
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Location",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  widget.data['location'],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            SizedBox(
              height: 15,
            ),
            Text(
              "Message",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              widget.data["text"],
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
          ]),
    );
  }

  Widget imageDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Sent By",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  widget.data["sendBy"],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            SizedBox(
              height: 15,
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Time",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  DateFormat('yyyy-MM-dd – kk:mm')
                      .format(widget.data['time'].toDate())
                      .toString(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            SizedBox(
              height: 15,
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Location",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  widget.data['location'],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            SizedBox(
              height: 15,
            ),
            Text(
              "Caption",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              widget.data['text'],
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ImageDetailsPreview(
                              image: widget.data["link"],
                            )));
              },
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(),
                child: Image.network(widget.data["link"]),
              ),
            )
          ]),
    );
  }

  Widget videoDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Sent By",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  widget.data["sendBy"],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            SizedBox(
              height: 15,
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Time",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  DateFormat('yyyy-MM-dd – kk:mm')
                      .format(widget.data['time'].toDate())
                      .toString(),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            SizedBox(
              height: 15,
            ),
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Location",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  widget.data['location'],
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ]),
            SizedBox(
              height: 15,
            ),
            Text(
              "Caption",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              widget.data['text'],
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoPreviewDetails(
                              video: widget.data["link"],
                            )));
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.black87,
                      child: Icon(Icons.play_arrow))
                ],
              ),
            )
          ]),
    );
  }
}
