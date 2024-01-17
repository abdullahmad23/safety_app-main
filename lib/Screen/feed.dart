import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_safety_main_app/Screen/send_text.dart';
import 'package:my_safety_main_app/utilities/app_color.dart';
import 'package:path_provider/path_provider.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../Services/file_handling.dart';
import 'camera_screen.dart';
import 'image_preview.dart';
import 'video_preview.dart';
import 'video_preview_details.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key, required this.uid}) : super(key: key);
  final String uid;

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  bool isLoading = true;
  List<dynamic> feed = [];

  getData() async {
    feed = [];
    setState(() {
      isLoading = true;
    });
    final ref = FirebaseFirestore.instance.collection("Feeds");
    var data = await ref
        .doc(widget.uid)
        .collection("FeedList")
        .orderBy("time", descending: true)
        .get();

    if (data.size != 0) {
      for (var item in data.docs) {
        var document = item.data();
        feed.add(document);
      }
    }
    for (int i = 0; i < feed.length; i++) {
      if (feed[i]["type"] == "video") {
        feed[i]["thumbnail"] = await VideoThumbnail.thumbnailFile(
          video: feed[i]["link"],
          thumbnailPath: (await getTemporaryDirectory()).path,
          imageFormat: ImageFormat.WEBP,
          quality: 75,
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  getTime(int index) {
    int mint =
        DateTime.now().difference(feed[index]["time"].toDate()).inMinutes;
    int hour = DateTime.now().difference(feed[index]["time"].toDate()).inHours;
    var date = DateTime.now().difference(feed[index]["time"].toDate());

    if (mint < 59) {
      return mint.toString() + "m";
    } else if (hour < 23) {
      return hour.toString() + "h";
    } else {
      return DateFormat('dd-MM-yyyy hh:mm a')
          .format(feed[index]["time"].toDate())
          .toString();
    }
  }

  var file;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feed"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          settingModalBottomSheet(context);
        },
        child: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : feed.isEmpty
              ? Center(
                  child: Text("Nothing Here"),
                )
              : ListView.builder(
                  itemCount: feed.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      color: Colors.white,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 2, color: kPrimaryColor),
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/images/profile.png"))),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      feed[index]['sendBy'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(getTime(index))
                                  ],
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                              alignment: Alignment.bottomLeft,
                              child:
                                  "${feed[index]["text"]}".text.make().px8()),
                          SizedBox(
                            height: 10,
                          ),
                          feed[index]["type"] == "image"
                              ? ConstrainedBox(
                                  constraints: new BoxConstraints(
                                    minHeight: 200.0,
                                  ),
                                  child: DecoratedBox(
                                      decoration:
                                          BoxDecoration(color: Colors.black),
                                      child: Image.network(
                                        feed[index]["link"],
                                      )))
                              : feed[index]["type"] == "text"
                                  ? SizedBox()
                                  : InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    VideoPreviewDetails(
                                                      video: feed[index]
                                                          ["link"],
                                                    )));
                                      },
                                      child: ConstrainedBox(
                                          constraints: new BoxConstraints(
                                            minHeight: 200.0,
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              DecoratedBox(
                                                  decoration: BoxDecoration(
                                                      color: Colors.black),
                                                  child: Image.file(
                                                    File(feed[index]
                                                        ["thumbnail"]),
                                                  )),
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor:
                                                    Colors.black54,
                                                child: Icon(
                                                  Icons.play_arrow,
                                                  size: 40,
                                                ),
                                              )
                                            ],
                                          )),
                                    ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    );
                  }),
    );
  }

  pickFile() async {
    var result = await FileServices.pickFile();
    if (result != null) {
      PlatformFile file = result.files.first;
      var extension = file.extension;
      if (extension == "jpg" || extension == "png" || extension == "png") {
        if (!mounted) return;
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ImagePreview(
                      image: File(file.path!),
                      screen: false,
                      isPost: true,
                    )));
        getData();
      } else if (extension == "mp4") {
        if (!mounted) return;
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VideoPreview(
                      video: File(file.path!),
                      screen: false,
                      isPost: true,
                    )));
        getData();
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
                        Icons.text_fields,
                        color: Colors.white,
                      )),
                  title: Text('Text'),
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SendText(isPost: true,)));
                    getData();
                  },
                ),
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
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CameraScreen(isPost: true,)));
                      getData();
                    }),
              ],
            ),
          );
        });
  }
}
