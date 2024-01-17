import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_safety_main_app/Services/auth.dart';
import 'package:my_safety_main_app/Services/config.dart';
import 'package:my_safety_main_app/utilities/alert.dart';

import '../utilities/app_color.dart';
import '../utilities/loding.dart';
// ignore_for_file: prefer_const_constructors

class SendText extends StatefulWidget {
  const SendText({Key? key,required this.isPost}) : super(key: key);
  final bool isPost;
  @override
  State<SendText> createState() => _SendTextState();
}

class _SendTextState extends State<SendText> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send Text"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(children: [
          SizedBox(
            height: 30,
          ),
          TextField(
            maxLines: 4,
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Describe your problem',
              labelStyle:
                  TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w500),
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding: EdgeInsets.all(16),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor, width: 2),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          SizedBox(
              width: double.infinity,
              height: 40,
              child:
                  ElevatedButton(onPressed: () {
                    if(controller.text != ""){
                      if(Config.friendIds.isEmpty){
                        Alert.showAlert("You have not added any friend");
                      }else {
                        widget.isPost?sendPost():sendMessage();
                    }
                    }else{
                      Alert.showAlert("Filled must be filled");
                    }
                  }, child: Text("Send Alert")))
        ]),
      ),
    );
  }

  sendMessage()async{
    Loading.showLoading("loading");
    var uid = await Auth.getUid();
    var now = DateTime.now();
    final  ref = FirebaseFirestore.instance.collection("Notifications");
    try{
      Config.friendIds.add({"_id":uid});
        for(var item in Config.friendIds){
          await ref.doc(item["_id"]).collection("NotificationList").add({
            "time":now,
            "text":controller.text,
            "type": "text",
            "sendBy":Config.userData["name"],
            "_id": uid,
            "location":Config.address,
            "isAlertTrue":true,
            "sentByID":uid,
            "isRead": false,
          });
        }
      Config.friendIds.removeLast();
      Config.callOnFcmApiSendPushNotifications("Your friend may need your help. Please help him");
        Loading.closeLoading();
        if(!mounted)return;
        Navigator.pop(context);
        Alert.showAlert("Alert Send Successfully");
    }catch(e){
      Alert.showAlert("Something wrong");
      Loading.closeLoading();
      print(e);
    }
  }
  sendPost()async{
    Loading.showLoading("loading");
    var uid = await Auth.getUid();
    var now = DateTime.now();
    final  ref = FirebaseFirestore.instance.collection("Feeds");
    try{
      Config.friendIds.add({"_id":uid});
      for(var item in Config.friendIds){
        await ref.doc(item["_id"]).collection("FeedList").add({
          "time":now,
          "text":controller.text,
          "type": "text",
          "sendBy":Config.userData["name"],
          "_id": uid,
          "sentByID":uid,
        });
      }
      Config.friendIds.removeLast();
      Config.callOnFcmApiSendPushNotifications("Your friend make a post");
      Loading.closeLoading();
      if(!mounted)return;
      Navigator.pop(context);
      Alert.showAlert("Uploaded");
    }catch(e){
      Alert.showAlert("Something wrong");
      Loading.closeLoading();
      print(e);
    }
  }
}
