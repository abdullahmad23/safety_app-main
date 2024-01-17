import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'image_preview.dart';
import 'video_preview.dart';
// ignore_for_file: prefer_const_constructors

late List<CameraDescription> cameras;

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key,required this.isPost}) : super(key: key);
  final bool isPost;
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool isRecording = false;
  bool isFlashOn = false;
  bool isFrontCamera = false;
  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Handle other errors.');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: FutureBuilder(builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                return CameraPreview(controller);
              }
            }, future: null,),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                          onTap: () {
                            setState(() {
                              isFlashOn = !isFlashOn;
                            });
                            isFlashOn?controller.setFlashMode(FlashMode.torch):controller.setFlashMode(FlashMode.off);
                          },
                          child:  Icon(
                            isFlashOn?Icons.flash_on:Icons.flash_off,
                            color: Colors.white,
                          )),
                      GestureDetector(
                          onLongPress: () async{
                           await controller.startVideoRecording();
                           setState(() {
                             isRecording = true;
                           });

                          },
                          onLongPressUp: () async{
                            final video = await controller.stopVideoRecording();
                            var videoPath = File(video.path);
                            setState(() {
                              isRecording = false;
                              isFlashOn = false;
                            });
                            isFlashOn?controller.setFlashMode(FlashMode.off):print("");
                            if (!mounted) return;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VideoPreview(
                                      video: videoPath,
                                      screen: true,
                                      isPost: widget.isPost,
                                    )));
                          },
                          onTap: () {
                            if(!isRecording){
                            takePhoto(context);
                            }
                          },
                          child: isRecording
                              ? Icon(
                                  Icons.radio_button_on,
                                  size: 80,
                                  color: Colors.red,
                                )
                              : Icon(
                                  Icons.panorama_fish_eye,
                                  size: 70,
                                  color: Colors.white,
                                )),
                      InkWell(
                          onTap: () async{
                            controller = CameraController(cameras[isFrontCamera?0:1], ResolutionPreset.high);
                            controller.initialize().then((_) {
                              if (!mounted) {
                                return;
                              }
                              setState(() {
                                isFrontCamera = !isFrontCamera;
                              });
                            }).catchError((Object e) {
                              if (e is CameraException) {
                                switch (e.code) {
                                  case 'CameraAccessDenied':
                                    print('User denied camera access.');
                                    break;
                                  default:
                                    print('Handle other errors.');
                                    break;
                                }
                              }
                            });
                          },
                          child: Icon(
                            Icons.flip_camera_ios_rounded,
                            color: Colors.white,
                          )),
                    ],
                  ),
                  Text(
                    "Hold for video, tap for photo",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void takePhoto(BuildContext context) async {
    final img = await controller.takePicture();
    var image = File(img.path);
    isFlashOn?controller.setFlashMode(FlashMode.off):print("");
    setState(() {
      isFlashOn = false;
    });
    if (!mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImagePreview(
                  image: image,screen: true,isPost: widget.isPost,
                )));
  }
}
