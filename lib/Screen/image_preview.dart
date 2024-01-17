// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Services/auth.dart';
import '../Services/config.dart';
import '../Services/file_handling.dart';
import '../utilities/alert.dart';
import '../utilities/loding.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({Key? key, required this.image,required this.screen,required this.isPost}) : super(key: key);
  final dynamic image;
  final bool screen;
  final bool isPost;
  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  TextEditingController controller = TextEditingController();
  String link = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: FileImage(
                      widget.image,
                    ),
                    fit: BoxFit.cover)),
          ),
          Positioned(
            bottom: 10,
            child: SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 5,
                    child: TextField(
                      controller: controller,
                      maxLines: 4,
                      minLines: 1,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          filled: true,
                          hintStyle: TextStyle(color: Colors.white),
                          hintText: "Enter Caption ",
                          fillColor: Colors.black54),
                    ),
                  ),
                  Expanded(
                      child: InkWell(
                        onTap: (){
                          uploadImage();
                        },
                        child: CircleAvatar(
                          radius: 23,
                    child: Center(child: Icon(Icons.send)),
                  ),
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void uploadImage() async {
    Loading.showLoading("loading");
    link =
        await FileServices.compressImage(widget.image, widget.isPost?"Post_Alert_Attachment":"Alert_Attachment");
    widget.isPost?await sendPost():await sendMessage();
    Loading.closeLoading();
    if (!mounted) return;
    if(widget.screen){
    Navigator.pop(context);
    Navigator.pop(context);
    }else{
      Navigator.pop(context);
    }
  }


  sendMessage()async{
    var uid = await Auth.getUid();
    var now = DateTime.now();
    final  ref = FirebaseFirestore.instance.collection("Notifications");
    try{
      Config.friendIds.add({"_id":uid});
      for(var item in Config.friendIds){
        await ref.doc(item["_id"]).collection("FeedList").add({
          "time":now,
          "text":controller.text == ""?"No Caption":controller.text,
          "type": "image",
          "sendBy":Config.userData["name"],
          "_id": uid,
          "location":Config.address,
          "link":link,
          "isAlertTrue":true,
          "sentByID":uid,
          "isRead": false,
        });
      }
      Config.friendIds.removeLast();
      Config.callOnFcmApiSendPushNotifications("Your friend may need your help. Please help him");
      Alert.showAlert("Alert Send Successfully");
    }catch(e){
      Alert.showAlert("Something wrong");
      Loading.closeLoading();
      print(e);
    }
  }
  sendPost()async{
    var uid = await Auth.getUid();
    var now = DateTime.now();
    final  ref = FirebaseFirestore.instance.collection("Feeds");
    try{
      Config.friendIds.add({"_id":uid});
      for(var item in Config.friendIds){
        await ref.doc(item["_id"]).collection("FeedList").add({
          "time":now,
          "text":controller.text == ""?"":controller.text,
          "type": "image",
          "sendBy":Config.userData["name"],
          "_id": uid,
          "link":link,
          "sentByID":uid,
        });
      }
      Config.friendIds.removeLast();
      Config.callOnFcmApiSendPushNotifications("Your Friend Make a Post");
      Alert.showAlert("Uploaded");
    }catch(e){
      Alert.showAlert("Something wrong");
      Loading.closeLoading();
      print(e);
    }
  }
}
