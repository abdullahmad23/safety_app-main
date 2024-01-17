// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_safety_main_app/utilities/loding.dart';
import 'package:video_player/video_player.dart';

import '../Services/auth.dart';
import '../Services/config.dart';
import '../Services/file_handling.dart';
import '../utilities/alert.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview({Key? key, required this.video,required this.screen,required this.isPost}) : super(key: key);
  final dynamic video;
  final bool screen;
  final bool isPost;
  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.video)
      ..initialize().then((_) async{
        var time = await  _controller.value.duration;
        print(time);
        _controller.addListener(() {
          if(_controller.value.position == time){
            setState(() {
            });
          }
        });
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  // setLandScape() async {
  //   await SystemChrome.setEnabledSystemUIOverlays([]);
  //   await SystemChrome.setPreferredOrientations([
  //     DeviceOrientation.landscapeLeft,
  //     DeviceOrientation.landscapeRight,
  //   ]);
  // }
  //
  // reset() async {
  //   await SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  //   await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  // }
  TextEditingController controller = TextEditingController();
  String link = "";
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Preview"),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : Container(),
          ),
          Align(
            alignment: Alignment.center,
            child: InkWell(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: CircleAvatar(
                radius: 33,
                backgroundColor: Colors.black26,
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),
          Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              )),
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
                          uploadVideo();
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

  void uploadVideo() async{
    Loading.showLoading("loading");
     link = await FileServices.uploadTask(widget.video, widget.isPost?"Post_Alert_Attachment":"Alert_Attachment");
    widget.isPost?await sendPost():await sendMessage();
    Loading.closeLoading();
    if(!mounted)return;
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
        await ref.doc(item["_id"]).collection("NotificationList").add({
          "time":now,
          "text":controller.text == ""?"No Caption":controller.text,
          "type": "video",
          "sendBy":Config.userData["name"],
          "_id": uid,
          "location":Config.address,
          "link":link,
          "isAlertTrue":true,
          "sentByID":uid,
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
          "type": "video",
          "sendBy":Config.userData["name"],
          "_id": uid,
          "link":link,
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

}
