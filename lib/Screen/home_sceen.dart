import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_safety_main_app/Screen/camera_screen.dart';
import 'package:my_safety_main_app/Screen/listContact.dart';
import 'package:my_safety_main_app/Services/auth.dart';
import 'package:my_safety_main_app/Services/config.dart';
import 'package:my_safety_main_app/login/welcome.dart';
import 'package:my_safety_main_app/utilities/app_color.dart';

import '../Services/file_handling.dart';
import 'image_preview.dart';
import 'notification_list.dart';
import 'replies.dart';
import 'send_text.dart';
import 'video_preview.dart';
// ignore_for_file: prefer_const_constructors

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startCamera();

    Auth.getUser().then((value) {
      Config.userData = value;
    });
    setState(() {});
    print(Config.userData);
    Auth.getUid().then((value) {
      uid = value;
      setState(() {
        isLoading = false;
      });
    });
    Config.fetchFriend();
  }

  startCamera() async {
    cameras = await availableCameras();
  }

  bool isLoading = true;
  String uid = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Lottie.asset("assets/animation/safety.json"),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ContactList(uid: uid)));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          margin: EdgeInsets.all(4),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: .8,
                                  blurRadius: 6,
                                  offset: Offset(
                                      0, 2), // changes position of shadow
                                ),
                              ],
                              borderRadius: BorderRadius.circular(15)),
                          child: Column(
                            children: [
                              Lottie.asset(
                                "assets/animation/contacts.json",
                                height: 90,
                                width: 150,
                              ),
                              Text(
                                "Contact Details",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationList(
                                      uid: uid,
                                    )));
                      },
                      child: Container(
                        margin: EdgeInsets.all(4),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: .8,
                                blurRadius: 6,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Badge(
                                label: isLoading
                                    ? SizedBox()
                                    : StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection("Notifications")
                                            .doc(uid.trim())
                                            .collection("NotificationList")
                                            .where("_id", whereNotIn: [uid])
                                            .orderBy('_id')
                                            .where("isRead", isEqualTo: false)
                                            .snapshots(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (snapshot.data != null &&
                                              snapshot.data!.docs.isEmpty) {
                                            return Text("0");
                                          } else {
                                            return Text(snapshot.data == null
                                                ? "0"
                                                : snapshot.data!.docs.length
                                                    .toString());
                                          }
                                        }),
                                child: Lottie.asset(
                                  "assets/animation/notification.json",
                                  fit: BoxFit.cover,
                                  height: 90,
                                  width: 120,
                                )),
                            Text(
                              "Notifications",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ))
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        settingModalBottomSheet(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        margin: EdgeInsets.all(4),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: .8,
                                blurRadius: 6,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            Lottie.asset("assets/animation/videoimage2.json",
                                fit: BoxFit.cover, height: 90, width: 120),
                            Text(
                              "Image/video",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    )),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SendText(
                                      isPost: false,
                                    )));
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        margin: EdgeInsets.all(4),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: .8,
                                blurRadius: 6,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            Lottie.asset(
                              "assets/animation/message.json",
                              height: 90,
                            ),
                            Text(
                              "Text",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          )
        ],
      )),
    );
  }

  pickFile() async {
    var result = await FileServices.pickFile();
    if (result != null) {
      PlatformFile file = result.files.first;
      var extension = file.extension;
      if (extension == "jpg" || extension == "png" || extension == "png") {
        if (!mounted) return;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImagePreview(
                      image: File(file.path!),
                      screen: false,
                      isPost: false,
                    )));
      } else if (extension == "mp4") {
        if (!mounted) return;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoPreview(
                      video: File(file.path!),
                      screen: false,
                      isPost: false,
                    )));
      }
    }
  }

  settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SizedBox(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                      backgroundColor: kPrimaryColor,
                      child: Icon(
                        Icons.image,
                        color: Colors.white,
                      )),
                  title: Text('Gallery'),
                  onTap: () async {
                    Navigator.pop(context);
                    pickFile();
                  },
                ),
                ListTile(
                    leading: CircleAvatar(
                      backgroundColor: kPrimaryColor,
                      child: Icon(
                        Icons.camera,
                        color: Colors.white,
                      ),
                    ),
                    title: Text("Camera"),
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CameraScreen(
                                    isPost: false,
                                  )));
                    }),
              ],
            ),
          );
        });
  }
}

// Expanded(child: Container(
// height: 100,
// color: Colors.black54,
// )),
// Row(
// children: [
// Expanded(child: Container(
// height: 100,
// color: Colors.black54,
// )),
// Expanded(child: Container(
// height: 100,
// color: Colors.black54,
// ))
// ],
// )
